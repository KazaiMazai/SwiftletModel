//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite
struct UniqueIndexTests {
    @Test
    func whenThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        try user1.save(to: &context)

        let user2 = User(id: "2", username: "@bob_cat", email: "bob@mail.com")
        #expect(throws: (any Error).self) {
            try user2.save(to: &context)
        }
    }

    @Test
    func whenUpsertResolveCollision_ThenCollisionIsResolved() throws {
        var context = Context()
        let user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        try user1.save(to: &context)

        let user2 = User(id: "2", username: "@bob", email: "bobtwo@mail.com")
        try user2.save(to: &context)

        #expect(user1.query().resolve(in: context) == nil)
        #expect(user2.query().resolve(in: context) != nil)
    }

    @Test
    func whenCustomResolveCollision_ThenCollisionIsResolved() throws {
        var context = Context()
        var user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        user1.isCurrent = true
        try user1.save(to: &context)

        var user2 = User(id: "2", username: "@alice", email: "alice@mail.com")
        user2.isCurrent = true
        try user2.save(to: &context)

        #expect(user2.query().resolve(in: context)!.isCurrent)
        #expect(!user1.query().resolve(in: context)!.isCurrent)
    }
}

@Suite
struct CompoundUniqueIndexTests {

    @Test
    func whenOneKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexed(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexed(
            id: "1",
            numOf1: 1,
            numOf10: 20,
            numOf100: 30,
            numOf1000: 40
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenTwoKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexed(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexed(
            id: "1",
            numOf1: 1,
            numOf10: 2,
            numOf100: 30,
            numOf1000: 40
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenThreeKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexed(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 40
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexed(
            id: "1",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 40
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenFourKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexed(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexed(
            id: "1",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenNoIndexUniqueIndexCollision_ThenNoError() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexed(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexed(
            id: "1",
            numOf1: 10,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )

        #expect(throws: Never.self) {
            try model2.save(to: &context)
        }
    }
}

@Suite
struct CompoundUniqueComparableIndexTests {

    @Test
    func whenOneKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexedComparable(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexedComparable(
            id: "1",
            numOf1: 1,
            numOf10: 20,
            numOf100: 30,
            numOf1000: 40
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenTwoKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexedComparable(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexedComparable(
            id: "1",
            numOf1: 1,
            numOf10: 2,
            numOf100: 30,
            numOf1000: 40
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenThreeKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexedComparable(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 40
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexedComparable(
            id: "1",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 40
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenFourKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexedComparable(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexedComparable(
            id: "1",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        #expect(throws: (any Error).self) {
            try model2.save(to: &context)
        }
    }

    @Test
    func whenNoIndexUniqueIndexCollision_ThenNoError() throws {
        var context = Context()
        let model1 = TestingModels.UniquelyIndexedComparable(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.UniquelyIndexedComparable(
            id: "1",
            numOf1: 10,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )

        #expect(throws: Never.self) {
            try model2.save(to: &context)
        }
    }
}
