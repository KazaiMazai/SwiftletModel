//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

@testable import SwiftletModel
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
