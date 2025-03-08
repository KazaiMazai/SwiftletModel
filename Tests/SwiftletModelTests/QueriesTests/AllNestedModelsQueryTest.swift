//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation
import XCTest
@testable import SwiftletModel

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
    }

    func test_WhenQueryWithNestedEntities_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.entities)
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
            "chat" : {
              "admins" : null,
              "id" : "1",
              "messages" : null,
              "users" : null
            },
            "id" : "0",
            "replies" : [
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "1",
                "replies" : null,
                "replyTo" : null,
                "text" : "hello",
                "viewedBy" : null
              },
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "2",
                "replies" : null,
                "replyTo" : null,
                "text" : "howdy",
                "viewedBy" : null
              },
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "3",
                "replies" : null,
                "replyTo" : null,
                "text" : "yo!",
                "viewedBy" : null
              },
              {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "4",
                "replies" : null,
                "replyTo" : null,
                "text" : "wassap!",
                "viewedBy" : null
              }
            ],
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "2",
              "name" : "Alice"
            },
            "chat" : {
              "admins" : null,
              "id" : "1",
              "messages" : null,
              "users" : null
            },
            "id" : "1",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : null,
              "chat" : null,
              "id" : "0",
              "replies" : null,
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : null
            },
            "text" : "hello",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "1",
              "name" : "Bob"
            },
            "chat" : {
              "admins" : null,
              "id" : "1",
              "messages" : null,
              "users" : null
            },
            "id" : "2",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : null,
              "chat" : null,
              "id" : "0",
              "replies" : null,
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : null
            },
            "text" : "howdy",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "5",
              "name" : "Tom"
            },
            "chat" : {
              "admins" : null,
              "id" : "1",
              "messages" : null,
              "users" : null
            },
            "id" : "3",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : null,
              "chat" : null,
              "id" : "0",
              "replies" : null,
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : null
            },
            "text" : "yo!",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : null,
              "chats" : null,
              "id" : "3",
              "name" : "John"
            },
            "chat" : {
              "admins" : null,
              "id" : "1",
              "messages" : null,
              "users" : null
            },
            "id" : "4",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : null,
              "chat" : null,
              "id" : "0",
              "replies" : null,
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : null
            },
            "text" : "wassap!",
            "viewedBy" : [

            ]
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }
    
    func test_WhenQueryWithNestedFragments_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let messages = Message
            .query(in: context)
            .with(.fragments)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : null,
                "chats" : null,
                "id" : "4",
                "name" : "Michael"
              }
            },
            "chat" : {
              "object" : {
                "admins" : null,
                "id" : "1",
                "messages" : null,
                "users" : null
              }
            },
            "id" : "0",
            "replies" : {
              "objects" : [
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "1",
                  "replies" : null,
                  "replyTo" : null,
                  "text" : "hello",
                  "viewedBy" : null
                },
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "2",
                  "replies" : null,
                  "replyTo" : null,
                  "text" : "howdy",
                  "viewedBy" : null
                },
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "3",
                  "replies" : null,
                  "replyTo" : null,
                  "text" : "yo!",
                  "viewedBy" : null
                },
                {
                  "attachment" : null,
                  "author" : null,
                  "chat" : null,
                  "id" : "4",
                  "replies" : null,
                  "replyTo" : null,
                  "text" : "wassap!",
                  "viewedBy" : null
                }
              ]
            },
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : null,
                "chats" : null,
                "id" : "2",
                "name" : "Alice"
              }
            },
            "chat" : {
              "object" : {
                "admins" : null,
                "id" : "1",
                "messages" : null,
                "users" : null
              }
            },
            "id" : "1",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "0",
                "replies" : null,
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : null
              }
            },
            "text" : "hello",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : null,
                "chats" : null,
                "id" : "1",
                "name" : "Bob"
              }
            },
            "chat" : {
              "object" : {
                "admins" : null,
                "id" : "1",
                "messages" : null,
                "users" : null
              }
            },
            "id" : "2",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "0",
                "replies" : null,
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : null
              }
            },
            "text" : "howdy",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : null,
                "chats" : null,
                "id" : "5",
                "name" : "Tom"
              }
            },
            "chat" : {
              "object" : {
                "admins" : null,
                "id" : "1",
                "messages" : null,
                "users" : null
              }
            },
            "id" : "3",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "0",
                "replies" : null,
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : null
              }
            },
            "text" : "yo!",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : null,
                "chats" : null,
                "id" : "3",
                "name" : "John"
              }
            },
            "chat" : {
              "object" : {
                "admins" : null,
                "id" : "1",
                "messages" : null,
                "users" : null
              }
            },
            "id" : "4",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : null,
                "chat" : null,
                "id" : "0",
                "replies" : null,
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : null
              }
            },
            "text" : "wassap!",
            "viewedBy" : {
              "objects" : [

              ]
            }
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }


    func test_WhenQueryWithNestedIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.ids)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "id" : "4"
            },
            "chat" : {
              "id" : "1"
            },
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
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "2"
            },
            "chat" : {
              "id" : "1"
            },
            "id" : "1",
            "replies" : [

            ],
            "replyTo" : {
              "id" : "0"
            },
            "text" : "hello",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "1"
            },
            "chat" : {
              "id" : "1"
            },
            "id" : "2",
            "replies" : [

            ],
            "replyTo" : {
              "id" : "0"
            },
            "text" : "howdy",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "5"
            },
            "chat" : {
              "id" : "1"
            },
            "id" : "3",
            "replies" : [

            ],
            "replyTo" : {
              "id" : "0"
            },
            "text" : "yo!",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "id" : "3"
            },
            "chat" : {
              "id" : "1"
            },
            "id" : "4",
            "replies" : [

            ],
            "replyTo" : {
              "id" : "0"
            },
            "text" : "wassap!",
            "viewedBy" : [

            ]
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedEntitiesAndIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.entities, .ids)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
              "chats" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "4",
              "name" : "Michael"
            },
            "chat" : {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "id" : "0"
                },
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
            },
            "id" : "0",
            "replies" : [
              {
                "attachment" : null,
                "author" : {
                  "id" : "2"
                },
                "chat" : {
                  "id" : "1"
                },
                "id" : "1",
                "replies" : [

                ],
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "hello",
                "viewedBy" : [

                ]
              },
              {
                "attachment" : null,
                "author" : {
                  "id" : "1"
                },
                "chat" : {
                  "id" : "1"
                },
                "id" : "2",
                "replies" : [

                ],
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "howdy",
                "viewedBy" : [

                ]
              },
              {
                "attachment" : null,
                "author" : {
                  "id" : "5"
                },
                "chat" : {
                  "id" : "1"
                },
                "id" : "3",
                "replies" : [

                ],
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "yo!",
                "viewedBy" : [

                ]
              },
              {
                "attachment" : null,
                "author" : {
                  "id" : "3"
                },
                "chat" : {
                  "id" : "1"
                },
                "id" : "4",
                "replies" : [

                ],
                "replyTo" : {
                  "id" : "0"
                },
                "text" : "wassap!",
                "viewedBy" : [

                ]
              }
            ],
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
              "chats" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "2",
              "name" : "Alice"
            },
            "chat" : {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "id" : "0"
                },
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
            },
            "id" : "1",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "id" : "4"
              },
              "chat" : {
                "id" : "1"
              },
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
              "viewedBy" : [

              ]
            },
            "text" : "hello",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [
                {
                  "id" : "1"
                }
              ],
              "chats" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "name" : "Bob"
            },
            "chat" : {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "id" : "0"
                },
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
            },
            "id" : "2",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "id" : "4"
              },
              "chat" : {
                "id" : "1"
              },
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
              "viewedBy" : [

              ]
            },
            "text" : "howdy",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
              "chats" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "5",
              "name" : "Tom"
            },
            "chat" : {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "id" : "0"
                },
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
            },
            "id" : "3",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "id" : "4"
              },
              "chat" : {
                "id" : "1"
              },
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
              "viewedBy" : [

              ]
            },
            "text" : "yo!",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
              "chats" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "3",
              "name" : "John"
            },
            "chat" : {
              "admins" : [
                {
                  "id" : "1"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "id" : "0"
                },
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
            },
            "id" : "4",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "id" : "4"
              },
              "chat" : {
                "id" : "1"
              },
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
              "viewedBy" : [

              ]
            },
            "text" : "wassap!",
            "viewedBy" : [

            ]
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedEntitiesEntitiesAndIds_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let messages = Message
            .query(in: context)
            .with(.entities, .entities, .ids)
            .resolve()
            .sorted(by: { $0.id < $1.id})

        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
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
                      "id" : "0"
                    },
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
              "id" : "4",
              "name" : "Michael"
            },
            "chat" : {
              "admins" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "users" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "2",
                  "name" : "Alice"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "5",
                  "name" : "Tom"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "3",
                  "name" : "John"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "4",
                  "name" : "Michael"
                }
              ]
            },
            "id" : "0",
            "replies" : [
              {
                "attachment" : null,
                "author" : {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "2",
                  "name" : "Alice"
                },
                "chat" : {
                  "admins" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "messages" : [
                    {
                      "id" : "0"
                    },
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
                },
                "id" : "1",
                "replies" : [

                ],
                "replyTo" : {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                "text" : "hello",
                "viewedBy" : [

                ]
              },
              {
                "attachment" : null,
                "author" : {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                },
                "chat" : {
                  "admins" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "messages" : [
                    {
                      "id" : "0"
                    },
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
                },
                "id" : "2",
                "replies" : [

                ],
                "replyTo" : {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                "text" : "howdy",
                "viewedBy" : [

                ]
              },
              {
                "attachment" : null,
                "author" : {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "5",
                  "name" : "Tom"
                },
                "chat" : {
                  "admins" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "messages" : [
                    {
                      "id" : "0"
                    },
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
                },
                "id" : "3",
                "replies" : [

                ],
                "replyTo" : {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                "text" : "yo!",
                "viewedBy" : [

                ]
              },
              {
                "attachment" : null,
                "author" : {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "3",
                  "name" : "John"
                },
                "chat" : {
                  "admins" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "messages" : [
                    {
                      "id" : "0"
                    },
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
                },
                "id" : "4",
                "replies" : [

                ],
                "replyTo" : {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                "text" : "wassap!",
                "viewedBy" : [

                ]
              }
            ],
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
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
                      "id" : "0"
                    },
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
              "id" : "2",
              "name" : "Alice"
            },
            "chat" : {
              "admins" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "users" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "2",
                  "name" : "Alice"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "5",
                  "name" : "Tom"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "3",
                  "name" : "John"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "4",
                  "name" : "Michael"
                }
              ]
            },
            "id" : "1",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "adminOf" : [

                ],
                "chats" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "4",
                "name" : "Michael"
              },
              "chat" : {
                "admins" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "1",
                "messages" : [
                  {
                    "id" : "0"
                  },
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
              },
              "id" : "0",
              "replies" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : [

              ]
            },
            "text" : "hello",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [
                {
                  "admins" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "messages" : [
                    {
                      "id" : "0"
                    },
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
                      "id" : "0"
                    },
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
              "id" : "1",
              "name" : "Bob"
            },
            "chat" : {
              "admins" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "users" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "2",
                  "name" : "Alice"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "5",
                  "name" : "Tom"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "3",
                  "name" : "John"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "4",
                  "name" : "Michael"
                }
              ]
            },
            "id" : "2",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "adminOf" : [

                ],
                "chats" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "4",
                "name" : "Michael"
              },
              "chat" : {
                "admins" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "1",
                "messages" : [
                  {
                    "id" : "0"
                  },
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
              },
              "id" : "0",
              "replies" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : [

              ]
            },
            "text" : "howdy",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
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
                      "id" : "0"
                    },
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
              "id" : "5",
              "name" : "Tom"
            },
            "chat" : {
              "admins" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "users" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "2",
                  "name" : "Alice"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "5",
                  "name" : "Tom"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "3",
                  "name" : "John"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "4",
                  "name" : "Michael"
                }
              ]
            },
            "id" : "3",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "adminOf" : [

                ],
                "chats" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "4",
                "name" : "Michael"
              },
              "chat" : {
                "admins" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "1",
                "messages" : [
                  {
                    "id" : "0"
                  },
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
              },
              "id" : "0",
              "replies" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : [

              ]
            },
            "text" : "yo!",
            "viewedBy" : [

            ]
          },
          {
            "attachment" : null,
            "author" : {
              "adminOf" : [

              ],
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
                      "id" : "0"
                    },
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
              "id" : "3",
              "name" : "John"
            },
            "chat" : {
              "admins" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                }
              ],
              "id" : "1",
              "messages" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "4"
                  },
                  "chat" : {
                    "id" : "1"
                  },
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
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "users" : [
                {
                  "adminOf" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "1",
                  "name" : "Bob"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "2",
                  "name" : "Alice"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "5",
                  "name" : "Tom"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "3",
                  "name" : "John"
                },
                {
                  "adminOf" : [

                  ],
                  "chats" : [
                    {
                      "id" : "1"
                    }
                  ],
                  "id" : "4",
                  "name" : "Michael"
                }
              ]
            },
            "id" : "4",
            "replies" : [

            ],
            "replyTo" : {
              "attachment" : null,
              "author" : {
                "adminOf" : [

                ],
                "chats" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "4",
                "name" : "Michael"
              },
              "chat" : {
                "admins" : [
                  {
                    "id" : "1"
                  }
                ],
                "id" : "1",
                "messages" : [
                  {
                    "id" : "0"
                  },
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
              },
              "id" : "0",
              "replies" : [
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "2"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "1",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "hello",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "1"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "2",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "howdy",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "5"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "3",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "yo!",
                  "viewedBy" : [

                  ]
                },
                {
                  "attachment" : null,
                  "author" : {
                    "id" : "3"
                  },
                  "chat" : {
                    "id" : "1"
                  },
                  "id" : "4",
                  "replies" : [

                  ],
                  "replyTo" : {
                    "id" : "0"
                  },
                  "text" : "wassap!",
                  "viewedBy" : [

                  ]
                }
              ],
              "replyTo" : null,
              "text" : "hello, ya'll",
              "viewedBy" : [

              ]
            },
            "text" : "wassap!",
            "viewedBy" : [

            ]
          }
        ]
        """

        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }

    func test_WhenQueryWithNestedEntitiesAndEntitiesAndEntities_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer
        
        let messages = Message
            .query(in: context)
            .with(.entities, .entities, .entities)
            .resolve()
            .sorted(by: { $0.id < $1.id})
        
        let expectedJSON = """
        [
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : {
                  "objects" : [

                  ]
                },
                "chats" : {
                  "objects" : [
                    {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  ]
                },
                "id" : "4",
                "name" : "Michael"
              }
            },
            "chat" : {
              "object" : {
                "admins" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    }
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "users" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "2",
                      "name" : "Alice"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "5",
                      "name" : "Tom"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "3",
                      "name" : "John"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "4",
                      "name" : "Michael"
                    }
                  ]
                }
              }
            },
            "id" : "0",
            "replies" : {
              "objects" : [
                {
                  "attachment" : null,
                  "author" : {
                    "object" : {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "2",
                      "name" : "Alice"
                    }
                  },
                  "chat" : {
                    "object" : {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  },
                  "id" : "1",
                  "replies" : {
                    "objects" : [

                    ]
                  },
                  "replyTo" : {
                    "object" : {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  },
                  "text" : "hello",
                  "viewedBy" : {
                    "objects" : [

                    ]
                  }
                },
                {
                  "attachment" : null,
                  "author" : {
                    "object" : {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    }
                  },
                  "chat" : {
                    "object" : {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  },
                  "id" : "2",
                  "replies" : {
                    "objects" : [

                    ]
                  },
                  "replyTo" : {
                    "object" : {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  },
                  "text" : "howdy",
                  "viewedBy" : {
                    "objects" : [

                    ]
                  }
                },
                {
                  "attachment" : null,
                  "author" : {
                    "object" : {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "5",
                      "name" : "Tom"
                    }
                  },
                  "chat" : {
                    "object" : {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  },
                  "id" : "3",
                  "replies" : {
                    "objects" : [

                    ]
                  },
                  "replyTo" : {
                    "object" : {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  },
                  "text" : "yo!",
                  "viewedBy" : {
                    "objects" : [

                    ]
                  }
                },
                {
                  "attachment" : null,
                  "author" : {
                    "object" : {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "3",
                      "name" : "John"
                    }
                  },
                  "chat" : {
                    "object" : {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  },
                  "id" : "4",
                  "replies" : {
                    "objects" : [

                    ]
                  },
                  "replyTo" : {
                    "object" : {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  },
                  "text" : "wassap!",
                  "viewedBy" : {
                    "objects" : [

                    ]
                  }
                }
              ]
            },
            "replyTo" : null,
            "text" : "hello, ya'll",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : {
                  "objects" : [

                  ]
                },
                "chats" : {
                  "objects" : [
                    {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  ]
                },
                "id" : "2",
                "name" : "Alice"
              }
            },
            "chat" : {
              "object" : {
                "admins" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    }
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "users" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "2",
                      "name" : "Alice"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "5",
                      "name" : "Tom"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "3",
                      "name" : "John"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "4",
                      "name" : "Michael"
                    }
                  ]
                }
              }
            },
            "id" : "1",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : {
                  "object" : {
                    "adminOf" : {
                      "objects" : [

                      ]
                    },
                    "chats" : {
                      "objects" : [
                        {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      ]
                    },
                    "id" : "4",
                    "name" : "Michael"
                  }
                },
                "chat" : {
                  "object" : {
                    "admins" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      ]
                    },
                    "id" : "1",
                    "messages" : {
                      "objects" : [
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "1",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "2",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "howdy",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "3",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "yo!",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "4",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "wassap!",
                          "viewedBy" : null
                        }
                      ]
                    },
                    "users" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      ]
                    }
                  }
                },
                "id" : "0",
                "replies" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : {
                  "objects" : [

                  ]
                }
              }
            },
            "text" : "hello",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : {
                  "objects" : [
                    {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  ]
                },
                "chats" : {
                  "objects" : [
                    {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  ]
                },
                "id" : "1",
                "name" : "Bob"
              }
            },
            "chat" : {
              "object" : {
                "admins" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    }
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "users" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "2",
                      "name" : "Alice"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "5",
                      "name" : "Tom"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "3",
                      "name" : "John"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "4",
                      "name" : "Michael"
                    }
                  ]
                }
              }
            },
            "id" : "2",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : {
                  "object" : {
                    "adminOf" : {
                      "objects" : [

                      ]
                    },
                    "chats" : {
                      "objects" : [
                        {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      ]
                    },
                    "id" : "4",
                    "name" : "Michael"
                  }
                },
                "chat" : {
                  "object" : {
                    "admins" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      ]
                    },
                    "id" : "1",
                    "messages" : {
                      "objects" : [
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "1",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "2",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "howdy",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "3",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "yo!",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "4",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "wassap!",
                          "viewedBy" : null
                        }
                      ]
                    },
                    "users" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      ]
                    }
                  }
                },
                "id" : "0",
                "replies" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : {
                  "objects" : [

                  ]
                }
              }
            },
            "text" : "howdy",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : {
                  "objects" : [

                  ]
                },
                "chats" : {
                  "objects" : [
                    {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  ]
                },
                "id" : "5",
                "name" : "Tom"
              }
            },
            "chat" : {
              "object" : {
                "admins" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    }
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "users" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "2",
                      "name" : "Alice"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "5",
                      "name" : "Tom"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "3",
                      "name" : "John"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "4",
                      "name" : "Michael"
                    }
                  ]
                }
              }
            },
            "id" : "3",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : {
                  "object" : {
                    "adminOf" : {
                      "objects" : [

                      ]
                    },
                    "chats" : {
                      "objects" : [
                        {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      ]
                    },
                    "id" : "4",
                    "name" : "Michael"
                  }
                },
                "chat" : {
                  "object" : {
                    "admins" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      ]
                    },
                    "id" : "1",
                    "messages" : {
                      "objects" : [
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "1",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "2",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "howdy",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "3",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "yo!",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "4",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "wassap!",
                          "viewedBy" : null
                        }
                      ]
                    },
                    "users" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      ]
                    }
                  }
                },
                "id" : "0",
                "replies" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : {
                  "objects" : [

                  ]
                }
              }
            },
            "text" : "yo!",
            "viewedBy" : {
              "objects" : [

              ]
            }
          },
          {
            "attachment" : null,
            "author" : {
              "object" : {
                "adminOf" : {
                  "objects" : [

                  ]
                },
                "chats" : {
                  "objects" : [
                    {
                      "admins" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          }
                        ]
                      },
                      "id" : "1",
                      "messages" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "0",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello, ya'll",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "users" : {
                        "objects" : [
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "1",
                            "name" : "Bob"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "2",
                            "name" : "Alice"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "5",
                            "name" : "Tom"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "3",
                            "name" : "John"
                          },
                          {
                            "adminOf" : null,
                            "chats" : null,
                            "id" : "4",
                            "name" : "Michael"
                          }
                        ]
                      }
                    }
                  ]
                },
                "id" : "3",
                "name" : "John"
              }
            },
            "chat" : {
              "object" : {
                "admins" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    }
                  ]
                },
                "id" : "1",
                "messages" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "0",
                      "replies" : {
                        "objects" : [
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "1",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "hello",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "2",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "howdy",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "3",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "yo!",
                            "viewedBy" : null
                          },
                          {
                            "attachment" : null,
                            "author" : null,
                            "chat" : null,
                            "id" : "4",
                            "replies" : null,
                            "replyTo" : null,
                            "text" : "wassap!",
                            "viewedBy" : null
                          }
                        ]
                      },
                      "replyTo" : null,
                      "text" : "hello, ya'll",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "users" : {
                  "objects" : [
                    {
                      "adminOf" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "1",
                      "name" : "Bob"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "2",
                      "name" : "Alice"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "5",
                      "name" : "Tom"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "3",
                      "name" : "John"
                    },
                    {
                      "adminOf" : {
                        "objects" : [

                        ]
                      },
                      "chats" : {
                        "objects" : [
                          {
                            "admins" : null,
                            "id" : "1",
                            "messages" : null,
                            "users" : null
                          }
                        ]
                      },
                      "id" : "4",
                      "name" : "Michael"
                    }
                  ]
                }
              }
            },
            "id" : "4",
            "replies" : {
              "objects" : [

              ]
            },
            "replyTo" : {
              "object" : {
                "attachment" : null,
                "author" : {
                  "object" : {
                    "adminOf" : {
                      "objects" : [

                      ]
                    },
                    "chats" : {
                      "objects" : [
                        {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      ]
                    },
                    "id" : "4",
                    "name" : "Michael"
                  }
                },
                "chat" : {
                  "object" : {
                    "admins" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      ]
                    },
                    "id" : "1",
                    "messages" : {
                      "objects" : [
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "1",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "2",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "howdy",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "3",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "yo!",
                          "viewedBy" : null
                        },
                        {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "4",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "wassap!",
                          "viewedBy" : null
                        }
                      ]
                    },
                    "users" : {
                      "objects" : [
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        },
                        {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "4",
                          "name" : "Michael"
                        }
                      ]
                    }
                  }
                },
                "id" : "0",
                "replies" : {
                  "objects" : [
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "2",
                          "name" : "Alice"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "1",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "hello",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "1",
                          "name" : "Bob"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "2",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "howdy",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "5",
                          "name" : "Tom"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "3",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "yo!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    },
                    {
                      "attachment" : null,
                      "author" : {
                        "object" : {
                          "adminOf" : null,
                          "chats" : null,
                          "id" : "3",
                          "name" : "John"
                        }
                      },
                      "chat" : {
                        "object" : {
                          "admins" : null,
                          "id" : "1",
                          "messages" : null,
                          "users" : null
                        }
                      },
                      "id" : "4",
                      "replies" : {
                        "objects" : [

                        ]
                      },
                      "replyTo" : {
                        "object" : {
                          "attachment" : null,
                          "author" : null,
                          "chat" : null,
                          "id" : "0",
                          "replies" : null,
                          "replyTo" : null,
                          "text" : "hello, ya'll",
                          "viewedBy" : null
                        }
                      },
                      "text" : "wassap!",
                      "viewedBy" : {
                        "objects" : [

                        ]
                      }
                    }
                  ]
                },
                "replyTo" : null,
                "text" : "hello, ya'll",
                "viewedBy" : {
                  "objects" : [

                  ]
                }
              }
            },
            "text" : "wassap!",
            "viewedBy" : {
              "objects" : [

              ]
            }
          }
        ] 
        """
       
        let json = messages.prettyDescription(with: encoder)!
        XCTAssertEqual(json, expectedJSON)
    }
}
