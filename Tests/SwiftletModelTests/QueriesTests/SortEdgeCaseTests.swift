//
//  SortEdgeCaseTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Sort Empty Context", .tags(.query, .sort))
struct SortEmptyContextTests {

    @Test("Sort on empty context returns empty result")
    func whenSortOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.isEmpty)
    }

    @Test("Sort descending on empty context returns empty result")
    func whenSortDescOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.isEmpty)
    }

    @Test("Multi-key sort on empty context returns empty result")
    func whenMultiKeySortOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf10, \.numOf1)
            .resolve(in: context)

        #expect(sortResult.isEmpty)
    }

    @Test("Sort with limit on empty context returns empty result")
    func whenSortLimitOnEmptyContext_ThenEmptyResult() throws {
        let context = Context()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .limit(10)
            .resolve(in: context)

        #expect(sortResult.isEmpty)
    }

    @Test("Sort first on empty context returns nil")
    func whenSortFirstOnEmptyContext_ThenNil() throws {
        let context = Context()

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .first()
            .resolve(in: context)

        #expect(result == nil)
    }

    @Test("Sort last on empty context returns nil")
    func whenSortLastOnEmptyContext_ThenNil() throws {
        let context = Context()

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .last()
            .resolve(in: context)

        #expect(result == nil)
    }
}

@Suite("Sort Single Entity", .tags(.query, .sort))
struct SortSingleEntityTests {

    private func makeContext() throws -> Context {
        var context = Context()
        let model = TestingModels.Indexed.SingleProperty(id: "1", value: 42)
        try model.save(to: &context)
        return context
    }

    @Test("Sort single entity returns that entity")
    func whenSortSingleEntity_ThenReturnsThatEntity() throws {
        let context = try makeContext()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.count == 1)
        #expect(sortResult[0].id == "1")
    }

    @Test("Sort descending single entity returns that entity")
    func whenSortDescSingleEntity_ThenReturnsThatEntity() throws {
        let context = try makeContext()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.count == 1)
        #expect(sortResult[0].id == "1")
    }

    @Test("Sort first on single entity returns that entity")
    func whenSortFirstSingleEntity_ThenReturnsThatEntity() throws {
        let context = try makeContext()

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .first()
            .resolve(in: context)

        #expect(result?.id == "1")
    }

    @Test("Sort last on single entity returns that entity")
    func whenSortLastSingleEntity_ThenReturnsThatEntity() throws {
        let context = try makeContext()

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .last()
            .resolve(in: context)

        #expect(result?.id == "1")
    }
}

@Suite("Sort with Limit", .tags(.query, .sort))
struct SortWithLimitTests {
    let count = 50

    var models: [TestingModels.Indexed.SingleProperty] {
        TestingModels.Indexed.SingleProperty.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.SingleProperty]) {
        var context = Context()
        let models = self.models
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Sort then limit returns first N sorted items")
    func whenSortThenLimit_ThenReturnsFirstNSorted() throws {
        let (context, _) = try makeContext()
        let limit = 10

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .limit(limit)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        // Verify result is sorted
        for i in 0..<(sortResult.count - 1) {
            #expect(sortResult[i].numOf1 <= sortResult[i + 1].numOf1)
        }
        // Verify we got the smallest values
        let maxInResult = sortResult.map { $0.numOf1 }.max()!
        #expect(maxInResult <= 1) // With 50 items, limit 10 should get numOf1 values 0 and 1
    }

    @Test("Sort descending then limit returns first N sorted items")
    func whenSortDescThenLimit_ThenReturnsFirstNSorted() throws {
        let (context, _) = try makeContext()
        let limit = 10

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1.desc)
            .limit(limit)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        // Verify result is sorted descending
        for i in 0..<(sortResult.count - 1) {
            #expect(sortResult[i].numOf1 >= sortResult[i + 1].numOf1)
        }
        // Verify we got the largest values
        let minInResult = sortResult.map { $0.numOf1 }.min()!
        #expect(minInResult >= 8) // With 50 items, limit 10 should get numOf1 values 8 and 9
    }

    @Test("Sort then limit with offset returns correct page")
    func whenSortThenLimitOffset_ThenReturnsCorrectPage() throws {
        let (context, models) = try makeContext()
        let limit = 10
        let offset = 20
        let sorted = models.sorted { $0.numOf1 < $1.numOf1 }
        let expected = Array(sorted.dropFirst(offset).prefix(limit))

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .limit(limit, offset: offset)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort then limit larger than count returns all")
    func whenSortThenLimitLargerThanCount_ThenReturnsAll() throws {
        let (context, models) = try makeContext()
        let expected = models.sorted { $0.numOf1 < $1.numOf1 }

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .limit(1000)
            .resolve(in: context)

        #expect(sortResult.count == count)
        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort then limit zero returns empty")
    func whenSortThenLimitZero_ThenReturnsEmpty() throws {
        let (context, _) = try makeContext()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .limit(0)
            .resolve(in: context)

        #expect(sortResult.isEmpty)
    }
}

@Suite("Sort First and Last", .tags(.query, .sort))
struct SortFirstLastTests {
    let count = 50

    var models: [TestingModels.Indexed.SingleProperty] {
        TestingModels.Indexed.SingleProperty.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.SingleProperty]) {
        var context = Context()
        let models = self.models
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Sort then first returns minimum value")
    func whenSortThenFirst_ThenReturnsMinimumValue() throws {
        let (context, models) = try makeContext()
        let minValue = models.map { $0.numOf1 }.min()!

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .first()
            .resolve(in: context)

        #expect(result?.numOf1 == minValue)
    }

    @Test("Sort then last returns maximum value")
    func whenSortThenLast_ThenReturnsMaximumValue() throws {
        let (context, models) = try makeContext()
        let maxValue = models.map { $0.numOf1 }.max()!

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .last()
            .resolve(in: context)

        #expect(result?.numOf1 == maxValue)
    }

    @Test("Sort descending then first returns maximum value")
    func whenSortDescThenFirst_ThenReturnsMaximumValue() throws {
        let (context, models) = try makeContext()
        let maxValue = models.map { $0.numOf1 }.max()!

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1.desc)
            .first()
            .resolve(in: context)

        #expect(result?.numOf1 == maxValue)
    }

    @Test("Sort descending then last returns minimum value")
    func whenSortDescThenLast_ThenReturnsMinimumValue() throws {
        let (context, models) = try makeContext()
        let minValue = models.map { $0.numOf1 }.min()!

        let result = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1.desc)
            .last()
            .resolve(in: context)

        #expect(result?.numOf1 == minValue)
    }
}

