//
//  SortDateTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Sort by Date", .tags(.query, .sort))
struct SortDateTests {
    let count = 50
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

    // MARK: - Ascending Sort Tests

    @Test("Sort by createdAt ascending without index equals plain sort")
    func whenSortDateAscNoIndex_ThenEqualPlainSort() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.sorted { $0.createdAt < $1.createdAt }

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by createdAt ascending with index equals plain sort")
    func whenSortDateAscIndexed_ThenEqualPlainSort() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.sorted { $0.createdAt < $1.createdAt }

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Descending Sort Tests

    @Test("Sort by createdAt descending without index equals plain sort")
    func whenSortDateDescNoIndex_ThenEqualPlainSort() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.sorted { $0.createdAt > $1.createdAt }

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by createdAt descending with index equals plain sort")
    func whenSortDateDescIndexed_ThenEqualPlainSort() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.sorted { $0.createdAt > $1.createdAt }

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Multi-key Sort with Date

    @Test("Sort by createdAt then age without index equals plain sort")
    func whenSortDateThenAgeNoIndex_ThenEqualPlainSort() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.sorted { ($0.createdAt, $0.age) < ($1.createdAt, $1.age) }

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.createdAt, \.age)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by createdAt then age with index equals plain sort")
    func whenSortDateThenAgeIndexed_ThenEqualPlainSort() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.sorted { ($0.createdAt, $0.age) < ($1.createdAt, $1.age) }

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt, \.age)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by createdAt desc then age asc")
    func whenSortDateDescThenAgeAsc_ThenEqualPlainSort() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.sorted { ($0.createdAt.desc, $0.age) < ($1.createdAt.desc, $1.age) }

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc, \.age)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Filter then Sort by Date

    @Test("Filter then sort by createdAt ascending")
    func whenFilterThenSortByDateAsc_ThenCorrectOrder() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.isActive == true }
            .sorted { $0.createdAt < $1.createdAt }

        let sortResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .sorted(by: \.createdAt)
            .resolve(in: context)

        #expect(!sortResult.isEmpty)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter then sort by createdAt descending")
    func whenFilterThenSortByDateDesc_ThenCorrectOrder() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age > 30 }
            .sorted { $0.createdAt > $1.createdAt }

        let sortResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 30)
            .sorted(by: \.createdAt.desc)
            .resolve(in: context)

        #expect(!sortResult.isEmpty)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Filter by date range then sort by createdAt")
    func whenFilterDateRangeThenSort_ThenCorrectOrder() throws {
        let (context, indexed, _) = try makeContext()
        let startDate = baseDate.addingTimeInterval(Double(count / 4) * 3600)
        let endDate = baseDate.addingTimeInterval(Double(count * 3 / 4) * 3600)

        let expected = indexed
            .filter { $0.createdAt >= startDate && $0.createdAt <= endDate }
            .sorted { $0.createdAt < $1.createdAt }

        let sortResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt >= startDate)
            .filter(\.createdAt <= endDate)
            .sorted(by: \.createdAt)
            .resolve(in: context)

        #expect(!sortResult.isEmpty)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Sort + Limit with Date

    @Test("Sort by createdAt then limit")
    func whenSortDateThenLimit_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 10
        let expected = Array(indexed.sorted { $0.createdAt < $1.createdAt }.prefix(limit))

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .limit(limit)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by createdAt desc then limit with offset")
    func whenSortDateDescThenLimitOffset_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 10
        let offset = 5
        let expected = Array(indexed.sorted { $0.createdAt > $1.createdAt }.dropFirst(offset).prefix(limit))

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc)
            .limit(limit, offset: offset)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - First/Last with Date Sort

    @Test("Sort by createdAt then first returns oldest")
    func whenSortDateThenFirst_ThenReturnsOldest() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.min { $0.createdAt < $1.createdAt }

        let result = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .first()
            .resolve(in: context)

        #expect(result?.id == expected?.id)
    }

    @Test("Sort by createdAt then last returns newest")
    func whenSortDateThenLast_ThenReturnsNewest() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.max { $0.createdAt < $1.createdAt }

        let result = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .last()
            .resolve(in: context)

        #expect(result?.id == expected?.id)
    }

    @Test("Sort by createdAt desc then first returns newest")
    func whenSortDateDescThenFirst_ThenReturnsNewest() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.max { $0.createdAt < $1.createdAt }

        let result = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc)
            .first()
            .resolve(in: context)

        #expect(result?.id == expected?.id)
    }
}
