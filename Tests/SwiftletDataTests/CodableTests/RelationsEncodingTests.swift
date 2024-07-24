//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 19/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletData

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
        
        try chat.save(&context)
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
                .ids(\.$users)
                .ids(\.$admins)
            }
            .resolve()
        
        
        let expectedJSON = """
        {
          "adminInChats" : null,
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
          "id" : "1",
          "name" : "Bob"
        }
        """
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        XCTAssertEqual(userJSON, expectedJSON)
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
                .ids(\.$users)
                .ids(\.$admins)
            }
            .resolve()
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminInChats" : null,
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
        
        XCTAssertEqual(userJSON, expectedJSON)
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
                .ids(\.$users)
                .ids(\.$admins)
            }
            .resolve()
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminInChats" : null,
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
        
        XCTAssertEqual(userJSON, expectedJSON)
    }
 
    func test_WhenExactEncodingFragment_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicitKeyedContainer
        
        let user = User
            .query(User.bob.id, in: context)
            .with(\.$chats) {
                $0.with(\.$messages, fragment: true) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .ids(\.$users, fragment: true)
                .ids(\.$admins)
            }
            .resolve()
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminInChats" : null,
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
                  "fragment" : [
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
                  "fragment_ids" : [
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
        
        XCTAssertEqual(userJSON, expectedJSON)
    }
    
    func test_WhenExplicitEncodingFragment_EqualExpectedJSON() {
       
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .keyedContainer
        
        let user = User
            .query(User.bob.id, in: context)
            .with(\.$chats) {
                $0.with(\.$messages, fragment: true) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .ids(\.$users, fragment: true)
                .ids(\.$admins)
            }
            .resolve()
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminInChats" : null,
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
        
        XCTAssertEqual(userJSON, expectedJSON)
    }
    
    func test_WhenDefaultEncodingFragment_EqualExpectedJSON() {
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain
        
        let user = User
            .query(User.bob.id, in: context)
            .with(\.$chats) {
                $0.with(\.$messages, fragment: true) {
                    $0.with(\.$attachment) {
                        $0.id(\.$message)
                    }
                    .id(\.$author)
                    .id(\.$chat)
                }
                .ids(\.$users, fragment: true)
                .ids(\.$admins)
            }
            .resolve()
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        let expectedJSON = """
        {
          "adminInChats" : null,
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
          "id" : "1",
          "name" : "Bob"
        }
        """
        
        XCTAssertEqual(userJSON, expectedJSON)
    }
}

