//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletData

final class RelationDecodingTests: XCTestCase {
    var repository = Repository()
    
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
        
        chat.save(&repository)
    }
    
    func test_WhenDefaultDecoding_EqualExpectedJSON() {
        let inputJSON = """
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
        
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .plain
        
        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .plain
        
        let data = inputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        XCTAssertEqual(userJSON, inputJSON)
    }
    
    func test_WhenExplicitDecoding_EqualExpectedJSON() {
        let inputJSON = """
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
        
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .explicit
        
        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .explicit
        
        let data = inputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        XCTAssertEqual(userJSON, inputJSON)
    }
    
    func test_WhenExactDecoding_EqualExpectedJSON() {
        let inputJSON = """
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
        
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .exact
        
        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .exact
        
        let data = inputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        XCTAssertEqual(userJSON, inputJSON)
    }
 
    func test_WhenExactDecodingFragment_EqualExpectedJSON() {
        let inputJSON = """
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
        
        let encoder = JSONEncoder.prettyPrinting
        encoder.relationEncodingStrategy = .exact
        
        let decoder = JSONDecoder()
        decoder.relationDecodingStrategy = .exact
        
        let data = inputJSON.data(using: .utf8)!
        let user = try! decoder.decode(User.self, from: data)
        
        let userJSON = user.prettyDescription(with: encoder) ?? ""
        XCTAssertEqual(userJSON, inputJSON)
    }
}
