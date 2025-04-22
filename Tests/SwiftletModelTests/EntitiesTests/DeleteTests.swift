//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 24/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletModel

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

    func test_WhenEntityIsDeleted_EntityIsRemovedFromContext() {
        try! Chat.delete(id: "1", from: &context)

        let chat = Chat
            .query("1", in: context)
            .resolve()

        XCTAssertNil(chat)

        let deletedChat = Deleted<Chat>
            .query("1", in: context)
            .resolve()

        XCTAssertNotNil(deletedChat)
    }
    
    func test_WhenSoftDeleteEntityIsSaved_EntityIsRemovedFromContext() {
        let softDeleteChat = Chat
            .query("1", in: context)
            .resolve()?
            .asDeleted(in: context)
        
        try! softDeleteChat!.save(to: &context)

        let chat = Chat
            .query("1", in: context)
            .resolve()

        XCTAssertNil(chat)
    }
    
    func test_WhenSoftDeleteEntityIsRestored_EntityIsRestoredInContext() {
        try! Chat.delete(id: "1", from: &context)
 
        try! Deleted<Chat>
            .query("1", in: context)
            .resolve()?
            .restore(in: &context)

        
        let chat = Chat
            .query("1", in: context)
            .resolve()

        XCTAssertNotNil(chat)
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

        let deletedMessage = Deleted<Message>
            .query("1", in: context)
            .resolve()

        XCTAssertNotNil(deletedMessage)

        let deletedAttachment = Deleted<Attachment>
            .query("1", in: context)
            .resolve()

        XCTAssertNotNil(deletedAttachment)
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

    func test_WhenEntityIsDetached_EntityIsNotRemovedFromContext() {
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
