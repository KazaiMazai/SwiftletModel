//
//  SortIndexedVsNonIndexedTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Sort Indexed vs Non-Indexed Comparison", .tags(.query, .sort, .index))
struct SortIndexedVsNonIndexedTests {
    let count = 100
    let baseDate = Date(timeIntervalSince1970: 1000000000)

    private func makeContext() throws -> Context {
        var context = Context()

        // Create equivalent data for both indexed and non-indexed models
        let statuses: [TestingModels.Indexed.RichProperty.Status] = [.draft, .published, .archived]
        let notIndexedStatuses: [TestingModels.NotIndexed.RichProperty.Status] = [.draft, .published, .archived]
        let titles = ["Alpha", "Beta", "Charlie", "Delta", "Echo", "Foxtrot", "Golf", "Hotel", "India", "Juliet"]
        let descriptions = ["First", "Second", "Third", "Fourth", "Fifth"]

        for idx in 0..<count {
            let tag: String? = idx % 3 == 0 ? "tag-\(idx)" : nil

            let indexed = TestingModels.Indexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: statuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 10],
                description: descriptions[idx % 5],
                optionalTag: tag
            )

            let notIndexed = TestingModels.NotIndexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: notIndexedStatuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 10],
                description: descriptions[idx % 5],
                optionalTag: tag
            )

            try indexed.save(to: &context)
            try notIndexed.save(to: &context)
        }

        return context
    }

    // MARK: - Integer Sort Comparison

    @Test("Sort by age ascending indexed equals non-indexed")
    func whenSortAgeAsc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.age)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Sort by age descending indexed equals non-indexed")
    func whenSortAgeDesc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.age.desc)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.age.desc)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    // MARK: - Date Sort Comparison

    @Test("Sort by createdAt ascending indexed equals non-indexed")
    func whenSortDateAsc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.createdAt)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Sort by createdAt descending indexed equals non-indexed")
    func whenSortDateDesc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.createdAt.desc)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    // MARK: - String Sort Comparison

    @Test("Sort by title ascending indexed equals non-indexed")
    func whenSortTitleAsc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        // Both should be sorted by title (values should match, order within same title may differ)
        #expect(indexedResult.map { $0.title } == notIndexedResult.map { $0.title })
    }

    @Test("Sort by title descending indexed equals non-indexed")
    func whenSortTitleDesc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        // Both should be sorted by title descending
        #expect(indexedResult.map { $0.title } == notIndexedResult.map { $0.title })
    }

    // MARK: - Multi-key Sort Comparison

    @Test("Sort by title then age indexed equals non-indexed")
    func whenSortTitleThenAge_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title, \.age)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title, \.age)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Sort by title desc then age asc indexed equals non-indexed")
    func whenSortTitleDescThenAgeAsc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title.desc, \.age)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title.desc, \.age)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Sort by createdAt then age indexed equals non-indexed")
    func whenSortDateThenAge_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.createdAt, \.age)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.createdAt, \.age)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    // MARK: - Sort + Limit Comparison

    @Test("Sort by age then limit indexed equals non-indexed")
    func whenSortAgeThenLimit_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let limit = 20

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        #expect(indexedResult.count == limit)
        #expect(notIndexedResult.count == limit)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Sort by title then limit with offset indexed equals non-indexed")
    func whenSortTitleThenLimitOffset_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let limit = 15
        let offset = 10

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title)
            .limit(limit, offset: offset)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title)
            .limit(limit, offset: offset)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        // Compare titles since items with same title may have different relative order
        #expect(indexedResult.map { $0.title } == notIndexedResult.map { $0.title })
    }

    // MARK: - Sort + First/Last Comparison

    @Test("Sort by age then first indexed equals non-indexed")
    func whenSortAgeThenFirst_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.age)
            .first()
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.age)
            .first()
            .resolve(in: context)

        // Compare values since there may be duplicates with same minimum age
        #expect(indexedResult?.age == notIndexedResult?.age)
    }

    @Test("Sort by age then last indexed equals non-indexed")
    func whenSortAgeThenLast_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.age)
            .last()
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.age)
            .last()
            .resolve(in: context)

        // Compare values since there may be duplicates with same maximum age
        #expect(indexedResult?.age == notIndexedResult?.age)
    }

    @Test("Sort by title desc then first indexed equals non-indexed")
    func whenSortTitleDescThenFirst_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .first()
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title.desc)
            .first()
            .resolve(in: context)

        // Compare titles since there may be duplicates
        #expect(indexedResult?.title == notIndexedResult?.title)
    }

    // MARK: - Filter + Sort Comparison

    @Test("Filter then sort indexed equals non-indexed")
    func whenFilterThenSort_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 50)
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Filter then sort by title desc indexed equals non-indexed")
    func whenFilterThenSortTitleDesc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .sorted(by: \.title.desc)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive == true)
            .sorted(by: \.title.desc)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        // Compare titles since items with same title may have different relative order
        #expect(indexedResult.map { $0.title } == notIndexedResult.map { $0.title })
    }

    @Test("Filter then sort then limit indexed equals non-indexed")
    func whenFilterThenSortThenLimit_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let limit = 10

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 30)
            .sorted(by: \.createdAt)
            .limit(limit)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 30)
            .sorted(by: \.createdAt)
            .limit(limit)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    // MARK: - Edge Cases Comparison

    @Test("Sort on empty filter result indexed equals non-indexed")
    func whenSortEmptyFilterResult_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 1000) // No matches
            .sorted(by: \.age)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 1000)
            .sorted(by: \.age)
            .resolve(in: context)

        #expect(indexedResult.isEmpty)
        #expect(notIndexedResult.isEmpty)
    }

    @Test("Sort all descending indexed equals non-indexed")
    func whenSortAllDesc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: \.title.desc, \.age.desc)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .query()
            .sorted(by: \.title.desc, \.age.desc)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }
}
