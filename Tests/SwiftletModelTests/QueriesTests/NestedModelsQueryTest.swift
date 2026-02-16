//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/08/2024.
//

import Foundation
import Testing
import SwiftletModel
import SnapshotTesting

@Suite(.tags(.query, .relations))
struct NestedModelsQueryTest {

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
        return context
    }

    @Test
    func whenQueryWithNestedModel_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .with(\.$author)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedModelId_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .id(\.$author)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedModelIds_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query()
            .sorted(by: \.id)
            .id(\.$replies)
            .resolve(in: context)

        assertSnapshot(of: messages, as: .json(encoder))
    }

    @Test
    func whenQueryWithNestedModels_EqualExpectedJSON() throws {
        let context = try makeContext()
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

    @Test
    func whenQueryWithNestedModelsAndFilter_EqualExpectedJSON() throws {
        let context = try makeContext()
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

    @Test
    func whenQueryWithNestedModelsAndSort_EqualExpectedJSON() throws {
        let context = try makeContext()
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

    @Test
    func whenQueryWithNestedModelsSlice_EqualExpectedJSON() throws {
        let context = try makeContext()
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

    @Test
    func whenQueryWithNestedIdsSlice_EqualExpectedJSON() throws {
        let context = try makeContext()
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
