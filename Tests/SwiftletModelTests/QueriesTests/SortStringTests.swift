//
//  SortStringTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Sort by String", .tags(.query, .sort))
struct SortStringTests {
    let count = 50

    var indexedModels: [TestingModels.Indexed.RichProperty] {
        let titles = ["Alpha", "Beta", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet"]
        let descriptions = ["First", "Second", "Third", "Fourth", "Fifth"]
        let statuses: [TestingModels.Indexed.RichProperty.Status] = [.draft, .published, .archived]
        let baseDate = Date(timeIntervalSince1970: 1000000000)

        var result: [TestingModels.Indexed.RichProperty] = []
        for idx in 0..<count {
            let model = TestingModels.Indexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: statuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 10],
                description: descriptions[idx % 5],
                optionalTag: idx % 3 == 0 ? "tag-\(idx)" : nil
            )
            result.append(model)
        }
        return result.shuffled()
    }

    var notIndexedModels: [TestingModels.NotIndexed.RichProperty] {
        let titles = ["Alpha", "Beta", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet"]
        let descriptions = ["First", "Second", "Third", "Fourth", "Fifth"]
        let statuses: [TestingModels.NotIndexed.RichProperty.Status] = [.draft, .published, .archived]
        let baseDate = Date(timeIntervalSince1970: 1000000000)

        var result: [TestingModels.NotIndexed.RichProperty] = []
        for idx in 0..<count {
            let model = TestingModels.NotIndexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: statuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 10],
                description: descriptions[idx % 5],
                optionalTag: idx % 3 == 0 ? "tag-\(idx)" : nil
            )
            result.append(model)
        }
        return result.shuffled()
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

    @Test("Sort by title ascending without index produces sorted result")
    func whenSortTitleAscNoIndex_ThenProducesSortedResult() throws {
        let (context, _, _) = try makeContext()

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title)
            .resolve(in: context)

        // Verify titles are in ascending order
        for i in 0..<(sortResult.count - 1) {
            #expect(sortResult[i].title <= sortResult[i + 1].title)
        }
    }

    @Test("Sort by title ascending with index produces sorted result")
    func whenSortTitleAscIndexed_ThenProducesSortedResult() throws {
        let (context, _, _) = try makeContext()

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title)
            .resolve(in: context)

        // Verify titles are in ascending order
        for i in 0..<(sortResult.count - 1) {
            #expect(sortResult[i].title <= sortResult[i + 1].title)
        }
    }

    // MARK: - Descending Sort Tests

    @Test("Sort by title descending without index produces sorted result")
    func whenSortTitleDescNoIndex_ThenProducesSortedResult() throws {
        let (context, _, _) = try makeContext()

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .resolve(in: context)

        // Verify titles are in descending order
        for i in 0..<(sortResult.count - 1) {
            #expect(sortResult[i].title >= sortResult[i + 1].title)
        }
    }

    @Test("Sort by title descending with index produces sorted result")
    func whenSortTitleDescIndexed_ThenProducesSortedResult() throws {
        let (context, _, _) = try makeContext()

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .resolve(in: context)

        // Verify titles are in descending order
        for i in 0..<(sortResult.count - 1) {
            #expect(sortResult[i].title >= sortResult[i + 1].title)
        }
    }

    // MARK: - Multi-key Sort with String

    @Test("Sort by title then age without index equals plain sort")
    func whenSortTitleThenAgeNoIndex_ThenEqualPlainSort() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.sorted { ($0.title, $0.age) < ($1.title, $1.age) }

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title, \.age)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by title then age with index equals plain sort")
    func whenSortTitleThenAgeIndexed_ThenEqualPlainSort() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.sorted { ($0.title, $0.age) < ($1.title, $1.age) }

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title, \.age)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by title desc then age asc without index equals plain sort")
    func whenSortTitleDescThenAgeAscNoIndex_ThenEqualPlainSort() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.sorted { ($0.title.desc, $0.age) < ($1.title.desc, $1.age) }

        let sortResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title.desc, \.age)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    // MARK: - Filter then Sort by String

    @Test("Filter then sort by title")
    func whenFilterThenSortByTitle_ThenCorrectOrder() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.isActive == true }
            .sorted { $0.title < $1.title }

        let sortResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .sorted(by: \.title)
            .resolve(in: context)

        #expect(!sortResult.isEmpty)
        // Compare titles since items with same title may have different relative order
        #expect(sortResult.map { $0.title } == expected.map { $0.title })
    }

    @Test("Filter then sort by title descending")
    func whenFilterThenSortByTitleDesc_ThenCorrectOrder() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed
            .filter { $0.age > 30 }
            .sorted { $0.title > $1.title }

        let sortResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 30)
            .sorted(by: \.title.desc)
            .resolve(in: context)

        #expect(!sortResult.isEmpty)
        // Compare titles since items with same title may have different relative order
        #expect(sortResult.map { $0.title } == expected.map { $0.title })
    }

    // MARK: - Sort + Limit with String

    @Test("Sort by title then limit")
    func whenSortTitleThenLimit_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 10
        let expected = Array(indexed.sorted { $0.title < $1.title }.prefix(limit))

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title)
            .limit(limit)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        // Compare titles since items with same title may have different relative order
        #expect(sortResult.map { $0.title } == expected.map { $0.title })
    }

    @Test("Sort by title desc then limit with offset")
    func whenSortTitleDescThenLimitOffset_ThenCorrectResults() throws {
        let (context, indexed, _) = try makeContext()
        let limit = 10
        let offset = 5
        let expected = Array(indexed.sorted { $0.title > $1.title }.dropFirst(offset).prefix(limit))

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .limit(limit, offset: offset)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        // Compare titles since items with same title may have different relative order
        #expect(sortResult.map { $0.title } == expected.map { $0.title })
    }
}
