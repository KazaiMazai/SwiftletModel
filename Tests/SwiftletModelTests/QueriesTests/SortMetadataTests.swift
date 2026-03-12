//
//  SortMetadataTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Sort by Metadata", .tags(.query, .sort, .metadata))
struct SortMetadataTests {

    @EntityModel
    struct SimpleModel: Sendable {
        let id: String
        let value: Int
    }

    // MARK: - Basic Metadata Sort Tests

    @Test("Sort by updatedAt orders by save time")
    func whenSortByUpdatedAt_ThenOrdersBySaveTime() throws {
        var context = Context()

        // Save models with delays to ensure different updatedAt timestamps
        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)
        let model3 = SimpleModel(id: "3", value: 300)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model3.save(to: &context)

        let sortResult = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .resolve(in: context)

        // Models should be sorted by save order (oldest first)
        #expect(sortResult.count == 3)
        #expect(sortResult[0].id == "1")
        #expect(sortResult[1].id == "2")
        #expect(sortResult[2].id == "3")
    }

    @Test("Sort by updatedAt reflects updates")
    func whenSortByUpdatedAt_ThenReflectsUpdates() throws {
        var context = Context()

        // Save models
        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)
        let model3 = SimpleModel(id: "3", value: 300)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model3.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)

        // Update model1 - should move to end
        try model1.save(to: &context)

        let sortResult = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .resolve(in: context)

        // model1 should now be last (most recently updated)
        #expect(sortResult.count == 3)
        #expect(sortResult[0].id == "2")
        #expect(sortResult[1].id == "3")
        #expect(sortResult[2].id == "1")
    }

    @Test("Sort by updatedAt with first returns oldest")
    func whenSortByUpdatedAtFirst_ThenReturnsOldest() throws {
        var context = Context()

        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)
        let model3 = SimpleModel(id: "3", value: 300)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model3.save(to: &context)

        let result = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .first()
            .resolve(in: context)

        #expect(result?.id == "1")
    }

    @Test("Sort by updatedAt with last returns newest")
    func whenSortByUpdatedAtLast_ThenReturnsNewest() throws {
        var context = Context()

        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)
        let model3 = SimpleModel(id: "3", value: 300)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model3.save(to: &context)

        let result = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .last()
            .resolve(in: context)

        #expect(result?.id == "3")
    }

    // MARK: - Metadata Sort with Limit

    @Test("Sort by updatedAt with limit returns oldest N")
    func whenSortByUpdatedAtWithLimit_ThenReturnsOldestN() throws {
        var context = Context()

        for i in 1...10 {
            let model = SimpleModel(id: "\(i)", value: i * 100)
            try model.save(to: &context)
            Thread.sleep(forTimeInterval: 0.005)
        }

        let sortResult = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .limit(3)
            .resolve(in: context)

        #expect(sortResult.count == 3)
        #expect(sortResult[0].id == "1")
        #expect(sortResult[1].id == "2")
        #expect(sortResult[2].id == "3")
    }

    @Test("Sort by updatedAt with limit and offset")
    func whenSortByUpdatedAtWithLimitOffset_ThenReturnsCorrectPage() throws {
        var context = Context()

        for i in 1...10 {
            let model = SimpleModel(id: "\(i)", value: i * 100)
            try model.save(to: &context)
            Thread.sleep(forTimeInterval: 0.005)
        }

        let sortResult = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .limit(3, offset: 3)
            .resolve(in: context)

        #expect(sortResult.count == 3)
        #expect(sortResult[0].id == "4")
        #expect(sortResult[1].id == "5")
        #expect(sortResult[2].id == "6")
    }

    // MARK: - Filter then Metadata Sort

    @Test("Filter then sort by updatedAt")
    func whenFilterThenSortByUpdatedAt_ThenFilteredAndSorted() throws {
        var context = Context()

        // Save odd and even models alternately
        for i in 1...6 {
            let model = SimpleModel(id: "\(i)", value: i * 100)
            try model.save(to: &context)
            Thread.sleep(forTimeInterval: 0.005)
        }

        // Filter for values > 200, then sort by updatedAt
        let sortResult = SimpleModel
            .filter(\.value > 200)
            .sorted(by: .updatedAt)
            .resolve(in: context)

        #expect(sortResult.count == 4) // values 300, 400, 500, 600
        #expect(sortResult[0].id == "3")
        #expect(sortResult[1].id == "4")
        #expect(sortResult[2].id == "5")
        #expect(sortResult[3].id == "6")
    }

    // MARK: - Empty Context

    @Test("Sort by updatedAt on empty context returns empty")
    func whenSortByUpdatedAtEmptyContext_ThenReturnsEmpty() throws {
        let context = Context()

        let sortResult = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .resolve(in: context)

        #expect(sortResult.isEmpty)
    }

    // MARK: - Single Entity

    @Test("Sort by updatedAt with single entity returns that entity")
    func whenSortByUpdatedAtSingleEntity_ThenReturnsSingleEntity() throws {
        var context = Context()

        let model = SimpleModel(id: "1", value: 100)
        try model.save(to: &context)

        let sortResult = SimpleModel
            .query()
            .sorted(by: .updatedAt)
            .resolve(in: context)

        #expect(sortResult.count == 1)
        #expect(sortResult[0].id == "1")
    }
}

