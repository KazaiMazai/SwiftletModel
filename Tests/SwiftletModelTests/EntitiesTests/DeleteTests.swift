//
//  File.swift
//
//
//  Created by Serge Kazakov on 24/07/2024.
//

import Foundation
import Testing
import SwiftletModel

@Suite(.tags(.delete, .relations))
struct DeleteTests {

    private func makeContext() throws -> Context {
        var context = Context()
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
        return context
    }

    @Test("Deleted entity is removed from context")
    func whenEntityIsDeleted_EntityIsRemovedFromContext() throws {
        var context = try makeContext()
        try Chat.delete(id: "1", from: &context)

        let chat = Chat
            .query("1")
            .resolve(in: context)

        #expect(chat == nil)

        let deletedChat = Deleted<Chat>
            .query("1")
            .resolve(in: context)

        #expect(deletedChat != nil)
    }

    @Test("Soft deleted entity is removed from context")
    func whenSoftDeleteEntityIsSaved_EntityIsRemovedFromContext() throws {
        var context = try makeContext()
        let softDeleteChat = Chat
            .query("1")
            .resolve(in: context)?
            .asDeleted(in: context)

        try softDeleteChat!.save(to: &context)

        let chat = Chat
            .query("1")
            .resolve(in: context)

        #expect(chat == nil)
    }

    @Test("Soft deleted entity can be restored")
    func whenSoftDeleteEntityIsRestored_EntityIsRestoredInContext() throws {
        var context = try makeContext()
        try Chat.delete(id: "1", from: &context)

        try Deleted<Chat>
            .query("1")
            .resolve(in: context)?
            .restore(in: &context)

        let chat = Chat
            .query("1")
            .resolve(in: context)

        #expect(chat != nil)
    }

    @Test("Deleted entity is removed from relations")
    func whenEntityIsDeleted_EntityIsRemovedFromRelations() throws {
        var context = try makeContext()
        try Chat.delete(id: "1", from: &context)

        let userChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        #expect(userChats.isEmpty)
    }

    @Test("Cascade delete removes related entities")
    func whenEntityIsDeleted_CascadeDeleteIsFullfilled() throws {
        var context = try makeContext()
        try Chat.delete(id: "1", from: &context)

        let message = Message
            .query("1")
            .resolve(in: context)

        let attachment = Attachment
            .query("1")
            .resolve(in: context)

        #expect(message == nil)
        #expect(attachment == nil)

        let deletedMessage = Deleted<Message>
            .query("1")
            .resolve(in: context)

        #expect(deletedMessage != nil)

        let deletedAttachment = Deleted<Attachment>
            .query("1")
            .resolve(in: context)

        #expect(deletedAttachment != nil)
    }

    @Test("Detached entity is removed from relations")
    func whenEntityIsDetached_EntityIsRemovedFromRelations() throws {
        var context = try makeContext()
        let chat = Chat
            .query("1")
            .resolve(in: context)!

        try chat.detach(\.$users, inverse: \.$chats, in: &context)

        let userChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        #expect(userChats.isEmpty)
    }

    @Test("Detached entity remains in context")
    func whenEntityIsDetached_EntityIsNotRemovedFromContext() throws {
        var context = try makeContext()
        let chat = Chat
            .query("1")
            .resolve(in: context)!

        try chat.detach(\.$users, inverse: \.$chats, in: &context)

        let user = User
            .query(User.bob.id)
            .resolve(in: context)

        #expect(user != nil)
    }

    @Test("Detaching from one-way relation removes entity from relation")
    func whenEntityIsDetachedFromOneWayRelation_EntityIsRemovedFromRelations() throws {
        var context = try makeContext()
        let message = Message
            .query("1")
            .resolve(in: context)!

        try message.detach(\.$author, in: &context)

        let refetchedMessage = Message
            .query("1")
            .with(\.$author)
            .resolve(in: context)!

        #expect(refetchedMessage.author == nil)
    }
}
