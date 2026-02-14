//
//  HashIndexTests.swift
//  SwiftletModel
//
//  Created on 13/02/2026.
//

import SwiftletModel
import Foundation
import XCTest

// MARK: - Single Property HashIndex Tests

final class HashIndexTests: XCTestCase {
    var context = Context()

    override func setUp() async throws {
        context = Context()
    }

    func test_WhenEntitySaved_ThenIndexContainsEntity() throws {
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        XCTAssertEqual(Set(result.map { $0.id }), Set(["1"]))
    }

    func test_WhenMultipleEntitiesWithSameValue_ThenAllInSameBucket() throws {
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

        XCTAssertEqual(Set(resultA.map { $0.id }), Set(["1", "2"]))
        XCTAssertEqual(Set(resultB.map { $0.id }), Set(["3"]))
    }

    func test_WhenEntityValueUpdated_ThenBucketMigration() throws {
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

        XCTAssertTrue(resultA.isEmpty, "Entity should no longer be in bucket A")
        XCTAssertEqual(Set(resultB.map { $0.id }), Set(["1"]))
    }

    func test_WhenEntitySavedWithSameValue_ThenNoRedundantUpdate() throws {
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try entity.save(to: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        XCTAssertEqual(result.count, 1, "Should still have exactly one entity")
        XCTAssertEqual(result.first?.id, "1")
    }

    func test_WhenEntityDeleted_ThenRemovedFromIndex() throws {
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try TestingModels.HashIndexed.delete(id: "1", from: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        XCTAssertTrue(result.isEmpty)
    }

    func test_WhenOneOfMultipleEntitiesDeleted_ThenOthersRemainInIndex() throws {
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

        XCTAssertEqual(Set(result.map { $0.id }), Set(["2", "3"]),
            "Deleting one entity should not remove others with same indexed value")
    }

    func test_WhenLastEntityInBucketDeleted_ThenBucketCleanup() throws {
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)
        try TestingModels.HashIndexed.delete(id: "1", from: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        XCTAssertTrue(result.isEmpty)
    }

    func test_WhenFilterByNonExistentValue_ThenReturnsEmpty() throws {
        let entity = TestingModels.HashIndexed(id: "1", category: "A", value: 10)
        try entity.save(to: &context)

        let result = TestingModels.HashIndexed
            .filter(\.category == "Z")
            .resolve(in: context)

        XCTAssertTrue(result.isEmpty)
    }
}

// MARK: - Compound HashIndex Tests

final class CompoundHashIndexTests: XCTestCase {
    var context = Context()

    override func setUp() async throws {
        context = Context()
    }

    // MARK: - Pair (Two Properties) Tests

    func test_WhenPairIndex_ThenBothPropertiesMustMatch() throws {
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

        XCTAssertEqual(Set(result.map { $0.id }), Set(["1"]))
    }

    func test_WhenPairIndexValueUpdated_ThenMigratesToNewBucket() throws {
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

        XCTAssertTrue(oldResult.isEmpty)
        XCTAssertEqual(Set(newResult.map { $0.id }), Set(["1"]))
    }

    // MARK: - Triplet (Three Properties) Tests

    func test_WhenTripletIndex_ThenAllThreeMatch() throws {
        let entity = TestingModels.HashIndexedTriplet(
            id: "1", region: "US", category: "Tech", subcategory: "Software"
        )
        try entity.save(to: &context)

        let result = TestingModels.HashIndexedTriplet
            .filter(\.region == "US")
            .filter(\.category == "Tech")
            .filter(\.subcategory == "Software")
            .resolve(in: context)

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    // MARK: - Quadruple (Four Properties) Tests

    func test_WhenQuadrupleIndex_ThenAllFourMatch() throws {
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

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }

    func test_WhenQuadruplePartialMatch_ThenNoResults() throws {
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

        XCTAssertTrue(result.isEmpty)
    }
}

// MARK: - HashIndex Query Integration Tests

final class HashIndexQueryTests: XCTestCase {
    let count = 100
    var context = Context()
    var models: [TestingModels.HashIndexed] = []

    override func setUp() async throws {
        context = Context()
        models = TestingModels.HashIndexed.shuffled(count)
        try models.forEach { try $0.save(to: &context) }
    }

    func test_WhenHashIndexedVsPlainFilter_ThenSameResults() throws {
        let expected = models.filter { $0.category == "A" }

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .resolve(in: context)

        XCTAssertEqual(Set(result.map { $0.id }), Set(expected.map { $0.id }))
    }

    func test_WhenOrPredicateWithHashIndex_ThenCorrectResults() throws {
        let expected = models.filter { $0.category == "A" || $0.category == "B" }

        let result = TestingModels.HashIndexed
            .filter(\.category == "A")
            .or(.filter(\.category == "B"))
            .resolve(in: context)

        XCTAssertEqual(Set(result.map { $0.id }), Set(expected.map { $0.id }))
    }

    func test_WhenExistingUserModelHashIndex_ThenQueryWorks() throws {
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

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.id, "1")
    }
}
