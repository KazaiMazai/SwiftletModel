//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletData

final class ManyToManyTests: XCTestCase {
    var repository = Repository()
    
    func test_WhenDirectAdded_InverseIsAdded() {
        var chatOne = Chat.one
        chatOne.$users = .relation([.bob])
        try! chatOne.save(&repository)
        
        var chatTwo = Chat.two
        chatTwo.$users = .relation([.bob])
        try! chatTwo.save(&repository)
        
        let bobChats = User
            .query(User.bob.id, in: repository)
            .related(\.$chats)
            .resolve() 
        
        XCTAssertEqual(bobChats.compactMap { $0.id }, [Chat.one.id, Chat.two.id])
    }
    
    func test_WhenRelationUpdatedWithInsert_NewRelationsInserted() {
        var chat = Chat.one
        chat.$users = .relation([.bob, .alice, .tom])
        try! chat.save(&repository)
        
        chat.$users = .fragment([.john, .michael])
        try! chat.save(&repository)
         
        let chatUsers = Chat
            .query(Chat.one.id, in: repository)
            .related(\.$users)
            .resolve()
        
        let expectedChatUsers = [User.bob.id, User.alice.id, User.tom.id, User.john.id, User.michael.id]
        
        XCTAssertEqual(chatUsers.compactMap { $0.id },
                       expectedChatUsers)
    }
    
    func test_WhenDirectReplaced_InverseIsUpdated() {
        var chat = Chat.one
        chat.$users = .relation([.bob, .alice, .tom])
        try! chat.save(&repository)
        
        chat.$users = .relation([.john, .michael])
        try! chat.save(&repository)
        
        let bobsChats = User
            .query(User.bob.id, in: repository)
            .related(\.$chats)
        
        XCTAssertTrue(bobsChats.isEmpty)
    }
}
   
