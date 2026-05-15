//
//  MetadataAccessorTests.swift
//  SwiftletModel
//
//  Created for Entity+Metadata accessors.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Metadata Accessors", .tags(.metadata))
struct MetadataAccessorTests {

    @EntityModel
    struct SimpleModel: Sendable {
        let id: String
        let value: Int
    }

    // MARK: - lastUpdatedAt

    @Test("lastUpdatedAt on empty context returns nil")
    func whenLastUpdatedAtEmptyContext_ThenReturnsNil() throws {
        let context = Context()

        #expect(SimpleModel.lastUpdatedAt(in: context) == nil)
    }

    @Test("lastUpdatedAt returns the most recent save time")
    func whenEntitiesSaved_ThenLastUpdatedAtMatchesNewest() throws {
        var context = Context()

        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)
        let model3 = SimpleModel(id: "3", value: 300)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model3.save(to: &context)

        let lastUpdatedAt = SimpleModel.lastUpdatedAt(in: context)

        #expect(lastUpdatedAt != nil)
        #expect(lastUpdatedAt == model3.updatedAt(in: context))
    }

    @Test("lastUpdatedAt reflects re-saving an older entity")
    func whenEntityReSaved_ThenLastUpdatedAtMovesForward() throws {
        var context = Context()

        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)

        let beforeReSave = try #require(SimpleModel.lastUpdatedAt(in: context))

        Thread.sleep(forTimeInterval: 0.01)
        try model1.save(to: &context)

        let afterReSave = try #require(SimpleModel.lastUpdatedAt(in: context))

        #expect(afterReSave > beforeReSave)
        #expect(afterReSave == model1.updatedAt(in: context))
    }

    @Test("lastUpdatedAt with a single entity equals that entity's updatedAt")
    func whenSingleEntity_ThenLastUpdatedAtEqualsEntityUpdatedAt() throws {
        var context = Context()

        let model = SimpleModel(id: "1", value: 100)
        try model.save(to: &context)

        #expect(SimpleModel.lastUpdatedAt(in: context) == model.updatedAt(in: context))
    }

    // MARK: - updatedAt

    @Test("updatedAt on empty context returns nil")
    func whenUpdatedAtEmptyContext_ThenReturnsNil() throws {
        let context = Context()

        let model = SimpleModel(id: "1", value: 100)
        #expect(model.updatedAt(in: context) == nil)
    }

    @Test("updatedAt for an unsaved entity returns nil")
    func whenEntityNotSaved_ThenUpdatedAtReturnsNil() throws {
        var context = Context()

        let saved = SimpleModel(id: "1", value: 100)
        try saved.save(to: &context)

        let unsaved = SimpleModel(id: "2", value: 200)
        #expect(unsaved.updatedAt(in: context) == nil)
    }

    @Test("updatedAt returns each entity's own save time")
    func whenEntitiesSaved_ThenUpdatedAtIsPerEntity() throws {
        var context = Context()

        let model1 = SimpleModel(id: "1", value: 100)
        let model2 = SimpleModel(id: "2", value: 200)

        try model1.save(to: &context)
        Thread.sleep(forTimeInterval: 0.01)
        try model2.save(to: &context)

        let updatedAt1 = try #require(model1.updatedAt(in: context))
        let updatedAt2 = try #require(model2.updatedAt(in: context))

        #expect(updatedAt1 < updatedAt2)
    }

    @Test("updatedAt moves forward when an entity is re-saved")
    func whenEntityReSaved_ThenUpdatedAtMovesForward() throws {
        var context = Context()

        let model = SimpleModel(id: "1", value: 100)
        try model.save(to: &context)

        let firstUpdatedAt = try #require(model.updatedAt(in: context))

        Thread.sleep(forTimeInterval: 0.01)
        try model.save(to: &context)

        let secondUpdatedAt = try #require(model.updatedAt(in: context))

        #expect(secondUpdatedAt > firstUpdatedAt)
    }
}
