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

@Suite(.tags(.query, .filter, .index, .hashIndex))
struct HashIndexTests {

    @Test
    func whenEntitySaved_ThenIndexContainsEntity() throws {
        var context = Context()
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(["1"]))
    }

    @Test
    func whenMultipleEntitiesWithSameValue_ThenAllInSameBucket() throws {
        var context = Context()
        let entities = [
            TestingModels.HashIndexed(id: "1", category: "A", value: 10),
            TestingModels.HashIndexed(id: "2", category: "A", value: 20),
            TestingModels.HashIndexed(id: "3", category: "B", value: 30)
        ]

        try entities.forEach { try $0.save(to: &context) }

        let resultA = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        let resultB = TestingModels.HashIndexed
            .filter(\.category == "B")
            .resolve(in: context)

        #expect(Set(resultA.map { $0.id }) == Set(["1", "2"]))
        #expect(Set(resultB.map { $0.id }) == Set(["3"]))
    }

    @Test
    func whenEntityValueUpdated_ThenBucketMigration() throws {
        var context = Context()
        var entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        entity = TestingModels.HashIndexed(id: "1", category: "B", value: 10)
        try entity.save(to: &context)

        let resultA = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        let resultB = TestingModels.HashIndexed
            .filter(\.category == "B")
            .resolve(in: context)

        #expect(resultA.isEmpty, "Entity should no longer be in bucket A")
        #expect(Set(resultB.map { $0.id }) == Set(["1"]))
    }

    @Test
    func whenEntitySavedWithSameValue_ThenNoRedundantUpdate() throws {
        var context = Context()
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try entity.save(to: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(result.count == 1, "Should still have exactly one entity")
        #expect(result.first?.id == "1")
    }

    @Test
    func whenEntityDeleted_ThenRemovedFromIndex() throws {
        var context = Context()
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try TestingModels.HashIndexed.delete(id: "1", from: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(result.isEmpty)
    }

    @Test
    func whenOneOfMultipleEntitiesDeleted_ThenOthersRemainInIndex() throws {
        var context = Context()
        let entities = [
            TestingModels.HashIndexed(id: "1", category: "A", value: 10),
            TestingModels.HashIndexed(id: "2", category: "A", value: 20),
            TestingModels.HashIndexed(id: "3", category: "A", value: 30)
        ]
        try entities.forEach { try $0.save(to: &context) }

        try TestingModels.HashIndexed.delete(id: "1", from: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(["2", "3"]),
            "Deleting one entity should not remove others with same indexed value")
    }

    @Test
    func whenLastEntityInBucketDeleted_ThenBucketCleanup() throws {
        var context = Context()
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try TestingModels.HashIndexed.delete(id: "1", from: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(result.isEmpty)
    }

    @Test
    func whenFilterByNonExistentValue_ThenReturnsEmpty() throws {
        var context = Context()
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "Z")
            .resolve(in: context)

        #expect(result.isEmpty)
    }
}

// MARK: - Compound HashIndex Tests

@Suite(.tags(.query, .filter, .index, .hashIndex))
struct CompoundHashIndexTests {

    // MARK: - Pair (Two Properties) Tests

    @Test
    func whenPairIndex_ThenBothPropertiesMustMatch() throws {
        var context = Context()
        let entities = [
            TestingModels.HashIndexedPair(id: "1", category: "A", subcategory: "X", value: 10),
            TestingModels.HashIndexedPair(id: "2", category: "A", subcategory: "Y", value: 20),
            TestingModels.HashIndexedPair(id: "3", category: "B", subcategory: "X", value: 30)
        ]

        try entities.forEach { try $0.save(to: &context) }

        let result = TestingModels.HashIndexedPair
            .filter(\.category == "A")
            .filter(\.subcategory == "X")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(["1"]))
    }

    @Test
    func whenPairIndexValueUpdated_ThenMigratesToNewBucket() throws {
        var context = Context()
        var entity = TestingModels.HashIndexedPair(
            id: "1", category: "A", subcategory: "X", value: 10
        )
        try entity.save(to: &context)

        entity = TestingModels.HashIndexedPair(
            id: "1", category: "A", subcategory: "Y", value: 10
        )
        try entity.save(to: &context)

        let oldResult = TestingModels.HashIndexedPair
            .filter(\.category == "A")
            .filter(\.subcategory == "X")
            .resolve(in: context)

        let newResult = TestingModels.HashIndexedPair
            .filter(\.category == "A")
            .filter(\.subcategory == "Y")
            .resolve(in: context)

        #expect(oldResult.isEmpty)
        #expect(Set(newResult.map { $0.id }) == Set(["1"]))
    }

    // MARK: - Triplet (Three Properties) Tests

    @Test
    func whenTripletIndex_ThenAllThreeMatch() throws {
        var context = Context()
        let entity = TestingModels.HashIndexedTriplet(
            id: "1", region: "US", category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.HashIndexedTriplet
            .filter(\.region == "US")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        #expect(result.count == 1)
        #expect(result.first?.id == "1")
    }

    // MARK: - Quadruple (Four Properties) Tests

    @Test
    func whenQuadrupleIndex_ThenAllFourMatch() throws {
        var context = Context()
        let entity = TestingModels.HashIndexedQuadruple(
            id: "1", region: "Americas", country: "US",
            category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.HashIndexedQuadruple
            .filter(\.region == "Americas")
            .filter(\.country == "US")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        #expect(result.count == 1)
        #expect(result.first?.id == "1")
    }

    @Test
    func whenQuadruplePartialMatch_ThenNoResults() throws {
        var context = Context()
        let entity = TestingModels.HashIndexedQuadruple(
            id: "1", region: "Americas", country: "US",
            category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.HashIndexedQuadruple
            .filter(\.region == "Americas")
            .filter(\.country == "Canada")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        #expect(result.isEmpty)
    }
}

// MARK: - HashIndex Query Integration Tests

@Suite(.tags(.query, .filter, .index, .hashIndex))
struct HashIndexQueryTests {
    let count = 100

    private func makeContext() throws -> (context: Context, models: [TestingModels.HashIndexed]) {
        var context = Context()
        let models = TestingModels.HashIndexed.shuffled(count)
        try models.forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test
    func whenHashIndexedVsPlainFilter_ThenSameResults() throws {
        let (context, models) = try makeContext()
        let expected = models.filter { $0.category == "A" }

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test
    func whenOrPredicateWithHashIndex_ThenCorrectResults() throws {
        let (context, models) = try makeContext()
        let expected = models.filter { $0.category == "A" || $0.category == "B" }

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .or(.filter(\.category == "B"))
            .resolve(in: context)

        #expect(Set(result.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test
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
