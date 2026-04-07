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

    @Test("Filter without index equals plain filtering")
    func whenFilterNoIndex_ThenEqualPlainFitlering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.NotIndexed.Model
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter with index equals plain filtering")
    func whenFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.Indexed.ManyProperties
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

        let filterResult = TestingModels.Indexed.ManyProperties
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

        let filterResult = TestingModels.Indexed.ManyProperties
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

        let filterResult = TestingModels.Indexed.ManyProperties
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

        let filterResult = TestingModels.Indexed.ManyProperties
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

        let filterResult = TestingModels.NotIndexed.Model
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

        let filterResult = TestingModels.NotIndexed.Model
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

        let filterResult = TestingModels.NotIndexed.Model
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf10 != 5))
            .or(.filter(\.numOf1 >= 2).and(\.numOf10 < 4))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    // MARK: - AND Query List Tests

    @Test("AND query list indexed filter equals intersection")
    func whenAndQueryListFilterIndexed_ThenEqualIntersection() throws {
        let (context, _, indexed) = try makeContext()
        let set1 = Set(indexed.filter { $0.numOf1 == 1 }.map { $0.id })
        let set2 = Set(indexed.filter { $0.numOf10 == 2 }.map { $0.id })
        let expected = set1.intersection(set2)

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .and(.filter(\.numOf10 == 2))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == expected)
    }

    @Test("AND query list non-indexed filter equals intersection")
    func whenAndQueryListFilterNotIndexed_ThenEqualIntersection() throws {
        let (context, notIndexed, _) = try makeContext()
        let set1 = Set(notIndexed.filter { $0.numOf1 == 1 }.map { $0.id })
        let set2 = Set(notIndexed.filter { $0.numOf10 == 2 }.map { $0.id })
        let expected = set1.intersection(set2)

        let filterResult = TestingModels.NotIndexed.Model
            .filter(\.numOf1 == 1)
            .and(.filter(\.numOf10 == 2))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == expected)
    }

    @Test("AND query list with no common elements returns empty")
    func whenAndQueryListNoCommonElements_ThenReturnsEmpty() throws {
        let (context, _, _) = try makeContext()

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .and(.filter(\.numOf1 == 2))
            .resolve(in: context)

        #expect(filterResult.isEmpty)
    }

    @Test("AND query list with subset returns subset")
    func whenAndQueryListWithSubset_ThenReturnsSubset() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.numOf1 == 1 && $0.numOf10 == 2 }

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .and(.filter(\.numOf1 == 1).filter(\.numOf10 == 2))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Chained AND query lists equals intersection of all")
    func whenChainedAndQueryLists_ThenEqualIntersectionOfAll() throws {
        let (context, _, indexed) = try makeContext()
        let set1 = Set(indexed.filter { $0.numOf1 <= 5 }.map { $0.id })
        let set2 = Set(indexed.filter { $0.numOf10 <= 3 }.map { $0.id })
        let set3 = Set(indexed.filter { $0.numOf100 == 0 }.map { $0.id })
        let expected = set1.intersection(set2).intersection(set3)

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 <= 5)
            .and(.filter(\.numOf10 <= 3))
            .and(.filter(\.numOf100 == 0))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == expected)
    }

    @Test("Complex AND and OR combination equals plain filtering")
    func whenComplexAndOrCombination_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                ($0.numOf1 == 1 || $0.numOf1 == 2)
                && ($0.numOf10 == 3 || $0.numOf10 == 4)
            }

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf1 == 2))
            .and(.filter(\.numOf10 == 3).or(.filter(\.numOf10 == 4)))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("AND query list preserves order from first query list")
    func whenAndQueryList_ThenPreservesOrderFromFirstList() throws {
        let (context, _, indexed) = try makeContext()
        let expectedIds = indexed
            .filter { $0.numOf1 == 1 && $0.numOf10 == 2 }
            .map { $0.id }

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .and(.filter(\.numOf10 == 2))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expectedIds))
    }

    @Test("AND with predicate and query list combined")
    func whenAndPredicateAndQueryListCombined_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter {
                $0.numOf1 == 1
                && $0.numOf10 <= 5
                && $0.numOf100 == 0
            }

        let filterResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .and(\.numOf10 <= 5)
            .and(.filter(\.numOf100 == 0))
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
