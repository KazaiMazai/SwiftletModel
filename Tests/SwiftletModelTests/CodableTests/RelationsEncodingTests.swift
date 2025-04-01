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

        let expectedJSON = """
        {
          "adminOf" : null,
          "age" : 12,
          "chats" : [
            {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : {
                    "id" : "1",
                    "kind" : {
                      "file" : {
                        "url" : "http://google.com/image-1.jpg"
                      }
                    },
                    "message" : {
                      "id" : "1"
                    }
                  },
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : null,
                  "replyTo" : null,
                  "text" : "hello",
                  "viewedBy" : null
                }
              ],
              "users" : [
                {
                  "id" : "1"
                },
                {
                  "id" : "2"
                },
                {
                  "id" : "5"
                },
                {
                  "id" : "3"
                },
                {
                  "id" : "4"
                }
              ]
            }
          ],
          "email" : "bob@gmail.com",
          "id" : "1",
          "isCurrent" : false,
          "name" : "Bob",
          "username" : "@bob"
        }
        """

        let userJSON = user.prettyDescription(with: encoder) ?? ""
        XCTAssertEqual(userJSON, expectedJSON)
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


        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminOf" : null,
          "age" : 33,
          "chats" : {
            "objects" : [
              {
                "admins" : {
                  "ids" : [
                    "1"
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : {
                        "object" : {
                          "id" : "1",
                          "kind" : {
                            "file" : {
                              "url" : "http://google.com/image-1.jpg"
                            }
                          },
                          "message" : {
                            "id" : "1"
                          }
                        }
                      },
                      "author" : {
                        "id" : "2"
                      },
                      "chat" : {
                        "id" : "1"
                      },
                      "id" : "1",
                      "replies" : null,
                      "replyTo" : null,
                      "text" : "hello",
                      "viewedBy" : null
                    }
                  ]
                },
                "users" : {
                  "ids" : [
                    "1",
                    "2",
                    "5",
                    "3",
                    "4"
                  ]
                }
              }
            ]
          },
          "email" : "bob@mail.com",
          "id" : "1",
          "isCurrent" : false,
          "name" : "Bob",
          "username" : "@bob"
        }
        """

        XCTAssertEqual(userJSON, expectedJSON)
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

        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminOf" : null,
          "age" : 33,
          "chats" : {
            "objects" : [
              {
                "admins" : {
                  "ids" : [
                    "1"
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : {
                        "object" : {
                          "id" : "1",
                          "kind" : {
                            "file" : {
                              "url" : "http://google.com/image-1.jpg"
                            }
                          },
                          "message" : {
                            "id" : "1"
                          }
                        }
                      },
                      "author" : {
                        "id" : "2"
                      },
                      "chat" : {
                        "id" : "1"
                      },
                      "id" : "1",
                      "replies" : null,
                      "replyTo" : null,
                      "text" : "hello",
                      "viewedBy" : null
                    }
                  ]
                },
                "users" : {
                  "ids" : [
                    "1",
                    "2",
                    "5",
                    "3",
                    "4"
                  ]
                }
              }
            ]
          },
          "email" : "bob@mail.com",
          "id" : "1",
          "isCurrent" : false,
          "name" : "Bob",
          "username" : "@bob"
        }
        """

        XCTAssertEqual(userJSON, expectedJSON)
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

        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminOf" : null,
          "age" : 33,
          "chats" : {
            "objects" : [
              {
                "admins" : {
                  "ids" : [
                    "1"
                  ]
                },
                "id" : "1",
                "messages" : {
                  "slice" : [
                    {
                      "attachment" : {
                        "object" : {
                          "id" : "1",
                          "kind" : {
                            "file" : {
                              "url" : "http://google.com/image-1.jpg"
                            }
                          },
                          "message" : {
                            "id" : "1"
                          }
                        }
                      },
                      "author" : {
                        "id" : "2"
                      },
                      "chat" : {
                        "id" : "1"
                      },
                      "id" : "1",
                      "replies" : null,
                      "replyTo" : null,
                      "text" : "hello",
                      "viewedBy" : null
                    }
                  ]
                },
                "users" : {
                  "slice_ids" : [
                    "1",
                    "2",
                    "5",
                    "3",
                    "4"
                  ]
                }
              }
            ]
          },
          "email" : "bob@mail.com",
          "id" : "1",
          "isCurrent" : false,
          "name" : "Bob",
          "username" : "@bob"
        }
        """

        XCTAssertEqual(userJSON, expectedJSON)
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

        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminOf" : null,
          "age" : 33,
          "chats" : {
            "objects" : [
              {
                "admins" : {
                  "ids" : [
                    "1"
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : {
                        "object" : {
                          "id" : "1",
                          "kind" : {
                            "file" : {
                              "url" : "http://google.com/image-1.jpg"
                            }
                          },
                          "message" : {
                            "id" : "1"
                          }
                        }
                      },
                      "author" : {
                        "id" : "2"
                      },
                      "chat" : {
                        "id" : "1"
                      },
                      "id" : "1",
                      "replies" : null,
                      "replyTo" : null,
                      "text" : "hello",
                      "viewedBy" : null
                    }
                  ]
                },
                "users" : {
                  "ids" : [
                    "1",
                    "2",
                    "5",
                    "3",
                    "4"
                  ]
                }
              }
            ]
          },
          "email" : "bob@mail.com",
          "id" : "1",
          "isCurrent" : false,
          "name" : "Bob",
          "username" : "@bob"
        }
        """

        XCTAssertEqual(userJSON, expectedJSON)
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

        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminOf" : null,
          "age" : 33,
          "chats" : [
            {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : {
                    "id" : "1",
                    "kind" : {
                      "file" : {
                        "url" : "http://google.com/image-1.jpg"
                      }
                    },
                    "message" : {
                      "id" : "1"
                    }
                  },
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : null,
                  "replyTo" : null,
                  "text" : "hello",
                  "viewedBy" : null
                }
              ],
              "users" : [
                {
                  "id" : "1"
                },
                {
                  "id" : "2"
                },
                {
                  "id" : "5"
                },
                {
                  "id" : "3"
                },
                {
                  "id" : "4"
                }
              ]
            }
          ],
          "email" : "bob@mail.com",
          "id" : "1",
          "isCurrent" : false,
          "name" : "Bob",
          "username" : "@bob"
        }
        """

        XCTAssertEqual(userJSON, expectedJSON)
        assertSnapshot(of: user, as: .json(encoder))
    }
}
