//
//  FilterDateTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Date", .tags(.query, .filter))
struct FilterDateTests {
    let count = 100
    let baseDate = Date(timeIntervalSince1970: 1000000000) // Fixed base date for consistent testing

    var indexedModels: [TestingModels.Indexed.RichProperty] {
        TestingModels.Indexed.RichProperty.shuffled(count, baseDate: baseDate)
    }

    var notIndexedModels: [TestingModels.NotIndexed.RichProperty] {
        TestingModels.NotIndexed.RichProperty.shuffled(count, baseDate: baseDate)
    }

    private func makeContext() throws -> (context: Context, indexed: [TestingModels.Indexed.RichProperty], notIndexed: [TestingModels.NotIndexed.RichProperty]) {
        var context = Context()
        let indexed = indexedModels
        let notIndexed = notIndexedModels

        try indexed.forEach { try $0.save(to: &context) }
        try notIndexed.forEach { try $0.save(to: &context) }

        return (context, indexed, notIndexed)
    }

    @Test("Filter createdAt > someDate without index equals plain filtering")
    func whenFilterAfterDateNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)
        let expected = notIndexed.filter { $0.createdAt > midDate }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.createdAt > midDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter createdAt > someDate with index equals plain filtering")
    func whenFilterAfterDateIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)
        let expected = indexed.filter { $0.createdAt > midDate }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt > midDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter createdAt < someDate without index equals plain filtering")
    func whenFilterBeforeDateNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)
        let expected = notIndexed.filter { $0.createdAt < midDate }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.createdAt < midDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter createdAt < someDate with index equals plain filtering")
    func whenFilterBeforeDateIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)
        let expected = indexed.filter { $0.createdAt < midDate }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt < midDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter date range without index equals plain filtering")
    func whenFilterDateRangeNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let startDate = baseDate.addingTimeInterval(Double(count / 4) * 3600)
        let endDate = baseDate.addingTimeInterval(Double(count * 3 / 4) * 3600)
        let expected = notIndexed.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.createdAt >= startDate)
            .filter(\.createdAt <= endDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter date range with index equals plain filtering")
    func whenFilterDateRangeIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let startDate = baseDate.addingTimeInterval(Double(count / 4) * 3600)
        let endDate = baseDate.addingTimeInterval(Double(count * 3 / 4) * 3600)
        let expected = indexed.filter { $0.createdAt >= startDate && $0.createdAt <= endDate }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt >= startDate)
            .filter(\.createdAt <= endDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter createdAt == exactDate with index equals plain filtering")
    func whenFilterExactDateIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let exactDate = baseDate.addingTimeInterval(10 * 3600) // Entity at index 10
        let expected = indexed.filter { $0.createdAt == exactDate }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt == exactDate)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter createdAt != exactDate with index equals plain filtering")
    func whenFilterNotExactDateIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let exactDate = baseDate.addingTimeInterval(10 * 3600) // Entity at index 10
        let expected = indexed.filter { $0.createdAt != exactDate }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt != exactDate)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Date filter with OR combination equals plain filtering")
    func whenDateOrCombinationFilter_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let earlyDate = baseDate.addingTimeInterval(10 * 3600)
        let lateDate = baseDate.addingTimeInterval(Double(count - 10) * 3600)
        let expected = indexed.filter { $0.createdAt < earlyDate || $0.createdAt > lateDate }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt < earlyDate)
            .or(.filter(\.createdAt > lateDate))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Date combined with other filters equals plain filtering")
    func whenDateCombinedWithOtherFilters_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)
        let expected = indexed.filter { $0.createdAt > midDate && $0.isActive == true }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt > midDate)
            .filter(\.isActive == true)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
