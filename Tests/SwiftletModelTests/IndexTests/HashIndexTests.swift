//
//  HashIndexTests.swift
//  SwiftletModel
//
//  Created on 13/02/2026.
//

import SwiftletModel
import Foundation
import Testing

// MARK: - Single Property HashIndex Tests

@Suite("Hash Index", .tags(.query, .filter, .index, .hashIndex))
struct HashIndexTests {

    @Test("Saved entity is added to hash index")
    func whenEntitySaved_ThenIndexContainsEntity() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(["1"]))
    }

    @Test("Multiple entities with same value are in same bucket")
    func whenMultipleEntitiesWithSameValue_ThenAllInSameBucket() throws {
        var context = Context()
        let entities = [
            TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10),
            TestingModels.Indexed.HashSingleProperty(id: "2", category: "A", value: 20),
            TestingModels.Indexed.HashSingleProperty(id: "3", category: "B", value: 30)
        ]

        try entities.forEach { try $0.save(to: &context) }

        let resultA = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        let resultB = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "B")
            .resolve(in: context)

        #expect(Set(resultA.map { $0.id }) == Set(["1", "2"]))
        #expect(Set(resultB.map { $0.id }) == Set(["3"]))
    }

    @Test("Entity value update migrates to new bucket")
    func whenEntityValueUpdated_ThenBucketMigration() throws {
        var context = Context()
        var entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "B", value: 10)
        try entity.save(to: &context)

        let resultA = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        let resultB = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "B")
            .resolve(in: context)

        #expect(resultA.isEmpty, "Entity should no longer be in bucket A")
        #expect(Set(resultB.map { $0.id }) == Set(["1"]))
    }

    @Test("Saving entity with same value does not duplicate")
    func whenEntitySavedWithSameValue_ThenNoRedundantUpdate() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try entity.save(to: &context)

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(result.count == 1, "Should still have exactly one entity")
        #expect(result.first?.id == "1")
    }

    @Test("Deleted entity is removed from index")
    func whenEntityDeleted_ThenRemovedFromIndex() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try TestingModels.Indexed.HashSingleProperty.delete(id: "1", from: &context)

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(result.isEmpty)
    }

    @Test("Deleting one entity preserves others in index")
    func whenOneOfMultipleEntitiesDeleted_ThenOthersRemainInIndex() throws {
        var context = Context()
        let entities = [
            TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10),
            TestingModels.Indexed.HashSingleProperty(id: "2", category: "A", value: 20),
            TestingModels.Indexed.HashSingleProperty(id: "3", category: "A", value: 30)
        ]
        try entities.forEach { try $0.save(to: &context) }

        try TestingModels.Indexed.HashSingleProperty.delete(id: "1", from: &context)

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(["2", "3"]),
            "Deleting one entity should not remove others with same indexed value")
    }

    @Test("Deleting last entity in bucket cleans up bucket")
    func whenLastEntityInBucketDeleted_ThenBucketCleanup() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try TestingModels.Indexed.HashSingleProperty.delete(id: "1", from: &context)

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(result.isEmpty)
    }

    @Test("Filter by non-existent value returns empty")
    func whenFilterByNonExistentValue_ThenReturnsEmpty() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashSingleProperty(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "Z")
            .resolve(in: context)

        #expect(result.isEmpty)
    }
}

// MARK: - Compound HashIndex Tests

@Suite("Compound Hash Index", .tags(.query, .filter, .index, .hashIndex))
struct CompoundHashIndexTests {

    // MARK: - Pair (Two Properties) Tests

