//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 30/03/2025.
//

import SwiftletModel
import Foundation
import XCTest

class SortByOnePathQueryTests: XCTestCase {
    let count = 10
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.SingleValueIndexed.shuffled(count)
    }()

    lazy var evalPropertyIndexedModels = {
        TestingModels.EvaluatedPropertyDescIndexed.shuffled(count)
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }

        try evalPropertyIndexedModels
            .forEach { try $0.save(to: &context) }
    }

    func test_WhenSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.SingleValueIndexed
            .query(in: context)
            .sorted(by: \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { $0.numOf1 > $1.numOf1 }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf1.desc)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortIndexed_ThenEqualPlainSort() throws {
        let expected = evalPropertyIndexedModels
            .sorted { $0.numOf1 > $1.numOf1 }

        let sortResult = TestingModels.EvaluatedPropertyDescIndexed
            .query(in: context)
            .sorted(by: \.numOf1.desc)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
}

class SortByTwoPathsQueryTests: XCTestCase {
    let count = 15
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }

    }

    func test_WhenSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { ($0.numOf10, $0.numOf1) < ($1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf10, $0.numOf1) < ($1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query(in: context)
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortNoIndex_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf10.desc, $0.numOf1) < ($1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf10.desc, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf10.desc, $0.numOf1) < ($1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query(in: context)
            .sorted(by: \.numOf10.desc, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
}

class SortByThreePathsQueryTests: XCTestCase {
    let count = 120
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }

    }

    func test_WhenSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { ($0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf100, \.numOf10, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query(in: context)
            .sorted(by: \.numOf100, \.numOf10, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortNoIndex_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query(in: context)
            .sorted(by: \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
}

class SortByFourPathsQueryTests: XCTestCase {
    let count = 1200
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }

    }

    func test_WhenSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query(in: context)
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortNoIndex_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }

    func test_WhenDescSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query(in: context)
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(context)

        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
}

