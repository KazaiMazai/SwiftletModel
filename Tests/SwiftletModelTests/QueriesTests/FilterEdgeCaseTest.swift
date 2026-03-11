//
//  FilterEdgeCaseTest.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 09/01/2026.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Index Out of Bounds", .tags(.query, .filter))
struct FilterIndexOutOfBoundsTests {

    var models: [TestingModels.Indexed.SingleProperty] {
        Range(0...10).map {
            TestingModels.Indexed.SingleProperty(id: "\($0)", value: $0)
        }
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.SingleProperty]) {
        var context = Context()
        let models = self.models
        try models
            .reversed()
            .forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Filter above upper bound returns empty result")
    func whenFilterOutOfUpperBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 > max.numOf1 + 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Filter below lower bound returns empty result")
    func whenFilterOutOfLowerBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 < min.numOf1 - 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Inclusive filter above upper bound returns empty result")
    func whenIncludingFilterOutOfUpperBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 >= max.numOf1 + 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Inclusive filter below lower bound returns empty result")
    func whenIncludingFilterOutOfLowerBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 <= min.numOf1 - 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }
}

@Suite("Filter Empty Context", .tags(.query, .filter))
struct FilterEmptyContextTests {

    @Test("Filter on empty context returns empty result")
    func whenFilterOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Filter with OR on empty context returns empty result")
    func whenFilterOrOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf1 == 2))
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Filter with sort on empty context returns empty result")
    func whenFilterSortOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 > 0)
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("String filter on empty context returns empty result")
    func whenStringFilterOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let filteredResult = TestingModels.Indexed.StringFullText
            .filter(.string(\.text, contains: "test"))
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }
}

@Suite("Filter Returns All Entities", .tags(.query, .filter))
struct FilterReturnsAllEntitiesTests {

    var models: [TestingModels.Indexed.SingleProperty] {
        Range(0...10).map {
            TestingModels.Indexed.SingleProperty(id: "\($0)", value: $0)
        }
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.SingleProperty]) {
        var context = Context()
        let models = self.models
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Filter matching all entities returns all")
    func whenFilterMatchesAll_ThenReturnsAll() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 >= min.numOf1)
            .resolve(in: context)

        #expect(filteredResult.count == models.count)
        #expect(Set(filteredResult.map { $0.id }) == Set(models.map { $0.id }))
    }

    @Test("Filter not equal to non-existent value returns all")
    func whenFilterNotEqualNonExistent_ThenReturnsAll() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 != max.numOf1 + 100)
            .resolve(in: context)

        #expect(filteredResult.count == models.count)
        #expect(Set(filteredResult.map { $0.id }) == Set(models.map { $0.id }))
    }
}

@Suite("Filter Exact Boundary Values", .tags(.query, .filter))
struct FilterExactBoundaryTests {

    // Use range 0...9 to avoid duplicate numOf1 values (since numOf1 = value % 10)
    var models: [TestingModels.Indexed.SingleProperty] {
        Range(0...9).map {
            TestingModels.Indexed.SingleProperty(id: "\($0)", value: $0)
        }
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.SingleProperty]) {
        var context = Context()
        let models = self.models
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Filter exactly at minimum boundary")
    func whenFilterAtMinBoundary_ThenIncludesMin() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!
        let expected = models.filter { $0.numOf1 >= min.numOf1 }

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 >= min.numOf1)
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter exactly at maximum boundary")
    func whenFilterAtMaxBoundary_ThenIncludesMax() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!
        let expected = models.filter { $0.numOf1 <= max.numOf1 }

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 <= max.numOf1)
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter exclusive at minimum boundary excludes min")
    func whenFilterExclusiveAtMinBoundary_ThenExcludesMin() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!
        let expected = models.filter { $0.numOf1 > min.numOf1 }

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 > min.numOf1)
            .resolve(in: context)

        #expect(filteredResult.count == expected.count)
        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter exclusive at maximum boundary excludes max")
    func whenFilterExclusiveAtMaxBoundary_ThenExcludesMax() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!
        let expected = models.filter { $0.numOf1 < max.numOf1 }

        let filteredResult = TestingModels.Indexed.SingleProperty
            .filter(\.numOf1 < max.numOf1)
            .resolve(in: context)

        #expect(filteredResult.count == expected.count)
        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}

@Suite("Filter Deeply Nested AND/OR", .tags(.query, .filter))
struct FilterDeeplyNestedTests {
    let count = 100

    var models: [TestingModels.Indexed.ManyProperties] {
        TestingModels.Indexed.ManyProperties.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.ManyProperties]) {
        var context = Context()
        let models = self.models
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Three level nested OR")
    func whenThreeLevelNestedOr_ThenMatchesCorrectly() throws {
        let (context, models) = try makeContext()
        let expected = models.filter {
            $0.numOf1 == 1 || $0.numOf1 == 2 || $0.numOf1 == 3
        }

        let filteredResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf1 == 2))
            .or(.filter(\.numOf1 == 3))
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Three level nested AND")
    func whenThreeLevelNestedAnd_ThenMatchesCorrectly() throws {
        let (context, models) = try makeContext()
        let expected = models.filter {
            $0.numOf1 == 1 && $0.numOf10 == 2 && $0.numOf100 == 0
        }

        let filteredResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .filter(\.numOf10 == 2)
            .filter(\.numOf100 == 0)
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Mixed three level AND/OR nesting - (A AND B) OR C")
    func whenMixedThreeLevelAndOr_ThenMatchesCorrectly() throws {
        let (context, models) = try makeContext()
        let expected = models.filter {
            ($0.numOf1 == 1 && $0.numOf10 == 2) || $0.numOf100 == 0
        }

        let filteredResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .filter(\.numOf10 == 2)
            .or(.filter(\.numOf100 == 0))
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Mixed three level OR/AND nesting - (A OR B) AND C")
    func whenMixedThreeLevelOrAnd_ThenMatchesCorrectly() throws {
        let (context, models) = try makeContext()
        let expected = models.filter {
            ($0.numOf1 == 1 || $0.numOf1 == 2) && $0.numOf10 < 5
        }

        let filteredResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf1 == 2))
            .and(\.numOf10 < 5)
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Four level nested OR")
    func whenFourLevelNestedOr_ThenMatchesCorrectly() throws {
        let (context, models) = try makeContext()
        let expected = models.filter {
            $0.numOf1 == 1 || $0.numOf1 == 2 || $0.numOf1 == 3 || $0.numOf1 == 4
        }

        let filteredResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .or(.filter(\.numOf1 == 2))
            .or(.filter(\.numOf1 == 3))
            .or(.filter(\.numOf1 == 4))
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Complex four level mixed nesting")
    func whenComplexFourLevelMixed_ThenMatchesCorrectly() throws {
        let (context, models) = try makeContext()
        // ((A AND B) OR (C AND D))
        let expected = models.filter {
            ($0.numOf1 == 1 && $0.numOf10 == 2) || ($0.numOf1 == 3 && $0.numOf10 == 4)
        }

        let filteredResult = TestingModels.Indexed.ManyProperties
            .filter(\.numOf1 == 1)
            .filter(\.numOf10 == 2)
            .or(.filter(\.numOf1 == 3).filter(\.numOf10 == 4))
            .resolve(in: context)

        #expect(Set(filteredResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
