//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 19/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletModel
import SnapshotTesting

final class RelationEncodingTests: XCTestCase {
    var context = Context()

    override func setUpWithError() throws {
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
    }

    func test_WhenDefaultEncoding_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let user = User
            .query(User.bob.id, in: context)
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
            .resolve()

        assertSnapshot(of: user, as: .json(encoder))
    }

    func test_WhenExplicitEncoding_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .keyedContainer

        let user = User
            .query(User.bob.id, in: context)
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
            .resolve()

        assertSnapshot(of: user, as: .json(encoder))
    }

    func test_WhenExactEncoding_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let user = User
            .query(User.bob.id, in: context)
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
            .resolve()

        assertSnapshot(of: user, as: .json(encoder))
    }

    func test_WhenExactEncodingSlice_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let user = User
            .query(User.bob.id, in: context)
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
            .resolve()

        assertSnapshot(of: user, as: .json(encoder))
    }

    func test_WhenExplicitEncodingSlice_EqualExpectedJSON() {

        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .keyedContainer

        let user = User
            .query(User.bob.id, in: context)
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
            .resolve()

        assertSnapshot(of: user, as: .json(encoder))
    }

    func test_WhenDefaultEncodingSlice_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let user = User
            .query(User.bob.id, in: context)
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
            .resolve()
 
        assertSnapshot(of: user, as: .json(encoder))
    }
}
