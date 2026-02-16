//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 30/03/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite(.tags(.query, .sort))
struct SortByOnePathQueryTests {
    let count = 10

    var notIndexedModels: [TestingModels.NotIndexed] {
        TestingModels.NotIndexed.shuffled(count)
    }

    var indexedModels: [TestingModels.SingleValueIndexed] {
        TestingModels.SingleValueIndexed.shuffled(count)
    }

    var evalPropertyIndexedModels: [TestingModels.EvaluatedPropertyDescIndexed] {
        TestingModels.EvaluatedPropertyDescIndexed.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed], indexed: [TestingModels.SingleValueIndexed], evalPropertyIndexed: [TestingModels.EvaluatedPropertyDescIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels
        let evalPropertyIndexed = evalPropertyIndexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }
        try evalPropertyIndexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed, evalPropertyIndexed)
    }

    @Test
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _, _) = try makeContext()
        let expected = notIndexed
            .sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed, _) = try makeContext()
        let expected = indexed
            .sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.SingleValueIndexed
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _, _) = try makeContext()
        let expected = notIndexed
            .sorted { $0.numOf1 > $1.numOf1 }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, _, evalPropertyIndexed) = try makeContext()
        let expected = evalPropertyIndexed
            .sorted { $0.numOf1 > $1.numOf1 }

        let sortResult = TestingModels.EvaluatedPropertyDescIndexed
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite(.tags(.query, .sort))
struct SortByTwoPathsQueryTests {
    let count = 15

    var notIndexedModels: [TestingModels.NotIndexed] {
        TestingModels.NotIndexed.shuffled(count)
    }

    var indexedModels: [TestingModels.ExtensivelyIndexed] {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed], indexed: [TestingModels.ExtensivelyIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .sorted { ($0.numOf10, $0.numOf1) < ($1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf10, $0.numOf1) < ($1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf10.desc, $0.numOf1) < ($1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf10.desc, $0.numOf1) < ($1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite(.tags(.query, .sort))
struct SortByThreePathsQueryTests {
    let count = 120

    var notIndexedModels: [TestingModels.NotIndexed] {
        TestingModels.NotIndexed.shuffled(count)
    }

    var indexedModels: [TestingModels.ExtensivelyIndexed] {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed], indexed: [TestingModels.ExtensivelyIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .sorted { ($0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite(.tags(.query, .sort))
struct SortByFourPathsQueryTests {
    let count = 1200

    var notIndexedModels: [TestingModels.NotIndexed] {
        TestingModels.NotIndexed.shuffled(count)
    }

    var indexedModels: [TestingModels.ExtensivelyIndexed] {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed], indexed: [TestingModels.ExtensivelyIndexed]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

