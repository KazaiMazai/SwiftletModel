//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import XCTest

final class UniqueIndexTests: XCTestCase {
    func test_WhenThrowingCollision_ThenErrorIsThrown() throws {
        var context = Context()
        let user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        try user1.save(to: &context)
       
        let user2 = User(id: "2", username: "@bob_cat", email: "bob@mail.com")
        XCTAssertThrowsError(try user2.save(to: &context))
    }
    
    func test_WhenUpsertResolveCollision_ThenCollisionIsResolved() throws {
        var context = Context()
        let user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        try user1.save(to: &context)
       
        let user2 = User(id: "2", username: "@bob", email: "bobtwo@mail.com")
        try user2.save(to: &context)
        
        XCTAssertNil(user1.query(in: context).resolve())
        XCTAssertNotNil(user2.query(in: context).resolve())
    }
    
    func test_WhenCustomResolveCollision_ThenCollisionIsResolved() throws {
        var context = Context()
        var user1 = User(id: "1", username: "@bob", email: "bob@mail.com")
        user1.isCurrent = true
        try user1.save(to: &context)
       
        var user2 = User(id: "2", username: "@alice", email: "alice@mail.com")
        user2.isCurrent = true
        try user2.save(to: &context)
      
        XCTAssertTrue(user2.query(in: context).resolve()!.isCurrent)
        XCTAssertFalse(user1.query(in: context).resolve()!.isCurrent)
    }
}

final class CompoundUniqueIndexTests: XCTestCase {
    
    func test_WhenOneKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }
    
    func test_WhenTwoKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }

    func test_WhenThreeKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }

    func test_WhenFourKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }

    func test_WhenNoIndexUniqueIndexCollision_ThenNoError() throws {
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
        
        XCTAssertNoThrow(try model2.save(to: &context))
    }
}


final class CompoundUniqueComparableIndexTests: XCTestCase {
    
    func test_WhenOneKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }
    
    func test_WhenTwoKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }

    func test_WhenThreeKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }

    func test_WhenFourKeyPathThrowingCollision_ThenErrorIsThrown() throws {
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
        XCTAssertThrowsError(try model2.save(to: &context))
    }

    func test_WhenNoIndexUniqueIndexCollision_ThenNoError() throws {
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
        
        XCTAssertNoThrow(try model2.save(to: &context))
    }
}
