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

    @Test
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

    @Test
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

    @Test
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

    @Test
    func whenEntityIsDeleted_EntityIsRemovedFromRelations() throws {
        var context = try makeContext()
        try Chat.delete(id: "1", from: &context)

        let userChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        #expect(userChats.isEmpty)
    }

    @Test
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

    @Test
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

    @Test
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

    @Test
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