    @Test("Pair index requires both properties to match")
    func whenPairIndex_ThenBothPropertiesMustMatch() throws {
        var context = Context()
        let entities = [
            TestingModels.Indexed.HashPropertyPair(id: "1", category: "A", subcategory: "X", value: 10),
            TestingModels.Indexed.HashPropertyPair(id: "2", category: "A", subcategory: "Y", value: 20),
            TestingModels.Indexed.HashPropertyPair(id: "3", category: "B", subcategory: "X", value: 30)
        ]

        try entities.forEach { try $0.save(to: &context) }

        let result = TestingModels.Indexed.HashPropertyPair
            .filter(\.category == "A")
            .filter(\.subcategory == "X")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(["1"]))
    }

    @Test("Pair index value update migrates to new bucket")
    func whenPairIndexValueUpdated_ThenMigratesToNewBucket() throws {
        var context = Context()
        var entity = TestingModels.Indexed.HashPropertyPair(
            id: "1", category: "A", subcategory: "X", value: 10
        )
        try entity.save(to: &context)

        entity = TestingModels.Indexed.HashPropertyPair(
            id: "1", category: "A", subcategory: "Y", value: 10
        )
        try entity.save(to: &context)

        let oldResult = TestingModels.Indexed.HashPropertyPair
            .filter(\.category == "A")
            .filter(\.subcategory == "X")
            .resolve(in: context)

        let newResult = TestingModels.Indexed.HashPropertyPair
            .filter(\.category == "A")
            .filter(\.subcategory == "Y")
            .resolve(in: context)

        #expect(oldResult.isEmpty)
        #expect(Set(newResult.map { $0.id }) == Set(["1"]))
    }

    // MARK: - Triplet (Three Properties) Tests

    @Test("Triplet index requires all three properties to match")
    func whenTripletIndex_ThenAllThreeMatch() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashPropertyTriplet(
            id: "1", region: "US", category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.Indexed.HashPropertyTriplet
            .filter(\.region == "US")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        #expect(result.count == 1)
        #expect(result.first?.id == "1")
    }

    // MARK: - Quadruple (Four Properties) Tests

    @Test("Quadruple index requires all four properties to match")
    func whenQuadrupleIndex_ThenAllFourMatch() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashPropertyQuadruple(
            id: "1", region: "Americas", country: "US",
            category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.Indexed.HashPropertyQuadruple
            .filter(\.region == "Americas")
            .filter(\.country == "US")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        #expect(result.count == 1)
        #expect(result.first?.id == "1")
    }

    @Test("Quadruple partial match returns no results")
    func whenQuadruplePartialMatch_ThenNoResults() throws {
        var context = Context()
        let entity = TestingModels.Indexed.HashPropertyQuadruple(
            id: "1", region: "Americas", country: "US",
            category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.Indexed.HashPropertyQuadruple
            .filter(\.region == "Americas")
            .filter(\.country == "Canada")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        #expect(result.isEmpty)
    }
}

// MARK: - HashIndex Query Integration Tests

@Suite("Hash Index Query Integration", .tags(.query, .filter, .index, .hashIndex))
struct HashIndexQueryTests {
    let count = 100

    private func makeContext() throws -> (context: Context, models: [TestingModels.Indexed.HashSingleProperty]) {
        var context = Context()
        let models = TestingModels.Indexed.HashSingleProperty.shuffled(count)
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Hash indexed filter equals plain filtering")
    func whenHashIndexedVsPlainFilter_ThenSameResults() throws {
        let (context, models) = try makeContext()
        let expected = models.filter { $0.category == "A" }

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("OR predicate with hash index returns correct results")
    func whenOrPredicateWithHashIndex_ThenCorrectResults() throws {
        let (context, models) = try makeContext()
        let expected = models.filter { $0.category == "A" || $0.category == "B" }

        let result = TestingModels.Indexed.HashSingleProperty
            .filter(\.category == "A")
            .or(.filter(\.category == "B"))
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Existing User model hash index query works")
    func whenExistingUserModelHashIndex_ThenQueryWorks() throws {
        var userContext = Context()
        let users = [
            User(id: "1", username: "@alice", email: "alice@test.com"),
            User(id: "2", username: "@bob", email: "bob@test.com"),
            User(id: "3", username: "@alice_smith", email: "alice.smith@test.com")
        ]

        try users.forEach { try $0.save(to: &userContext) }

        let result = User
            .filter(\.username == "@alice")
            .resolve(in: userContext)

        #expect(result.count == 1)
        #expect(result.first?.id == "1")
    }
}
