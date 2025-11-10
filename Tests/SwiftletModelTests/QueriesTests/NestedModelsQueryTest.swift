//
//  File.swift
//  
//
//  Created by Serge Kazakov on 02/08/2024.
//

import Foundation
import XCTest
import SwiftletModel
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
            .query()
            .sorted(by: \.id)
            .with(\.$author)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelId_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .id(\.$author)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .id(\.$replies)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModels_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .with(\.$replies) { replies in
                replies
                    .sorted(by: \.text.count)
                    .filter(\.text.count > 3)
                    .id(\.$replyTo)
            }
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelsAndFilter_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .with(\.$replies) { replies in
                replies
                    .sorted(by: \.text.count)
                    .filter(\.text.count > 5)
                    .id(\.$replyTo)
            }
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelsAndSort_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .with(\.$replies) { replies in
                replies
                    .sorted(by: \.text.count)
                    .id(\.$replyTo)
            }
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedModelsSlice_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query()
            .sorted(by: \.id)
            .with(slice: \.$replies) {
                $0.id(\.$replyTo)
            }
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    func test_WhenQueryWithNestedIdsSlice_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query()
            .sorted(by: \.id)
            .id(slice: \.$replies)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }
}
