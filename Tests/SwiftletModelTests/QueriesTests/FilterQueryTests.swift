//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite(.tags(.query, .filter))
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

    @Test
    func whenFilterNoIndex_ThenEqualPlainFitlering() throws {
        let (context, notIndexed, _) = try makeContext()
        let expected = notIndexed
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.NotIndexed
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test
    func whenFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, _, indexed) = try makeContext()
        let expected = indexed
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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

    @Test
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
