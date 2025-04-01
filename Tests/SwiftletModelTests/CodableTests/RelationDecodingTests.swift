//
//  File.swift
//
//
//  Created by Sergey Kazakov on 22/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletModel

final class RelationDecodingTests: XCTestCase {
    func test_WhenDefaultDecoding_EqualExpectedJSON() {
        let userInputJSON = """
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

        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .plain

        let data = userInputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)

        let userJSON = user.prettyDescription(with: encoder)!
        XCTAssertEqual(userJSON, userInputJSON)
        
        
    }

    func test_WhenExplicitDecoding_EqualExpectedJSON() {
        let userInputJSON = """
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
          "id" : "1",
          "name" : "Bob"
        }
        """

        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .keyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .keyedContainer

        let data = userInputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)

        let userJSON = user.prettyDescription(with: encoder)!
        XCTAssertEqual(userJSON, userInputJSON)
    }

    func test_WhenExactDecoding_EqualExpectedJSON() {
        let userInputJSON = """
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

        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .explicitKeyedContainer

        let data = userInputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)

        let userJSON = user.prettyDescription(with: encoder)!
        XCTAssertEqual(userJSON, userInputJSON)
    }

    func test_WhenExactDecodingSlice_EqualExpectedJSON() {
        let userInputJSON = """
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

        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer

        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .explicitKeyedContainer

        let data = userInputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)

        let userJSON = user.prettyDescription(with: encoder)!
        XCTAssertEqual(userJSON, userInputJSON)
    }
}
