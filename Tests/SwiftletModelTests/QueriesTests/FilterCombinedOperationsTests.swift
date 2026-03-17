//
//  FilterCombinedOperationsTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Combined Operations", .tags(.query, .filter, .sort))
struct FilterCombinedOperationsTests {
    let count = 100
    let baseDate = Date(timeIntervalSince1970: 1000000000)

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

    // MARK: - Filter + Sort Tests

    @Test("Filter then sort by age without index")
    func whenFilterThenSortNoIndex_ThenOrdersCorrectly() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed
            .filter { $0.age > 50 }
            .sorted { $0.age < $1.age }

        let result = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(!result.isEmpty)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter then sort by age with index")
    func whenFilterThenSortIndexed_ThenOrdersCorrectly() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age > 50 }
            .sorted { $0.age < $1.age }

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(!result.isEmpty)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter then sort descending")
    func whenFilterThenSortDesc_ThenOrdersCorrectly() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age < 30 }
            .sorted { $0.age > $1.age }

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age < 30)
            .sorted(by: \.age.desc)
            .resolve(in: context)

        #expect(!result.isEmpty)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter then sort by date")
    func whenFilterThenSortByDate_ThenOrdersCorrectly() throws {
        let (context, indexed, _) = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)
        let expected = indexed
            .filter { $0.createdAt > midDate }
            .sorted { $0.createdAt < $1.createdAt }

        let result = TestingModels.Indexed.RichProperty
            .filter(\.createdAt > midDate)
            .sorted(by: \.createdAt)
            .resolve(in: context)

        #expect(!result.isEmpty)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Filter + Sort + Limit Tests

    @Test("Filter then sort then limit without index")
    func whenFilterSortLimitNoIndex_ThenReturnsLimitedSortedResults() throws {
        let (context, _, notIndexed) = try makeContext()
        let limit = 10
        let expected = Array(notIndexed
            .filter { $0.age > 20 }
            .sorted { $0.age < $1.age }
            .prefix(limit))

        let result = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        #expect(result.count == limit)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter then sort then limit with index")
    func whenFilterSortLimitIndexed_ThenReturnsLimitedSortedResults() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 10
        let expected = Array(indexed
            .filter { $0.age > 20 }
            .sorted { $0.age < $1.age }
            .prefix(limit))

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        #expect(result.count == limit)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter then sort then limit with offset")
    func whenFilterSortLimitOffset_ThenReturnsCorrectPage() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 10
        let offset = 5
        let filtered = indexed.filter { $0.age > 20 }
        let sorted = filtered.sorted { $0.age < $1.age }
        let expected = Array(sorted.dropFirst(offset).prefix(limit))

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit, offset: offset)
            .resolve(in: context)

        #expect(result.count == min(limit, sorted.count - offset))
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter sort limit larger than result set")
    func whenLimitLargerThanResultSet_ThenReturnsAllMatching() throws {
        let (context, indexed, _) = try makeContext()
        let filtered = indexed.filter { $0.age > 95 }
        let expected = filtered.sorted { $0.age < $1.age }

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 95)
            .sorted(by: \.age)
            .limit(1000)
            .resolve(in: context)

        #expect(result.count == expected.count)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Multiple Filters + Sort Tests

    @Test("Multiple chained filters then sort")
    func whenMultipleFiltersThenSort_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age > 30 && $0.age < 70 && $0.isActive == true }
            .sorted { $0.age < $1.age }

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 30)
            .filter(\.age < 70)
            .filter(\.isActive == true)
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter with OR then sort")
    func whenFilterOrThenSort_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age < 10 || $0.age > 90 }
            .sorted { $0.age < $1.age }

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age < 10)
            .or(.filter(\.age > 90))
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(!result.isEmpty)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - First/Last with Filter Tests

    @Test("Filter then sorted first")
    func whenFilterThenSortedFirst_ThenReturnsFirstMatch() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age > 50 }
            .sorted { $0.age < $1.age }
            .first

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .first()
            .resolve(in: context)

        #expect(result?.id == expected?.id)
    }

    @Test("Filter then sorted last")
    func whenFilterThenSortedLast_ThenReturnsLastMatch() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age > 50 }
            .sorted { $0.age < $1.age }
            .last

        let result = TestingModels.Indexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .last()
            .resolve(in: context)

        #expect(result?.id == expected?.id)
    }

    // MARK: - Complex Combinations

    @Test("Complex filter with enum and bool then sort then limit")
    func whenComplexFilterSortLimit_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 5
        let expected = Array(indexed
            .filter { $0.status == .published && $0.isActive == true }
            .sorted { $0.age < $1.age }
            .prefix(limit))

        let result = TestingModels.Indexed.RichProperty
            .filter(\.status == .published)
            .filter(\.isActive == true)
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        #expect(result.count <= limit)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter by date range then sort by age then limit")
    func whenFilterDateRangeSortAgeThenLimit_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let startDate = baseDate.addingTimeInterval(Double(count / 4) * 3600)
        let endDate = baseDate.addingTimeInterval(Double(count * 3 / 4) * 3600)
        let limit = 10
        let expected = Array(indexed
            .filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
            .sorted { $0.age < $1.age }
            .prefix(limit))

        let result = TestingModels.Indexed.RichProperty
            .filter(\.createdAt >= startDate)
            .filter(\.createdAt <= endDate)
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        #expect(result.count <= limit)
        #expect(result.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort then filter consistency check")
    func whenSortThenFilter_ThenFilterResultIsSorted() throws {
        let (context, indexed, _) = try makeContext()
        // First do filter then sort
        let filterThenSort = TestingModels.Indexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .resolve(in: context)

        // Verify result is actually sorted
        let ages = filterThenSort.map { $0.age }
        let sortedAges = ages.sorted()
        #expect(ages == sortedAges)

        // Verify all match filter condition
        #expect(filterThenSort.allSatisfy { $0.age > 50 })
    }
}
