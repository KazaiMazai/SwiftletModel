//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/08/2024.
//

import Foundation
import XCTest
@testable import SwiftletModel
import SnapshotTesting


final class NestedModelsQueryTest: XCTestCase {
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
    }

    func test_WhenQueryWithNestedModel_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain
        
        let messages = Message
            .query(in: context)
            .with(\.$author)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
        
    }

    func test_WhenQueryWithNestedModelId_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .id(\.$author)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .id(\.$replies)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModels_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(\.$replies) {
                $0.id(\.$replyTo)
            }
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelsSlice_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query(in: context)
            .with(slice: \.$replies) {
                $0.id(\.$replyTo)
            }
            .resolve()
            .sorted(by: { $0.id < $1.id})

        
        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedIdsSlice_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query(in: context)
            .id(slice: \.$replies)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        assertSnapshot(of: messages, as: .json(encoder))
    }
}

