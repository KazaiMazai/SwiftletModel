//
//  File.swift
//
//
//  Created by Serge Kazakov on 13/07/2024.
//

import Foundation
import Testing
import SwiftletModel

@Suite(.tags(.relations, .toMany, .mutual))
struct ManyToManyTests {

    @Test("Direct relation adds inverse relation")
    func whenDirectAdded_InverseIsAdded() throws {
        var context = Context()
        var chatOne = Chat.one
        chatOne.$users = .relation([.bob])
        try chatOne.save(to: &context)

        var chatTwo = Chat.two
        chatTwo.$users = .relation([.bob])
        try chatTwo.save(to: &context)

        let bobChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        #expect(bobChats.compactMap { $0.id } == [Chat.one.id, Chat.two.id])
    }

    @Test("Relation update with insert adds new relations")
    func whenRelationUpdatedWithInsert_NewRelationsInserted() throws {
        var context = Context()
        var chat = Chat.one
        chat.$users = .relation([.bob, .alice, .tom])
        try chat.save(to: &context)

        chat.$users = .appending(relation: [.john, .michael])
        try chat.save(to: &context)

        let chatUsers = Chat
            .query(Chat.one.id)
            .related(\.$users)
            .resolve(in: context)

        let expectedChatUsers = [User.bob.id, User.alice.id, User.tom.id, User.john.id, User.michael.id]

        #expect(chatUsers.compactMap { $0.id } == expectedChatUsers)
    }

    @Test("Replacing direct relation updates inverse")
    func whenDirectReplaced_InverseIsUpdated() throws {
        var context = Context()
        var chat = Chat.one
        chat.$users = .relation([.bob, .alice, .tom])
        try chat.save(to: &context)

        chat.$users = .relation([.john, .michael])
        try chat.save(to: &context)

        let bobsChats = User
            .query(User.bob.id)
            .related(\.$chats)
            .resolve(in: context)

        #expect(bobsChats.isEmpty)
    }
}
