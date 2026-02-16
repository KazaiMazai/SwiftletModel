//
//  File.swift
//
//
//  Created by Serge Kazakov on 19/07/2024.
//

import Foundation
import Testing
import SwiftletModel
import SnapshotTesting

@Suite(.tags(.coding, .encoding, .decoding, .relations))
struct RelationsEncodingDecodingTests {

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

    @Test("Default coding matches expected JSON")
    func whenDefaultCoding_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .plain

        let user = User
            .query(User.bob.id)
            .with(\.$chats) {
                $0.with(\.$messages) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .id(\.$users)
                .id(\.$admins)
            }
            .resolve(in: context)

        assertSnapshot(of: user, as: .json(encoder))

        let decodedUser = try decoder.decode(
            User.self,
            from: user
                .prettyDescription(with: encoder)!
                .data(using: .utf8)!
        )

        assertSnapshot(of: decodedUser, as: .json(encoder))
    }

    @Test("Explicit coding matches expected JSON")
    func whenExplicitCoding_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .keyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .keyedContainer

        let user = User
            .query(User.bob.id)
            .with(\.$chats) {
                $0.with(\.$messages) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .id(\.$users)
                .id(\.$admins)
            }
            .resolve(in: context)

        assertSnapshot(of: user, as: .json(encoder))

        let decodedUser = try decoder.decode(
            User.self,
            from: user
                .prettyDescription(with: encoder)!
                .data(using: .utf8)!
        )

        assertSnapshot(of: decodedUser, as: .json(encoder))
    }

    @Test("Exact coding matches expected JSON")
    func whenExactCoding_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .explicitKeyedContainer

        let user = User
            .query(User.bob.id)
            .with(\.$chats) {
                $0.with(\.$messages) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .id(\.$users)
                .id(\.$admins)
            }
            .resolve(in: context)

        assertSnapshot(of: user, as: .json(encoder))

        let decodedUser = try decoder.decode(
            User.self,
            from: user
                .prettyDescription(with: encoder)!
                .data(using: .utf8)!
        )

        assertSnapshot(of: decodedUser, as: .json(encoder))
    }

    @Test("Exact encoding slice matches expected JSON")
    func whenExactEncodingSlice_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .explicitKeyedContainer

        let user = User
            .query(User.bob.id)
            .with(\.$chats) {
                $0.with(slice: \.$messages) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .id(slice: \.$users)
                .id(\.$admins)
            }
            .resolve(in: context)

        assertSnapshot(of: user, as: .json(encoder))
        let decodedUser = try decoder.decode(
            User.self,
            from: user
                .prettyDescription(with: encoder)!
                .data(using: .utf8)!
        )

        assertSnapshot(of: decodedUser, as: .json(encoder))
    }

    @Test("Explicit encoding slice matches expected JSON")
    func whenExplicitEncodingSlice_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .keyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .keyedContainer

        let user = User
            .query(User.bob.id)
            .with(\.$chats) {
                $0.with(slice: \.$messages) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .id(slice: \.$users)
                .id(\.$admins)
            }
            .resolve(in: context)

        assertSnapshot(of: user, as: .json(encoder))

        let decodedUser = try decoder.decode(
            User.self,
            from: user
                .prettyDescription(with: encoder)!
                .data(using: .utf8)!
        )

        assertSnapshot(of: decodedUser, as: .json(encoder))
    }

    @Test("Default encoding slice matches expected JSON")
    func whenDefaultEncodingSlice_EqualExpectedJSON() throws {
        let context = try makeContext()
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .plain

        let user = User
            .query(User.bob.id)
            .with(\.$chats) {
                $0.with(slice: \.$messages) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .id(slice: \.$users)
                .id(\.$admins)
            }
            .resolve(in: context)

        assertSnapshot(of: user, as: .json(encoder))

        let decodedUser = try decoder.decode(
            User.self,
            from: user
                .prettyDescription(with: encoder)!
                .data(using: .utf8)!
        )

        assertSnapshot(of: decodedUser, as: .json(encoder))
    }
}
