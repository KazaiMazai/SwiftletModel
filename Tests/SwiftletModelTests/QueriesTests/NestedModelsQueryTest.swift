//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/08/2024.
//

import Foundation
import XCTest
@testable import SwiftletModel

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
                    replyTo: .relation(id: "0")
                ),

                Message(
                    id: "2",
                    text: "howdy",
                    author: .relation(.bob),
                    replyTo: .relation(id: "0")
                ),

                Message(
                    id: "3",
                    text: "yo!",
                    author: .relation(.tom),
                    replyTo: .relation(id: "0")
                ),

                Message(
                    id: "4",
                    text: "wassap!",
                    author: .relation(.john),
                    replyTo: .relation(id: "0")
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

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "4",
              "name" : "Michael"
            },
            "chat" : null,
            "id" : "0",
            "replies" : null,
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "2",
              "name" : "Alice"
            },
            "chat" : null,
            "id" : "1",
            "replies" : null,
            "replyTo" : null,
            "text" : "hello",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "1",
              "name" : "Bob"
            },
            "chat" : null,
            "id" : "2",
            "replies" : null,
            "replyTo" : null,
            "text" : "howdy",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "5",
              "name" : "Tom"
            },
            "chat" : null,
            "id" : "3",
            "replies" : null,
            "replyTo" : null,
            "text" : "yo!",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "3",
              "name" : "John"
            },
            "chat" : null,
            "id" : "4",
            "replies" : null,
            "replyTo" : null,
            "text" : "wassap!",
            "viewedBy" : null
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedModelId_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .id(\.$author)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "id" : "4"
            },
            "chat" : null,
            "id" : "0",
            "replies" : null,
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "2"
            },
            "chat" : null,
            "id" : "1",
            "replies" : null,
            "replyTo" : null,
            "text" : "hello",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "1"
            },
            "chat" : null,
            "id" : "2",
            "replies" : null,
            "replyTo" : null,
            "text" : "howdy",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "5"
            },
            "chat" : null,
            "id" : "3",
            "replies" : null,
            "replyTo" : null,
            "text" : "yo!",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "3"
            },
            "chat" : null,
            "id" : "4",
            "replies" : null,
            "replyTo" : null,
            "text" : "wassap!",
            "viewedBy" : null
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedModelIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .id(\.$replies)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "0",
            "replies" : [
              {
                "id" : "1"
              },
              {
                "id" : "2"
              },
              {
                "id" : "3"
              },
              {
                "id" : "4"
              }
            ],
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "1",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "hello",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "2",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "howdy",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "3",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "yo!",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "4",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "wassap!",
            "viewedBy" : null
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
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

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "0",
            "replies" : [
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "1",
                "replies" : null,
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "hello",
                "viewedBy" : null
              },
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "2",
                "replies" : null,
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "howdy",
                "viewedBy" : null
              },
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "3",
                "replies" : null,
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "yo!",
                "viewedBy" : null
              },
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "4",
                "replies" : null,
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "wassap!",
                "viewedBy" : null
              }
            ],
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "1",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "hello",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "2",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "howdy",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "3",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "yo!",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "4",
            "replies" : [

            ],
            "replyTo" : null,
            "text" : "wassap!",
            "viewedBy" : null
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedModelsFragment_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query(in: context)
            .with(fragment: \.$replies) {
                $0.id(\.$replyTo)
            }
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "0",
            "replies" : {
              "fragment" : [
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "1",
                  "replies" : null,
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : null
                },
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "2",
                  "replies" : null,
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : null
                },
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "3",
                  "replies" : null,
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : null
                },
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "4",
                  "replies" : null,
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : null
                }
              ]
            },
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "1",
            "replies" : {
              "fragment" : [

              ]
            },
            "replyTo" : null,
            "text" : "hello",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "2",
            "replies" : {
              "fragment" : [

              ]
            },
            "replyTo" : null,
            "text" : "howdy",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "3",
            "replies" : {
              "fragment" : [

              ]
            },
            "replyTo" : null,
            "text" : "yo!",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "4",
            "replies" : {
              "fragment" : [

              ]
            },
            "replyTo" : null,
            "text" : "wassap!",
            "viewedBy" : null
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedIdsFragment_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query(in: context)
            .id(fragment: \.$replies)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "0",
            "replies" : {
              "fragment_ids" : [
                "1",
                "2",
                "3",
                "4"
              ]
            },
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "1",
            "replies" : {
              "fragment_ids" : [

              ]
            },
            "replyTo" : null,
            "text" : "hello",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "2",
            "replies" : {
              "fragment_ids" : [

              ]
            },
            "replyTo" : null,
            "text" : "howdy",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "3",
            "replies" : {
              "fragment_ids" : [

              ]
            },
            "replyTo" : null,
            "text" : "yo!",
            "viewedBy" : null
          },
          {
            "attachment" : null,
            "author" : null,
            "chat" : null,
            "id" : "4",
            "replies" : {
              "fragment_ids" : [

              ]
            },
            "replyTo" : null,
            "text" : "wassap!",
            "viewedBy" : null
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }
}
