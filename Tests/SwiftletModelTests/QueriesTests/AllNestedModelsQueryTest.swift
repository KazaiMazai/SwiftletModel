//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation
import XCTest
@testable import SwiftletModel
import SnapshotTesting
import SnapshotTestingCustomDump

final class AllNestedModelsQueryTest: XCTestCase {
    var context = Context()
     
    override func setUpWithError() throws {
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
    }

    func test_WhenQueryWithNestedEntities_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.entities)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }
    
    func test_WhenQueryWithNestedFragments_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query(in: context)
            .with(.fragments)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.ids)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedEntitiesAndIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.entities, .ids)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedEntitiesEntitiesAndIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.entities, .entities, .entities, .ids)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }
    
    func test_WhenQuerySchemaLatestRange_IncludesEntitiesUpdatedWithinRange() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        Thread.sleep(forTimeInterval: 1.0)
        let snapshotTime = Date.now
        Thread.sleep(forTimeInterval: 1.0)

        try! Chat.query("1", in: context)
            .resolve()?
            .save(to: &context)
        
        let schema = Schema
            .fullSchemaQuery(updated: snapshotTime...Date.distantFuture, in: context)
            .resolve()
        
        assertSnapshot(of: schema, as: .json(encoder))
    }
    
    func test_WhenQuerySchemaOlderRange_IncludesEntitiesUpdatedWithinRange() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        Thread.sleep(forTimeInterval: 1.0)
        let snapshotTime = Date.now
        Thread.sleep(forTimeInterval: 1.0)

        try! Chat.query("1", in: context)
            .resolve()?
            .save(to: &context)
        
        
        let schema = Schema
            .fullSchemaQuery(updated: Date.distantPast...snapshotTime, in: context)
            .resolve()

        assertSnapshot(of: schema, as: .json(encoder))
    }
 
}
