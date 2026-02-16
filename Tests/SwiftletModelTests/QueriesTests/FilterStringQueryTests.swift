//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import Testing

@Suite
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

    @Test
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

    @Test
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

// Using parameterized tests for case sensitivity instead of inheritance
@Suite(.tags(.caseSensitive))
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

extension Tag {
    @Tag static var caseSensitive: Self
}

@Suite
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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
