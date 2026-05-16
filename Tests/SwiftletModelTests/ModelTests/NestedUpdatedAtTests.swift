//
//  NestedUpdatedAtTests.swift
//  SwiftletModel
//
//  Created for nested Entity+Metadata accessors.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Nested updatedAt", .tags(.metadata, .relations))
struct NestedUpdatedAtTests {

    // MARK: - Relations Not Loaded

    @Test("updatedAt withNested equals own updatedAt when relations are not loaded")
    func whenRelationsNotLoaded_ThenWithNestedEqualsUpdatedAt() throws {
        var context = Context()

        let chat = Chat(id: "1", messages: .relation([
            Message(id: "m1", text: "hi", author: .relation(.bob))
        ]))
        try chat.save(to: &context)

        // Bump the nested message so the graph has a newer entity than the chat
        Thread.sleep(forTimeInterval: 0.01)
        try Message(id: "m1", text: "hi", author: .relation(.bob)).save(to: &context)

        // Resolve the chat without loading any relation
        let resolved = try #require(Chat.query("1").resolve(in: context))

        #expect(resolved.updatedAt(in: context, withNested: true) == resolved.updatedAt(in: context))
    }

    @Test("updatedAt withNested equals own updatedAt when a loaded relation is empty")
    func whenLoadedRelationIsEmpty_ThenWithNestedEqualsUpdatedAt() throws {
        var context = Context()

        let chat = Chat(id: "1", messages: .relation([]))
        try chat.save(to: &context)

        let resolved = try #require(
            Chat.query("1").with(\.$messages).resolve(in: context)
        )

        #expect(resolved.updatedAt(in: context, withNested: true) == resolved.updatedAt(in: context))
    }

    // MARK: - To-One Relation

    @Test("updatedAt withNested includes a loaded to-one relation")
    func whenToOneRelationLoaded_ThenWithNestedIncludesIt() throws {
        var context = Context()

        let message = Message(id: "m1", text: "hi", author: .relation(.bob))
        try message.save(to: &context)

        // Bump the author so it becomes the newest entity in the graph
        Thread.sleep(forTimeInterval: 0.01)
        try User.bob.save(to: &context)

        let resolved = try #require(
            Message.query("m1").with(\.$author).resolve(in: context)
        )

        let messageUpdatedAt = try #require(message.updatedAt(in: context))
        let authorUpdatedAt = try #require(User.bob.updatedAt(in: context))

        #expect(authorUpdatedAt > messageUpdatedAt)
        #expect(resolved.updatedAt(in: context, withNested: true) == authorUpdatedAt)
    }

    // MARK: - To-Many Relation

    @Test("updatedAt withNested includes the newest child of a loaded to-many relation")
    func whenToManyRelationLoaded_ThenWithNestedIncludesNewestChild() throws {
        var context = Context()

        let chat = Chat(id: "1", messages: .relation([
            Message(id: "m1", text: "one", author: .relation(.bob)),
            Message(id: "m2", text: "two", author: .relation(.alice)),
            Message(id: "m3", text: "three", author: .relation(.tom))
        ]))
        try chat.save(to: &context)

        // Bump one message so it becomes the newest entity in the graph
        Thread.sleep(forTimeInterval: 0.01)
        let bumpedMessage = Message(id: "m2", text: "two", author: .relation(.alice))
        try bumpedMessage.save(to: &context)

        let resolved = try #require(
            Chat.query("1").with(\.$messages).resolve(in: context)
        )

        let chatUpdatedAt = try #require(resolved.updatedAt(in: context))
        let bumpedUpdatedAt = try #require(bumpedMessage.updatedAt(in: context))

        #expect(bumpedUpdatedAt > chatUpdatedAt)
        #expect(resolved.updatedAt(in: context, withNested: true) == bumpedUpdatedAt)
    }

    // MARK: - Deeply Nested Relations

    @Test("updatedAt withNested traverses deeply nested loaded relations")
    func whenDeeplyNestedRelationsLoaded_ThenWithNestedReflectsDeepest() throws {
        var context = Context()

        let chat = Chat(id: "1", messages: .relation([
            Message(id: "m1", text: "one", author: .relation(.bob)),
            Message(id: "m2", text: "two", author: .relation(.alice))
        ]))
        try chat.save(to: &context)

        // Bump a deeply nested author (in the graph)...
        Thread.sleep(forTimeInterval: 0.01)
        try User.alice.save(to: &context)
        // ...then bump an entity that is NOT part of the loaded graph.
        Thread.sleep(forTimeInterval: 0.01)
        try User.tom.save(to: &context)

        let resolved = try #require(
            Chat.query("1")
                .with(\.$messages) { $0.with(\.$author) }
                .resolve(in: context)
        )

        let aliceUpdatedAt = try #require(User.alice.updatedAt(in: context))
        let tomUpdatedAt = try #require(User.tom.updatedAt(in: context))

        // Sanity: tom is the newest entity in the context, but not in the graph.
        #expect(tomUpdatedAt > aliceUpdatedAt)

        // withNested reflects the newest entity within the loaded graph only.
        #expect(resolved.updatedAt(in: context, withNested: true) == aliceUpdatedAt)
    }

    // MARK: - Root Is Newest

    @Test("updatedAt withNested equals the root's updatedAt when the root is the newest")
    func whenRootIsNewest_ThenWithNestedEqualsRoot() throws {
        var context = Context()

        let chat = Chat(id: "1", messages: .relation([
            Message(id: "m1", text: "one", author: .relation(.bob))
        ]))
        try chat.save(to: &context)

        // Re-save the chat last, relinking the message by id so it is not bumped
        Thread.sleep(forTimeInterval: 0.01)
        try Chat(id: "1", messages: .ids(["m1"])).save(to: &context)

        let resolved = try #require(
            Chat.query("1").with(\.$messages).resolve(in: context)
        )

        #expect(resolved.updatedAt(in: context, withNested: true) == resolved.updatedAt(in: context))
    }
}
