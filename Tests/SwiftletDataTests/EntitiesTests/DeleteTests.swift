//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletData

final class DeleteTests: XCTestCase {
    var context = Context()
    
    override func setUpWithError() throws {
        let chat = Chat(
            id: "1",
            users: .relation([.bob, .alice, .tom, .john, .michael]),
            messages: .relation([
                Message(
                    id: "1",
                    text: "hello",
                    author: .relation(.alice),
                    attachment: .relation(.imageOne)
                )
            ]),
            admins: .relation([.bob])
        )
        
        try chat.save(to: &context)
    }
    
    func test_WhenEntityIsDeleted_EntityIsRemovedFromRepository() {
        try! Chat.delete(id: "1", from: &context)
         
        let chatInRepository = Chat
            .query("1", in: context)
            .resolve()
        
        XCTAssertNil(chatInRepository)
    }
    
    func test_WhenEntityIsDeleted_EntityIsRemovedFromRelations() {
        try! Chat.delete(id: "1", from: &context)
        
        let userChats = User
            .query(User.bob.id, in: context)
            .related(\.$chats)
            .resolve()
        
        XCTAssertTrue(userChats.isEmpty)
    }
    
    func test_WhenEntityIsDeleted_CascadeDeleteIsFullfilled() {
        try! Chat.delete(id: "1", from: &context)
        
        let message = Message
            .query("1", in: context)
            .resolve()
    
        let attachment = Attachment
            .query("1", in: context)
            .resolve()
        
        XCTAssertNil(message)
        XCTAssertNil(attachment)
    }
    
    func test_WhenEntityIsDetached_EntityIsRemovedFromRelations() {
        let chat = Chat
            .query("1", in: context)
            .resolve()!
        
        chat.detach(\.$users, inverse: \.$chats, in: &context)
        
        let userChats = User
            .query(User.bob.id, in: context)
            .related(\.$chats)
            .resolve()
        
        XCTAssertTrue(userChats.isEmpty)
    }
    
    func test_WhenEntityIsDetached_EntityIsNotRemovedFromRepository() {
        let chat = Chat
            .query("1", in: context)
            .resolve()!
        
        chat.detach(\.$users, inverse: \.$chats, in: &context)
        
        let user = User
            .query(User.bob.id, in: context)
            .resolve()
        
        XCTAssertNotNil(user)
    }
    
    func test_WhenEntityIsDetachedFromOneWayRelation_EntityIsRemovedFromRelations() {
        let message = Message
            .query("1", in: context)
            .resolve()!
        
        message.detach(\.$author, in: &context)
        
        let refetchedMessage = Message
            .query("1", in: context)
            .with(\.$author)
            .resolve()!
        
        XCTAssertNil(refetchedMessage.author)
    }
}
