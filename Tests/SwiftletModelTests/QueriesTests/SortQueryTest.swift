//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 30/03/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Sort by One Path", .tags(.query, .sort))
struct SortByOnePathQueryTests {
    let count = 10

    var notIndexedModels: [TestingModels.NotIndexed.Model] {
        TestingModels.NotIndexed.Model.shuffled(count)
    }

    var indexedModels: [TestingModels.Indexed.SingleProperty] {
        TestingModels.Indexed.SingleProperty.shuffled(count)
    }

    var evalPropertyIndexedModels: [TestingModels.Indexed.SingleEvaluatedPropertyDesc] {
        TestingModels.Indexed.SingleEvaluatedPropertyDesc.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed.Model], indexed: [TestingModels.Indexed.SingleProperty], evalPropertyIndexed: [TestingModels.Indexed.SingleEvaluatedPropertyDesc]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels
        let evalPropertyIndexed = evalPropertyIndexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }
        try evalPropertyIndexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed, evalPropertyIndexed)
    }

    @Test("Sort by one path without index equals plain sort")
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _, _) = try makeContext()
        let expected = notIndexed
            .sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by one path with index equals plain sort")
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed, _) = try makeContext()
        let expected = indexed
            .sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by one path without index equals plain sort")
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _, _) = try makeContext()
        let expected = notIndexed
            .sorted { $0.numOf1 > $1.numOf1 }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by one path with index equals plain sort")
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, _, evalPropertyIndexed) = try makeContext()
        let expected = evalPropertyIndexed
            .sorted { $0.numOf1 > $1.numOf1 }

        let sortResult = TestingModels.Indexed.SingleEvaluatedPropertyDesc
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite("Sort by Two Paths", .tags(.query, .sort))
struct SortByTwoPathsQueryTests {
    let count = 15

    var notIndexedModels: [TestingModels.NotIndexed.Model] {
        TestingModels.NotIndexed.Model.shuffled(count)
    }

    var indexedModels: [TestingModels.Indexed.ManyProperties] {
        TestingModels.Indexed.ManyProperties.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed.Model], indexed: [TestingModels.Indexed.ManyProperties]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test("Sort by two paths without index equals plain sort")
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .sorted { ($0.numOf10, $0.numOf1) < ($1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by two paths with index equals plain sort")
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf10, $0.numOf1) < ($1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by two paths without index equals plain sort")
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf10.desc, $0.numOf1) < ($1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by two paths with index equals plain sort")
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf10.desc, $0.numOf1) < ($1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite("Sort by Three Paths", .tags(.query, .sort))
struct SortByThreePathsQueryTests {
    let count = 120

    var notIndexedModels: [TestingModels.NotIndexed.Model] {
        TestingModels.NotIndexed.Model.shuffled(count)
    }

    var indexedModels: [TestingModels.Indexed.ManyProperties] {
        TestingModels.Indexed.ManyProperties.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed.Model], indexed: [TestingModels.Indexed.ManyProperties]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test("Sort by three paths without index equals plain sort")
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .sorted { ($0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by three paths with index equals plain sort")
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by three paths without index equals plain sort")
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by three paths with index equals plain sort")
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite("Sort by Four Paths", .tags(.query, .sort))
struct SortByFourPathsQueryTests {
    let count = 1200

    var notIndexedModels: [TestingModels.NotIndexed.Model] {
        TestingModels.NotIndexed.Model.shuffled(count)
    }

    var indexedModels: [TestingModels.Indexed.ManyProperties] {
        TestingModels.Indexed.ManyProperties.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, notIndexed: [TestingModels.NotIndexed.Model], indexed: [TestingModels.Indexed.ManyProperties]) {
        var context = Context()
        let notIndexed = notIndexedModels
        let indexed = indexedModels

        try notIndexed.forEach { try $0.save(to: &context) }
        try indexed.forEach { try $0.save(to: &context) }

        return (context, notIndexed, indexed)
    }

    @Test("Sort by four paths without index equals plain sort")
    func whenSortNoIndex_ThenEqualPlainSort() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by four paths with index equals plain sort")
    func whenSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10, $1.numOf1) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by four paths without index equals plain sort")
    func whenDescSortNoIndex_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.NotIndexed.Model
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Descending sort by four paths with index equals plain sort")
    func whenDescSortIndexed_ThenEqualPlainSort() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .sorted { ($0.numOf1000, $0.numOf100, $0.numOf10.desc, $0.numOf1) < ($1.numOf1000, $1.numOf100, $1.numOf10.desc, $1.numOf1) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}
