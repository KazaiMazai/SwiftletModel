//
//  FilterMultipleStringFieldsTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

@testable import SwiftletModel
import Foundation
import Testing

@Suite("Filter Multiple String Fields", .tags(.query, .filter))
struct FilterMultipleStringFieldsTests {
    let count = 100

    var indexedModels: [TestingModels.Indexed.RichProperty] {
        TestingModels.Indexed.RichProperty.shuffled(count)
    }

    var notIndexedModels: [TestingModels.NotIndexed.RichProperty] {
        TestingModels.NotIndexed.RichProperty.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, indexed: [TestingModels.Indexed.RichProperty], notIndexed: [TestingModels.NotIndexed.RichProperty]) {
        var context = Context()
        let indexed = indexedModels
        let notIndexed = notIndexedModels

        try indexed.forEach { try $0.save(to: &context) }
        try notIndexed.forEach { try $0.save(to: &context) }

        return (context, indexed, notIndexed)
    }

    @Test("Multi-field contains filter without index matches ANY field")
    func whenMultiFieldContainsNoIndex_ThenMatchesAnyField() throws {
        let (context, _, notIndexed) = try makeContext()
        // "intro" appears in description "A brief intro"
        let expected = notIndexed.filter {
            $0.title.contains("intro", caseSensitive: false)
            || $0.description.contains("intro", caseSensitive: false)
        }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(.string(\.title, \.description, contains: "intro"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field contains filter with index matches ANY field")
    func whenMultiFieldContainsIndexed_ThenMatchesAnyField() throws {
        let (context, indexed, _) = try makeContext()
        // "intro" appears in description "A brief intro"
        let expected = indexed.filter {
            $0.title.contains("intro", caseSensitive: false)
            || $0.description.contains("intro", caseSensitive: false)
        }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, contains: "intro"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field contains filter matches title field")
    func whenMultiFieldContains_ThenMatchesTitleField() throws {
        let (context, indexed, _) = try makeContext()
        // "Overview" appears in title
        let expected = indexed.filter {
            $0.title.contains("Overview", caseSensitive: false)
            || $0.description.contains("Overview", caseSensitive: false)
        }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, contains: "Overview"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field prefix filter without index matches ANY field")
    func whenMultiFieldPrefixNoIndex_ThenMatchesAnyField() throws {
        let (context, _, notIndexed) = try makeContext()
        // "A brief" is prefix of description "A brief intro"
        let expected = notIndexed.filter {
            $0.title.hasPrefix("Intro", caseSensitive: false)
            || $0.description.hasPrefix("Intro", caseSensitive: false)
        }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(.string(\.title, \.description, hasPrefix: "Intro"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field prefix filter with index matches ANY field")
    func whenMultiFieldPrefixIndexed_ThenMatchesAnyField() throws {
        let (context, indexed, _) = try makeContext()
        // "Intro" is prefix of title "Introduction"
        let expected = indexed.filter {
            $0.title.hasPrefix("Intro", caseSensitive: false)
            || $0.description.hasPrefix("Intro", caseSensitive: false)
        }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, hasPrefix: "Intro"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field suffix filter matches ANY field")
    func whenMultiFieldSuffix_ThenMatchesAnyField() throws {
        let (context, indexed, _) = try makeContext()
        // "thoughts" is suffix of description "Final thoughts"
        let expected = indexed.filter {
            $0.title.hasSuffix("thoughts", caseSensitive: false)
            || $0.description.hasSuffix("thoughts", caseSensitive: false)
        }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, hasSuffix: "thoughts"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field matches filter without index matches ANY field")
    func whenMultiFieldMatchesNoIndex_ThenMatchesAnyField() throws {
        let (context, _, notIndexed) = try makeContext()
        // Fuzzy match for "general"
        let expected = notIndexed.filter {
            $0.title.matches(fuzzy: "general")
            || $0.description.matches(fuzzy: "general")
        }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(.string(\.title, \.description, matches: "general"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field matches filter with index matches ANY field")
    func whenMultiFieldMatchesIndexed_ThenMatchesAnyField() throws {
        let (context, indexed, _) = try makeContext()
        // Fuzzy match for "general"
        let expected = indexed.filter {
            $0.title.matches(fuzzy: "general")
            || $0.description.matches(fuzzy: "general")
        }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, matches: "general"))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field filter combined with other filters")
    func whenMultiFieldCombinedWithOtherFilters_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter {
            ($0.title.contains("Overview", caseSensitive: false)
             || $0.description.contains("Overview", caseSensitive: false))
            && $0.isActive == true
        }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, contains: "Overview"))
            .filter(\.isActive == true)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multi-field filter case sensitivity")
    func whenMultiFieldCaseSensitive_ThenRespectsCase() throws {
        let (context, indexed, _) = try makeContext()
        // Case sensitive: "overview" should not match "Overview"
        let expectedCaseSensitive = indexed.filter {
            $0.title.contains("overview", caseSensitive: true)
            || $0.description.contains("overview", caseSensitive: true)
        }
        // Case insensitive: "overview" should match "Overview"
        let expectedCaseInsensitive = indexed.filter {
            $0.title.contains("overview", caseSensitive: false)
            || $0.description.contains("overview", caseSensitive: false)
        }

        let filterResultCaseSensitive = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, contains: "overview", caseSensitive: true))
            .resolve(in: context)

        let filterResultCaseInsensitive = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, contains: "overview", caseSensitive: false))
            .resolve(in: context)

        #expect(Set(filterResultCaseSensitive.map { $0.id }) == Set(expectedCaseSensitive.map { $0.id }))
        #expect(Set(filterResultCaseInsensitive.map { $0.id }) == Set(expectedCaseInsensitive.map { $0.id }))
    }
}
