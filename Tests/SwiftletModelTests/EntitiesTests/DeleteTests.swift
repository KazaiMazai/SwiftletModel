//
//  File.swift
//  
//
//  Created by Serge Kazakov on 24/07/2024.
//

import Foundation
import XCTest
import SwiftletModel

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
            .query("1")
            .resolve(in: context)

        XCTAssertNil(chat)

        let deletedChat = Deleted<Chat>
            .query("1")
            .resolve(in: context)

        XCTAssertNotNil(deletedChat)
    }

    func test_WhenSoftDeleteEntityIsSaved_EntityIsRemovedFromContext() {
        let softDeleteChat = Chat
            .query("1")
            .resolve(in: context)?
            .asDeleted(in: context)

        try! softDeleteChat!.save(to: &context)

        let chat = Chat
            .query("1")
            .resolve(in: context)

        XCTAssertNil(chat)
    }

    func test_WhenSoftDeleteEntityIsRestored_EntityIsRestoredInContext() {
        try! Chat.delete(id: "1", from: &context)

        try! Deleted<Chat>
            .query("1")
            .resolve(in: context)?
            .restore(in: &context)

        let chat = Chat
            .query("1")
            .resolve(in: context)

        XCTAssertNotNil(chat)
    }

    func test_WhenEntityIsDeleted_EntityIsRemovedFromRelations() {
        try! Chat.delete(id: "1", from: &context)

        let userChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        XCTAssertTrue(userChats.isEmpty)
    }

    func test_WhenEntityIsDeleted_CascadeDeleteIsFullfilled() {
        try! Chat.delete(id: "1", from: &context)

        let message = Message
            .query("1")
            .resolve(in: context)

        let attachment = Attachment
            .query("1")
            .resolve(in: context)

        XCTAssertNil(message)
        XCTAssertNil(attachment)

        let deletedMessage = Deleted<Message>
            .query("1")
            .resolve(in: context)

        XCTAssertNotNil(deletedMessage)

        let deletedAttachment = Deleted<Attachment>
            .query("1")
            .resolve(in: context)

        XCTAssertNotNil(deletedAttachment)
    }

    func test_WhenEntityIsDetached_EntityIsRemovedFromRelations() {
        let chat = Chat
            .query("1")
            .resolve(in: context)!

        try! chat.detach(\.$users, inverse: \.$chats, in: &context)

        let userChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        XCTAssertTrue(userChats.isEmpty)
    }

    func test_WhenEntityIsDetached_EntityIsNotRemovedFromContext() {
        let chat = Chat
            .query("1")
            .resolve(in: context)!

        try! chat.detach(\.$users, inverse: \.$chats, in: &context)

        let user = User
            .query(User.bob.id)
            .resolve(in: context)

        XCTAssertNotNil(user)
    }

    func test_WhenEntityIsDetachedFromOneWayRelation_EntityIsRemovedFromRelations() {
        let message = Message
            .query("1")
            .resolve(in: context)!

        try! message.detach(\.$author, in: &context)

        let refetchedMessage = Message
            .query("1")
            .with(\.$author)
            .resolve(in: context)!

        XCTAssertNil(refetchedMessage.author)
    }
}