@Suite("Sort by Metadata with RichProperty", .tags(.query, .sort, .metadata))
struct SortMetadataRichPropertyTests {
    let count = 20

    private func makeContext() throws -> Context {
        var context = Context()
        let baseDate = Date(timeIntervalSince1970: 1000000000)
        let statuses: [TestingModels.Indexed.RichProperty.Status] = [.draft, .published, .archived]
        let titles = ["Alpha", "Beta", "Charlie", "Delta", "Echo"]
        let descriptions = ["First", "Second", "Third", "Fourth", "Fifth"]

        for idx in 0..<count {
            let model = TestingModels.Indexed.RichProperty(
                id: "\(idx)",
                age: idx % 100,
                isActive: idx % 2 == 0,
                status: statuses[idx % 3],
                createdAt: baseDate.addingTimeInterval(Double(idx) * 3600),
                title: titles[idx % 5],
                description: descriptions[idx % 5],
                optionalTag: idx % 3 == 0 ? "tag-\(idx)" : nil
            )
            try model.save(to: &context)
            Thread.sleep(forTimeInterval: 0.005)
        }

        return context
    }

    @Test("Sort RichProperty by updatedAt")
    func whenSortRichPropertyByUpdatedAt_ThenCorrectOrder() throws {
        let context = try makeContext()

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: .updatedAt)
            .resolve(in: context)

        #expect(sortResult.count == count)
        // First saved should be first
        #expect(sortResult[0].id == "0")
        // Last saved should be last
        #expect(sortResult[count - 1].id == "\(count - 1)")
    }

    @Test("Filter RichProperty then sort by updatedAt")
    func whenFilterRichPropertyThenSortByUpdatedAt_ThenCorrectOrder() throws {
        let context = try makeContext()

        let sortResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .sorted(by: .updatedAt)
            .resolve(in: context)

        #expect(!sortResult.isEmpty)
        // All should be active
        #expect(sortResult.allSatisfy { $0.isActive == true })
        // Should be in save order (by updatedAt)
        for i in 0..<(sortResult.count - 1) {
            let currentId = Int(sortResult[i].id)!
            let nextId = Int(sortResult[i + 1].id)!
            #expect(currentId < nextId)
        }
    }

    @Test("Sort RichProperty by updatedAt with limit")
    func whenSortRichPropertyByUpdatedAtLimit_ThenReturnsOldest() throws {
        let context = try makeContext()
        let limit = 5

        let sortResult = TestingModels.Indexed.RichProperty
            .query()
            .sorted(by: .updatedAt)
            .limit(limit)
            .resolve(in: context)

        #expect(sortResult.count == limit)
        #expect(sortResult[0].id == "0")
        #expect(sortResult[limit - 1].id == "\(limit - 1)")
    }
}
