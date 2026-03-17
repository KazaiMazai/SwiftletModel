//
//  FilterIndexedVsNonIndexedTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Indexed vs Non-Indexed Comparison", .tags(.query, .filter, .index))
struct FilterIndexedVsNonIndexedTests {
    let count = 100
    let baseDate = Date(timeIntervalSince1970: 1000000000)

    private func makeContext() throws -> Context {
        var context = Context()

        // Create equivalent data for both indexed and non-indexed models
        for idx in 0..<count {
            let statuses: [TestingModels.Indexed.RichProperty.Status] = [.draft, .published, .archived]
            let notIndexedStatuses: [TestingModels.NotIndexed.RichProperty.Status] = [.draft, .published, .archived]
            let titles = ["Introduction", "Overview", "Summary", "Details", "Conclusion"]
            let descriptions = ["A brief intro", "General overview", "Quick summary", "In-depth details", "Final thoughts"]
            let tag: String? = idx % 3 == 0 ? "tag-\(idx)" : nil

            let indexed = TestingModels.Indexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: statuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 5],
                description: descriptions[idx % 5],
                optionalTag: tag
            )

            let notIndexed = TestingModels.NotIndexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: notIndexedStatuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 5],
                description: descriptions[idx % 5],
                optionalTag: tag
            )

            try indexed.save(to: &context)
            try notIndexed.save(to: &context)
        }

        return context
    }

    // MARK: - Boolean Filter Comparison

    @Test("Boolean filter indexed equals non-indexed")
    func whenBooleanFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive == true)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Boolean negation filter indexed equals non-indexed")
    func whenBooleanNegationFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive != true)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive != true)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    // MARK: - Enum Filter Comparison

    @Test("Enum equality filter indexed equals non-indexed")
    func whenEnumEqualityFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.status == .published)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.status == .published)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Enum not-equal filter indexed equals non-indexed")
    func whenEnumNotEqualFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.status != .draft)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.status != .draft)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    // MARK: - Integer Comparison Filter

    @Test("Integer greater-than filter indexed equals non-indexed")
    func whenIntGreaterThanFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 50)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 50)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Integer less-than filter indexed equals non-indexed")
    func whenIntLessThanFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age < 30)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age < 30)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Integer range filter indexed equals non-indexed")
    func whenIntRangeFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age >= 25)
            .filter(\.age <= 75)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age >= 25)
            .filter(\.age <= 75)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    // MARK: - Date Filter Comparison

    @Test("Date greater-than filter indexed equals non-indexed")
    func whenDateGreaterThanFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt > midDate)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.createdAt > midDate)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Date range filter indexed equals non-indexed")
    func whenDateRangeFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let startDate = baseDate.addingTimeInterval(Double(count / 4) * 3600)
        let endDate = baseDate.addingTimeInterval(Double(count * 3 / 4) * 3600)

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.createdAt >= startDate)
            .filter(\.createdAt <= endDate)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.createdAt >= startDate)
            .filter(\.createdAt <= endDate)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    // MARK: - String Filter Comparison

    @Test("String contains filter indexed equals non-indexed")
    func whenStringContainsFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, contains: "Overview"))
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(.string(\.title, contains: "Overview"))
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("String prefix filter indexed equals non-indexed")
    func whenStringPrefixFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, hasPrefix: "Intro"))
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(.string(\.title, hasPrefix: "Intro"))
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Multi-field string filter indexed equals non-indexed")
    func whenMultiFieldStringFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(.string(\.title, \.description, contains: "intro"))
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(.string(\.title, \.description, contains: "intro"))
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    // MARK: - Complex Filter Comparison

    @Test("Chained AND filters indexed equals non-indexed")
    func whenChainedAndFilters_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .filter(\.age > 30)
            .filter(\.status == .published)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive == true)
            .filter(\.age > 30)
            .filter(\.status == .published)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("OR filter indexed equals non-indexed")
    func whenOrFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age < 10)
            .or(.filter(\.age > 90))
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age < 10)
            .or(.filter(\.age > 90))
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }

    @Test("Complex AND/OR filter indexed equals non-indexed")
    func whenComplexAndOrFilter_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let midDate = baseDate.addingTimeInterval(Double(count / 2) * 3600)

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .filter(\.age > 20)
            .or(.filter(\.createdAt > midDate))
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive == true)
            .filter(\.age > 20)
            .or(.filter(\.createdAt > midDate))
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
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

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        // For sorted results, order matters
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Filter then sort descending indexed equals non-indexed")
    func whenFilterThenSortDesc_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age < 30)
            .sorted(by: \.age.desc)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age < 30)
            .sorted(by: \.age.desc)
            .resolve(in: context)

        #expect(!indexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    // MARK: - Filter + Sort + Limit Comparison

    @Test("Filter sort limit indexed equals non-indexed")
    func whenFilterSortLimit_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let limit = 10

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit)
            .resolve(in: context)

        #expect(indexedResult.count == limit)
        #expect(notIndexedResult.count == limit)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    @Test("Filter sort limit offset indexed equals non-indexed")
    func whenFilterSortLimitOffset_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()
        let limit = 10
        let offset = 5

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit, offset: offset)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 20)
            .sorted(by: \.age)
            .limit(limit, offset: offset)
            .resolve(in: context)

        #expect(indexedResult.count == notIndexedResult.count)
        #expect(indexedResult.map { $0.id } == notIndexedResult.map { $0.id })
    }

    // MARK: - Edge Cases Comparison

    @Test("Empty result indexed equals non-indexed")
    func whenEmptyResult_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age > 1000) // No entities match
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age > 1000)
            .resolve(in: context)

        #expect(indexedResult.isEmpty)
        #expect(notIndexedResult.isEmpty)
        #expect(indexedResult.count == notIndexedResult.count)
    }

    @Test("All match indexed equals non-indexed")
    func whenAllMatch_IndexedEqualsNonIndexed() throws {
        let context = try makeContext()

        let indexedResult = TestingModels.Indexed.RichProperty
            .filter(\.age >= 0)
            .resolve(in: context)

        let notIndexedResult = TestingModels.NotIndexed.RichProperty
            .filter(\.age >= 0)
            .resolve(in: context)

        #expect(indexedResult.count == count)
        #expect(notIndexedResult.count == count)
        #expect(Set(indexedResult.map { $0.id }) == Set(notIndexedResult.map { $0.id }))
    }
}