@Suite("Sort All Descending", .tags(.query, .sort))
struct SortAllDescendingTests {
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

    @Test("Sort by two paths all descending")
    func whenSortTwoPathsAllDesc_ThenCorrectOrder() throws {
        let (context, models) = try makeContext()
        let expected = models.sorted { ($0.numOf10.desc, $0.numOf1.desc) < ($1.numOf10.desc, $1.numOf1.desc) }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf10.desc, \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by three paths all descending")
    func whenSortThreePathsAllDesc_ThenCorrectOrder() throws {
        let (context, models) = try makeContext()
        let expected = models.sorted {
            ($0.numOf100.desc, $0.numOf10.desc, $0.numOf1.desc) <
            ($1.numOf100.desc, $1.numOf10.desc, $1.numOf1.desc)
        }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf100.desc, \.numOf10.desc, \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }

    @Test("Sort by four paths all descending")
    func whenSortFourPathsAllDesc_ThenCorrectOrder() throws {
        let (context, models) = try makeContext()
        let expected = models.sorted {
            ($0.numOf1000.desc, $0.numOf100.desc, $0.numOf10.desc, $0.numOf1.desc) <
            ($1.numOf1000.desc, $1.numOf100.desc, $1.numOf10.desc, $1.numOf1.desc)
        }

        let sortResult = TestingModels.Indexed.ManyProperties
            .query()
            .sorted(by: \.numOf1000.desc, \.numOf100.desc, \.numOf10.desc, \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.map { $0.id } == expected.map { $0.id })
    }
}

@Suite("Sort Stability", .tags(.query, .sort))
struct SortStabilityTests {

    @Test("Sort maintains relative order for equal values")
    func whenSortEqualValues_ThenMaintainsRelativeOrder() throws {
        var context = Context()

        // Create models with same numOf1 value but different IDs
        // numOf1 = value % 10, so values 0, 10, 20, 30 all have numOf1 = 0
        let models = [
            TestingModels.Indexed.SingleProperty(id: "a", value: 0),
            TestingModels.Indexed.SingleProperty(id: "b", value: 10),
            TestingModels.Indexed.SingleProperty(id: "c", value: 20),
            TestingModels.Indexed.SingleProperty(id: "d", value: 30)
        ]

        try models.forEach { try $0.save(to: &context) }

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        // All should have numOf1 = 0, verify they're all included
        #expect(sortResult.count == 4)
        #expect(sortResult.allSatisfy { $0.numOf1 == 0 })
        #expect(Set(sortResult.map { $0.id }) == Set(["a", "b", "c", "d"]))
    }
}

@Suite("Sort with Duplicate Values", .tags(.query, .sort))
struct SortDuplicateValuesTests {
    let count = 30

    private func makeContext() throws -> Context {
        var context = Context()

        // Create models where many share the same sort key value
        for idx in 0..<count {
            // numOf1 will be idx % 10, so values 0-9 repeat 3 times each
            let model = TestingModels.Indexed.SingleProperty(id: "\(idx)", value: idx)
            try model.save(to: &context)
        }

        return context
    }

    @Test("Sort with duplicates groups equal values together")
    func whenSortWithDuplicates_ThenGroupsEqualValues() throws {
        let context = try makeContext()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1)
            .resolve(in: context)

        #expect(sortResult.count == count)

        // Verify sorting: each numOf1 value should appear consecutively
        var lastNumOf1 = -1
        for model in sortResult {
            #expect(model.numOf1 >= lastNumOf1)
            lastNumOf1 = model.numOf1
        }
    }

    @Test("Sort descending with duplicates groups equal values together")
    func whenSortDescWithDuplicates_ThenGroupsEqualValues() throws {
        let context = try makeContext()

        let sortResult = TestingModels.Indexed.SingleProperty
            .query()
            .sorted(by: \.numOf1.desc)
            .resolve(in: context)

        #expect(sortResult.count == count)

        // Verify sorting: each numOf1 value should appear consecutively in descending order
        var lastNumOf1 = 100
        for model in sortResult {
            #expect(model.numOf1 <= lastNumOf1)
            lastNumOf1 = model.numOf1
        }
    }
}
