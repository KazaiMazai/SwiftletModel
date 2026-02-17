//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Query", .tags(.query, .filter))
struct FilterQueryTests {
    let count = 100

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

    @Test("Filter without index equals plain filtering")
    func whenFilterNoIndex_ThenEqualPlainFitlering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter with index equals plain filtering")
    func whenFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Chained indexed filters equal plain filtering")
    func whenChainedFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                && $0.numOf10 == 2
            }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .filter(\.numOf10 == 2)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("AND predicate indexed filter equals plain filtering")
    func whenAndPredicateFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                && $0.numOf10 == 2
            }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .filter(\.numOf10 == 2)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("OR predicate indexed filter equals plain filtering")
    func whenOrPredicateFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                || $0.numOf10 == 2
            }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf10 == 2))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Complex indexed filter equals plain filtering")
    func whenComplexFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                ||  $0.numOf10 != 5
                || ($0.numOf1 > 1 && $0.numOf10 <= 4)
            }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf10 != 5))
            .or(.filter(\.numOf1 > 1).and(\.numOf10 <= 4))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Complex non-indexed filter equals plain filtering")
    func whenComplexFilterNotIndexed_ThenEqualPlainFiltering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter {
                $0.numOf1 == 1
                || $0.numOf10 != 5
                || ($0.numOf1 > 1 && $0.numOf10 <= 4)
            }

        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf10 != 5))
            .or(.filter(\.numOf1 > 1).and(\.numOf10 <= 4))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Complex comparison indexed filter equals plain filtering")
    func whenCompareComplexFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                ||  $0.numOf10 != 5
                || ($0.numOf1 >= 2 && $0.numOf10 < 4)
            }

        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf10 != 5))
            .or(.filter(\.numOf1 >= 2).and(\.numOf10 < 4))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Complex comparison non-indexed filter equals plain filtering")
    func whenCompareComplexFilterNotIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                ||  $0.numOf10 != 5
                || ($0.numOf1 >= 2 && $0.numOf10 < 4)
            }

        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf10 != 5))
            .or(.filter(\.numOf1 >= 2).and(\.numOf10 < 4))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
