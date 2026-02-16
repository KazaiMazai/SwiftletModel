//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/03/2025.
//

import Foundation
import Testing
import SwiftletModel
import SnapshotTesting
import SnapshotTestingCustomDump

@Suite
struct AllNestedModelsQueryTest {

    private func makeContext() throws -> Context {
        var context = Context()
        let chat = Chat(
            id: "1",
            users: .relation([.bob, .alice, .tom, .john, .michael]),
            messages: .relation([
                Message(
                    id: "0",
                    text: "hello, ya'll",
                    author: .relation(.michael)
                ),

                Message(
                    id: "1",
                    text: "hello",
                    author: .relation(.alice),
                    replyTo: .id("0")
                ),

                Message(
                    id: "2",
                    text: "howdy",
                    author: .relation(.bob),
                    replyTo: .id("0")
                ),

                Message(
                    id: "3",
                    text: "yo!",
                    author: .relation(.tom),
                    replyTo: .id("0")
                ),

                Message(
                    id: "4",
                    text: "wassap!",
                    author: .relation(.john),
                    replyTo: .id("0")
                )
            ]),
            admins: .relation([.bob])
        )

        try chat.save(to: &context)
        try Schema().save(to: &context)
        return context
    }

    @Test
    func whenQueryWithNestedEntities_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .with(.entities)
            .resolve(in: context)
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedFragments_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query()
            .with(.fragments)
            .resolve(in: context)
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedIds_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .with(.ids)
            .resolve(in: context)
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedEntitiesAndIds_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .with(.entities, .ids)
            .resolve(in: context)
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedEntitiesEntitiesAndIds_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .with(.entities, .entities, .entities, .ids)
            .resolve(in: context)
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQuerySchemaLatestRange_IncludesEntitiesUpdatedWithinRange() throws {
        var context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        Thread.sleep(forTimeInterval: 1.0)
        let snapshotTime = Date.now
        Thread.sleep(forTimeInterval: 1.0)

        try Chat.query("1")
            .resolve(in: context)?
            .save(to: &context)

        let schema = Schema
            .fullSchemaQuery(updated: snapshotTime...Date.distantFuture)
            .resolve(in: context)

        assertSnapshot(of: schema, as: .json(encoder))
    }

    @Test
    func whenQuerySchemaOlderRange_IncludesEntitiesUpdatedWithinRange() throws {
        var context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        Thread.sleep(forTimeInterval: 1.0)
        let snapshotTime = Date.now
        Thread.sleep(forTimeInterval: 1.0)

        try Chat.query("1")
            .resolve(in: context)?
            .save(to: &context)

        let schema = Schema
            .fullSchemaQuery(updated: Date.distantPast...snapshotTime)
            .resolve(in: context)

        assertSnapshot(of: schema, as: .json(encoder))
    }

    @Test
    func whenQueryFullSchema_IncludesAllEntities() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let schema = Schema
            .fullSchemaQuery()
            .resolve(in: context)

        assertSnapshot(of: schema, as: .json(encoder))
    }

    @Test
    func whenQueryFullSchemaFragments_IncludesAllEntities() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let schema = Schema
            .fullSchemaQuery()
            .resolve(in: context)

        assertSnapshot(of: schema, as: .json(encoder))
    }
}
