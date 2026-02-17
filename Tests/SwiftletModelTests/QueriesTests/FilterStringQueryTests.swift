//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

final class FilterMatchStringQueryTests: XCTestCase {
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.StringPlain.shuffled()
    }()

    lazy var indexedModels = {
        TestingModels.Indexed.StringFullText.shuffled()
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }
    }

    func test_WhenMatchFilterNoIndex_ThenEqualPlainFitlering() throws {
        let expected = notIndexedModels
            .filter { $0.text.matches(fuzzy: "ananas") }

        let filterResult = TestingModels.NotIndexed.StringPlain
            .filter(.string(\.text, matches: "ananas"))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenMatchFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.text.matches(fuzzy: "ananas") }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, matches: "ananas"))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
}

final class FilterStringCaseSensitiveQueryTests: FilterStringQueryTests {
    override var caseSensitive: Bool { true }
}

class FilterStringQueryTests: XCTestCase {
    var context = Context()
    var caseSensitive: Bool { false }

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.StringPlain.shuffled()
    }()

    lazy var indexedModels = {
        TestingModels.Indexed.StringFullText.shuffled()
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }
    }

    func test_WhenContainsFilterNoIndex_ThenEqualPlainFitlering() throws {
        let expected = notIndexedModels
            .filter { $0.text.contains("ananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.NotIndexed.StringPlain
            .filter(.string(\.text, contains: "ananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenContainsFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.text.contains("ananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, contains: "ananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.hasPrefix("Sweet", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.NotIndexed.StringPlain
            .filter(.string(\.text, hasPrefix: "Sweet", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.text.hasPrefix("Sweet", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, hasPrefix: "Sweet", caseSensitive: caseSensitive))
            .resolve(in: context)

        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { $0.text.hasSuffix("selection", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.NotIndexed.StringPlain
            .filter(.string(\.text, hasSuffix: "selection", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.text.hasSuffix("selection", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, hasSuffix: "selection", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenNotHavingPrefixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { !$0.text.hasPrefix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.NotIndexed.StringPlain
            .filter(.string(\.text, notHavingPrefix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenNotHavingPrefixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { !$0.text.hasPrefix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, notHavingPrefix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenNotHavingSuffixFilterNoIndex_ThenEqualPlainFiltering() throws {
        let expected = notIndexedModels
            .filter { !$0.text.hasSuffix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.NotIndexed.StringPlain
            .filter(.string(\.text, notHavingSuffix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)
        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenNotHavingSuffixFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { !$0.text.hasSuffix("bananas", caseSensitive: caseSensitive) }

        let filterResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, notHavingSuffix: "bananas", caseSensitive: caseSensitive))
            .resolve(in: context)

        XCTAssertFalse(filterResult.isEmpty)
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }
}
