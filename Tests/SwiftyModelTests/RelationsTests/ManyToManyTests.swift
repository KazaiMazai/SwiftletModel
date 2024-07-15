//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation
import XCTest
@testable import SwiftyModel

final class ManyToManyTests: XCTestCase {
    var repository = Repository()
    
    func test_WhenDirectAdded_InverseIsAdded() {
        var chatOne = Chat.one
        chatOne.users = .relation([.bob])
        chatOne.save(&repository)
        
        var chatTwo = Chat.two
        chatTwo.users = .relation([.bob])
        chatTwo.save(&repository)
        
        let bobChats = User
            .query(User.bob.id, in: repository)
            .related(\.chats)
            .resolve() 
        
        XCTAssertEqual(bobChats.compactMap { $0.id }, [Chat.one.id, Chat.two.id])
    }
    
    func test_WhenRelationUpdatedWithInsert_NewRelationsInserted() {
        var chat = Chat.one
        chat.users = .relation([.bob, .alice, .tom])
        chat.save(&repository)
        
        chat.users = .fragment([.john, .michael])
        chat.save(&repository)
         
        let chatUsers = Chat
            .query(Chat.one.id, in: repository)
            .related(\.users)
            .resolve()
        
        let expectedChatUsers = [User.bob.id, User.alice.id, User.tom.id, User.john.id, User.michael.id]
        
        XCTAssertEqual(chatUsers.compactMap { $0.id },
                       expectedChatUsers)
    }
    
    func test_WhenDirectReplaced_InverseIsUpdated() {
        var chat = Chat.one
        chat.users = .relation([.bob, .alice, .tom])
        chat.save(&repository)
        
        chat.users = .relation([.john, .michael])
        chat.save(&repository)
        
        let bobsChats = User
            .query(User.bob.id, in: repository)
            .related(\.chats)
        
        XCTAssertTrue(bobsChats.isEmpty)
    }
    
    func test_Encoding() {
        var chat = Chat.one
        chat.users = .relation([.bob, .alice, .tom])
        chat.save(&repository)
        chat.messages = .relation([
            Message(id: "1",
                    text: "hello",
                    author: .relation(.alice),
                    attachment: .null)
        ])
        chat.users = .fragment([.john, .michael])
        chat.save(&repository)
        
        let bob = User
            .query(User.bob.id, in: repository)
            .with(\.chats) { $0
                .ids(\.users)
                .with(\.messages) {
                    $0.with(\.attachment) {
                        $0.id(\.message)
                    }
                    .id(\.author)
                }
            }
        
//            .with(\.chats) {
//                $0.with(\.users)
//                    .with(\.messages) {
//                        $0.with(ids: \.attachment)
//                    }
//            }
            .resolve()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]//, .sortedKeys]
       
        let string = String(data: try! encoder.encode(chat), encoding: .utf8) ?? ""
        print(string)
    }
}
   
