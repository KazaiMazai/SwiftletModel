//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import Testing

@Suite("Filter String Match", .tags(.query, .filter))
struct FilterMatchStringQueryTests {

    var notIndexedModels: [TestingModels.StringNotIndexed] {
        TestingModels.StringNotIndexed.shuffled()
    }

    var indexedModels: [TestingModels.StringFullTextIndexed] {
        TestingModels.StringFullTextIndexed.shuffled()
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.StringNotIndexed], indexed: [TestingModels.StringFullTextIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test("Match filter without index equals plain filtering")
    func whenMatchFilterNoIndex_ThenEqualPlainFitlering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.matches(fuzzy: "ananas") }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, matches: "ananas"))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Match filter with index equals plain filtering")
    func whenMatchFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.matches(fuzzy: "ananas") }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, matches: "ananas"))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}

@Suite("Filter String Case-Sensitive", .tags(.query, .filter))
struct FilterStringCaseSensitiveQueryTests {
    let caseSensitive = true

    var notIndexedModels: [TestingModels.StringNotIndexed] {
        TestingModels.StringNotIndexed.shuffled()
    }

    var indexedModels: [TestingModels.StringFullTextIndexed] {
        TestingModels.StringFullTextIndexed.shuffled()
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.StringNotIndexed], indexed: [TestingModels.StringFullTextIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test("Contains filter without index equals plain filtering (case-sensitive)")
    func whenContainsFilterNoIndex_ThenEqualPlainFitlering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.contains("ananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, contains: "ananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Contains filter with index equals plain filtering (case-sensitive)")
    func whenContainsFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.contains("ananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, contains: "ananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Prefix filter without index equals plain filtering (case-sensitive)")
    func whenPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.hasPrefix("Sweet", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, hasPrefix: "Sweet", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Prefix filter with index equals plain filtering (case-sensitive)")
    func whenPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.hasPrefix("Sweet", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, hasPrefix: "Sweet", caseSensitive: caseSensitive))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Suffix filter without index equals plain filtering (case-sensitive)")
    func whenSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.hasSuffix("selection", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, hasSuffix: "selection", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Suffix filter with index equals plain filtering (case-sensitive)")
    func whenSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.hasSuffix("selection", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, hasSuffix: "selection", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having prefix filter without index equals plain filtering (case-sensitive)")
    func whenNotHavingPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { !$0.text.hasPrefix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, notHavingPrefix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having prefix filter with index equals plain filtering (case-sensitive)")
    func whenNotHavingPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { !$0.text.hasPrefix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, notHavingPrefix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having suffix filter without index equals plain filtering (case-sensitive)")
    func whenNotHavingSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { !$0.text.hasSuffix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, notHavingSuffix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having suffix filter with index equals plain filtering (case-sensitive)")
    func whenNotHavingSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { !$0.text.hasSuffix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, notHavingSuffix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}

@Suite("Filter String Case-Insensitive", .tags(.query, .filter))
struct FilterStringQueryTests {
    let caseSensitive = false

    var notIndexedModels: [TestingModels.StringNotIndexed] {
        TestingModels.StringNotIndexed.shuffled()
    }

    var indexedModels: [TestingModels.StringFullTextIndexed] {
        TestingModels.StringFullTextIndexed.shuffled()
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.StringNotIndexed], indexed: [TestingModels.StringFullTextIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test("Contains filter without index equals plain filtering (case-insensitive)")
    func whenContainsFilterNoIndex_ThenEqualPlainFitlering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.contains("ananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, contains: "ananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Contains filter with index equals plain filtering (case-insensitive)")
    func whenContainsFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.contains("ananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, contains: "ananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Prefix filter without index equals plain filtering (case-insensitive)")
    func whenPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.hasPrefix("Sweet", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, hasPrefix: "Sweet", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Prefix filter with index equals plain filtering (case-insensitive)")
    func whenPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.hasPrefix("Sweet", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, hasPrefix: "Sweet", caseSensitive: caseSensitive))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Suffix filter without index equals plain filtering (case-insensitive)")
    func whenSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.text.hasSuffix("selection", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, hasSuffix: "selection", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Suffix filter with index equals plain filtering (case-insensitive)")
    func whenSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.text.hasSuffix("selection", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, hasSuffix: "selection", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having prefix filter without index equals plain filtering (case-insensitive)")
    func whenNotHavingPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { !$0.text.hasPrefix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, notHavingPrefix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having prefix filter with index equals plain filtering (case-insensitive)")
    func whenNotHavingPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { !$0.text.hasPrefix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, notHavingPrefix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having suffix filter without index equals plain filtering (case-insensitive)")
    func whenNotHavingSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { !$0.text.hasSuffix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringNotIndexed
            .filter(.string(\.text, notHavingSuffix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Not having suffix filter with index equals plain filtering (case-insensitive)")
    func whenNotHavingSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { !$0.text.hasSuffix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.StringFullTextIndexed
            .filter(.string(\.text, notHavingSuffix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
