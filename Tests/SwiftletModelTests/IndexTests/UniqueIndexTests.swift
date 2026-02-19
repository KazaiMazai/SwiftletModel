//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Unique Index", .tags(.index, .uniqueIndex))
struct UniqueIndexTests {
    @Test("Throwing collision strategy throws error on duplicate")
    func whenThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        try user1.save(to: &context)

        let user2 = User(id: "2", username: "@bob_cat", email: "bob@mail.com")
        #expect(throws: (any Error).self) {
            try user2.save(to: &context)
        }
    }

    @Test("Upsert strategy resolves collision by replacing")
    func whenUpsertResolveCollision_ThenCollisionIsResolved() throws {
        var context = Context()
        let user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        try user1.save(to: &context)

        let user2 = User(id: "2", username: "@bob", email: "bobtwo@mail.com")
        try user2.save(to: &context)

        #expect(user1.query().resolve(in: context) == nil)
        #expect(user2.query().resolve(in: context) != nil)
    }

    @Test("Custom strategy resolves collision")
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

@Suite("Compound Unique Index", .tags(.index, .uniqueIndex))
struct CompoundUniqueIndexTests {

    @Test("One key path collision throws error")
    func whenOneKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueProperties(
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

    @Test("Two key path collision throws error")
    func whenTwoKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueProperties(
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

    @Test("Three key path collision throws error")
    func whenThreeKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 40
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueProperties(
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

    @Test("Four key path collision throws error")
    func whenFourKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueProperties(
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

    @Test("No collision when keys differ")
    func whenNoIndexUniqueIndexCollision_ThenNoError() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueProperties(
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

@Suite("Compound Unique Comparable Index", .tags(.index, .uniqueIndex))
struct CompoundUniqueComparableIndexTests {

    @Test("One key path comparable collision throws error")
    func whenOneKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueComparableProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueComparableProperties(
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

    @Test("Two key path comparable collision throws error")
    func whenTwoKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueComparableProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueComparableProperties(
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

    @Test("Three key path comparable collision throws error")
    func whenThreeKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueComparableProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 40
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueComparableProperties(
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

    @Test("Four key path comparable collision throws error")
    func whenFourKeyPathThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueComparableProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueComparableProperties(
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

    @Test("No comparable collision when keys differ")
    func whenNoIndexUniqueIndexCollision_ThenNoError() throws {
        var context = Context()
        let model1 = TestingModels.Indexed.ManyUniqueComparableProperties(
            id: "0",
            numOf1: 1,
            numOf10: 2,
            numOf100: 3,
            numOf1000: 4
        )
        try model1.save(to: &context)

        let model2 = TestingModels.Indexed.ManyUniqueComparableProperties(
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
