//
//  FilterStringRegexTests.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/04/2026.
//

@testable import SwiftletModel
import Foundation
import Testing

@Suite("Filter String Regex", .tags(.query, .filter))
struct FilterStringRegexTests {

    var notIndexedModels: [TestingModels.NotIndexed.StringModel] {
        TestingModels.NotIndexed.StringModel.shuffled()
    }

    var indexedModels: [TestingModels.Indexed.StringFullText] {
        TestingModels.Indexed.StringFullText.shuffled()
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed.StringModel], indexed: [TestingModels.Indexed.StringFullText]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    // MARK: - NSRegularExpression Tests

    @Test("NSRegularExpression filter without index equals plain filtering")
    func whenNSRegexFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "ananas", options: [])

        let expected = notIndexed.filter {
            regex.firstMatch(in: $0.text, range: NSRange(location: 0, length: $0.text.count)) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("NSRegularExpression filter with index equals plain filtering")
    func whenNSRegexFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let regex = try NSRegularExpression(pattern: "ananas", options: [])

        let expected = indexed.filter {
            regex.firstMatch(in: $0.text, range: NSRange(location: 0, length: $0.text.count)) != nil
        }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("NSRegularExpression case-insensitive filter without index")
    func whenNSRegexCaseInsensitiveNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "sweet", options: [.caseInsensitive])

        let expected = notIndexed.filter {
            regex.firstMatch(in: $0.text, range: NSRange(location: 0, length: $0.text.count)) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("NSRegularExpression with matching options")
    func whenNSRegexWithMatchingOptions_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "^Sweet", options: [])
        let options: NSRegularExpression.MatchingOptions = [.anchored]

        let expected = notIndexed.filter {
            regex.firstMatch(in: $0.text, options: options, range: NSRange(location: 0, length: $0.text.count)) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex, options: options))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("NSRegularExpression with complex pattern without index")
    func whenNSRegexComplexPatternNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "\\b[Bb]anana\\w*\\b", options: [])

        let expected = notIndexed.filter {
            regex.firstMatch(in: $0.text, range: NSRange(location: 0, length: $0.text.count)) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - Swift Regex Tests

    @available(iOS 16.0, *)
    @Test("Swift Regex filter without index equals plain filtering")
    func whenSwiftRegexFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try Regex("ananas")

        let expected = notIndexed.filter {
            $0.text.firstMatch(of: regex) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @available(iOS 16.0, *)
    @Test("Swift Regex filter with index equals plain filtering")
    func whenSwiftRegexFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let regex = try Regex("ananas")

        let expected = indexed.filter {
            $0.text.firstMatch(of: regex) != nil
        }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @available(iOS 16.0, *)
    @Test("Swift Regex case-insensitive filter without index")
    func whenSwiftRegexCaseInsensitiveNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try Regex("sweet").ignoresCase()

        let expected = notIndexed.filter {
            $0.text.firstMatch(of: regex) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @available(iOS 16.0, *)
    @Test("Swift Regex with complex pattern without index")
    func whenSwiftRegexComplexPatternNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try Regex("[Bb]anana\\w*")

        let expected = notIndexed.filter {
            $0.text.firstMatch(of: regex) != nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - Not Matching Regex Tests (NSRegularExpression)

    @Test("NSRegularExpression not matching filter without index")
    func whenNSRegexNotMatchingNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "ananas", options: [])

        let expected = notIndexed.filter {
            regex.firstMatch(in: $0.text, range: NSRange(location: 0, length: $0.text.count)) == nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, notMatching: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("NSRegularExpression not matching filter with index")
    func whenNSRegexNotMatchingIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let regex = try NSRegularExpression(pattern: "ananas", options: [])

        let expected = indexed.filter {
            regex.firstMatch(in: $0.text, range: NSRange(location: 0, length: $0.text.count)) == nil
        }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, notMatching: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("NSRegularExpression not matching with options")
    func whenNSRegexNotMatchingWithOptions_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "^Sweet", options: [.caseInsensitive])
        let options: NSRegularExpression.MatchingOptions = [.anchored]

        let expected = notIndexed.filter {
            regex.firstMatch(in: $0.text, options: options, range: NSRange(location: 0, length: $0.text.count)) == nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, notMatching: regex, options: options))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - Not Matching Regex Tests (Swift Regex)
    @available(iOS 16.0, *)
    @Test("Swift Regex not matching filter without index")
    func whenSwiftRegexNotMatchingNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try Regex("ananas")

        let expected = notIndexed.filter {
            $0.text.firstMatch(of: regex) == nil
        }

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, notMatching: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
    @available(iOS 16.0, *)
    @Test("Swift Regex not matching filter with index")
    func whenSwiftRegexNotMatchingIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let regex = try Regex("ananas")

        let expected = indexed.filter {
            $0.text.firstMatch(of: regex) == nil
        }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, notMatching: regex))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - Regex No Match Tests

    @Test("NSRegularExpression matching nothing returns empty")
    func whenNSRegexMatchesNothing_ThenReturnsEmpty() throws {
        let (context, _, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "^zzzzzzzzz$", options: [])

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(filterResult.isEmpty)
    }
    
    @available(iOS 16.0, *)
    @Test("Swift Regex matching nothing returns empty")
    func whenSwiftRegexMatchesNothing_ThenReturnsEmpty() throws {
        let (context, _, _) = try makeContext()
        let regex = try Regex("^zzzzzzzzz$")

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, matches: regex))
            .resolve(in: context)

        #expect(filterResult.isEmpty)
    }

    @Test("NSRegularExpression not matching everything returns all")
    func whenNSRegexNotMatchingMatchesNothing_ThenReturnsAll() throws {
        let (context, notIndexed, _) = try makeContext()
        let regex = try NSRegularExpression(pattern: "^zzzzzzzzz$", options: [])

        let filterResult = TestingModels.NotIndexed.StringModel
            .filter(.string(\.text, notMatching: regex))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(notIndexed.map { $0.id }))
    }
}
