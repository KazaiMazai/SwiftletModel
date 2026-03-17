//
//  FilterStringEdgeCasesTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

@testable import SwiftletModel
import Foundation
import Testing

@Suite("Filter String Edge Cases", .tags(.query, .filter))
struct FilterStringEdgeCasesTests {

    @EntityModel
    struct IndexedStringModel: Sendable {
        @FullTextIndex<Self>(\.text) private var textIndex

        let id: String
        let text: String
    }

    @EntityModel
    struct NotIndexedStringModel: Sendable {
        let id: String
        let text: String
    }

    // MARK: - Empty String Tests

    @Test("Filter empty string contains without index")
    func whenFilterEmptyStringContainsNoIndex_ThenMatchesAll() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "hello"),
            NotIndexedStringModel(id: "2", text: "world"),
            NotIndexedStringModel(id: "3", text: "")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: ""))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter entity with empty text field")
    func whenFilterEntityWithEmptyText_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "hello"),
            NotIndexedStringModel(id: "2", text: ""),
            NotIndexedStringModel(id: "3", text: "world")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("hello", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "hello"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "1")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - Unicode Tests

    @Test("Filter unicode Japanese characters")
    func whenFilterUnicodeJapanese_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "Hello world"),
            NotIndexedStringModel(id: "2", text: "こんにちは世界"),
            NotIndexedStringModel(id: "3", text: "日本語テスト")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("日本語", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "日本語"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "3")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter unicode with emojis")
    func whenFilterUnicodeEmojis_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "Hello world"),
            NotIndexedStringModel(id: "2", text: "Party time! 🎉🎊"),
            NotIndexedStringModel(id: "3", text: "Success ✅")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("🎉", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "🎉"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "2")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter unicode mixed scripts")
    func whenFilterUnicodeMixedScripts_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "English only"),
            NotIndexedStringModel(id: "2", text: "Café résumé"),
            NotIndexedStringModel(id: "3", text: "Привет мир"),
            NotIndexedStringModel(id: "4", text: "中文和English混合")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expectedFrench = models.filter { $0.text.contains("résumé", caseSensitive: false) }
        let expectedRussian = models.filter { $0.text.contains("Привет", caseSensitive: false) }
        let expectedMixed = models.filter { $0.text.contains("中文", caseSensitive: false) }

        let filterFrench = NotIndexedStringModel
            .filter(.string(\.text, contains: "résumé"))
            .resolve(in: context)

        let filterRussian = NotIndexedStringModel
            .filter(.string(\.text, contains: "Привет"))
            .resolve(in: context)

        let filterMixed = NotIndexedStringModel
            .filter(.string(\.text, contains: "中文"))
            .resolve(in: context)

        #expect(Set(filterFrench.map { $0.id }) == Set(expectedFrench.map { $0.id }))
        #expect(Set(filterRussian.map { $0.id }) == Set(expectedRussian.map { $0.id }))
        #expect(Set(filterMixed.map { $0.id }) == Set(expectedMixed.map { $0.id }))
    }

    // MARK: - Special Characters Tests

    @Test("Filter special characters email")
    func whenFilterSpecialCharsEmail_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "Contact: foo@bar.com"),
            NotIndexedStringModel(id: "2", text: "Email: test@example.org"),
            NotIndexedStringModel(id: "3", text: "No email here")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("foo@bar.com", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "foo@bar.com"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "1")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter special characters path")
    func whenFilterSpecialCharsPath_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "File: /path/to/file.txt"),
            NotIndexedStringModel(id: "2", text: "URL: https://example.com/page"),
            NotIndexedStringModel(id: "3", text: "Simple text")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("/path/to/", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "/path/to/"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "1")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter special characters brackets and quotes")
    func whenFilterSpecialCharsBracketsQuotes_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "Array: [1, 2, 3]"),
            NotIndexedStringModel(id: "2", text: "Quote: \"Hello World\""),
            NotIndexedStringModel(id: "3", text: "Parentheses: (a, b)")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expectedBrackets = models.filter { $0.text.contains("[1, 2, 3]", caseSensitive: false) }
        let expectedQuotes = models.filter { $0.text.contains("\"Hello", caseSensitive: false) }

        let filterBrackets = NotIndexedStringModel
            .filter(.string(\.text, contains: "[1, 2, 3]"))
            .resolve(in: context)

        let filterQuotes = NotIndexedStringModel
            .filter(.string(\.text, contains: "\"Hello"))
            .resolve(in: context)

        #expect(Set(filterBrackets.map { $0.id }) == Set(expectedBrackets.map { $0.id }))
        #expect(Set(filterQuotes.map { $0.id }) == Set(expectedQuotes.map { $0.id }))
    }

    // MARK: - Whitespace Tests

    @Test("Filter leading and trailing whitespace")
    func whenFilterWhitespace_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "  leading spaces"),
            NotIndexedStringModel(id: "2", text: "trailing spaces  "),
            NotIndexedStringModel(id: "3", text: "  both sides  "),
            NotIndexedStringModel(id: "4", text: "no extra spaces")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("leading", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "leading"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "1")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter multiple internal whitespace")
    func whenFilterMultipleInternalWhitespace_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "word1  word2"),
            NotIndexedStringModel(id: "2", text: "word1   word2"),
            NotIndexedStringModel(id: "3", text: "word1 word2")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("word1  word2", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "word1  word2"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "1")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter tabs and newlines")
    func whenFilterTabsNewlines_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "line1\nline2"),
            NotIndexedStringModel(id: "2", text: "col1\tcol2"),
            NotIndexedStringModel(id: "3", text: "normal text")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expectedNewline = models.filter { $0.text.contains("line1\nline2", caseSensitive: false) }
        let expectedTab = models.filter { $0.text.contains("col1\tcol2", caseSensitive: false) }

        let filterNewline = NotIndexedStringModel
            .filter(.string(\.text, contains: "line1\nline2"))
            .resolve(in: context)

        let filterTab = NotIndexedStringModel
            .filter(.string(\.text, contains: "col1\tcol2"))
            .resolve(in: context)

        #expect(Set(filterNewline.map { $0.id }) == Set(expectedNewline.map { $0.id }))
        #expect(Set(filterTab.map { $0.id }) == Set(expectedTab.map { $0.id }))
    }

    // MARK: - Long String Tests

    @Test("Filter very long strings")
    func whenFilterVeryLongStrings_ThenMatchesCorrectly() throws {
        var context = Context()
        let longText = String(repeating: "a", count: 10000) + "UNIQUE" + String(repeating: "b", count: 10000)
        let models = [
            NotIndexedStringModel(id: "1", text: longText),
            NotIndexedStringModel(id: "2", text: "short text"),
            NotIndexedStringModel(id: "3", text: String(repeating: "x", count: 5000))
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.contains("UNIQUE", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, contains: "UNIQUE"))
            .resolve(in: context)

        #expect(filterResult.count == 1)
        #expect(filterResult.first?.id == "1")
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - Prefix/Suffix Edge Cases

    @Test("Filter prefix with single character")
    func whenFilterPrefixSingleChar_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "apple"),
            NotIndexedStringModel(id: "2", text: "banana"),
            NotIndexedStringModel(id: "3", text: "avocado")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.hasPrefix("a", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, hasPrefix: "a"))
            .resolve(in: context)

        #expect(filterResult.count == 2)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter suffix with single character")
    func whenFilterSuffixSingleChar_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "apple"),
            NotIndexedStringModel(id: "2", text: "banana"),
            NotIndexedStringModel(id: "3", text: "grape")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.hasSuffix("e", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, hasSuffix: "e"))
            .resolve(in: context)

        #expect(filterResult.count == 2)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter prefix equals full string")
    func whenFilterPrefixFullString_ThenMatchesCorrectly() throws {
        var context = Context()
        let models = [
            NotIndexedStringModel(id: "1", text: "exact"),
            NotIndexedStringModel(id: "2", text: "exactly"),
            NotIndexedStringModel(id: "3", text: "other")
        ]
        try models.forEach { try $0.save(to: &context) }

        let expected = models.filter { $0.text.hasPrefix("exact", caseSensitive: false) }

        let filterResult = NotIndexedStringModel
            .filter(.string(\.text, hasPrefix: "exact"))
            .resolve(in: context)

        #expect(filterResult.count == 2)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
