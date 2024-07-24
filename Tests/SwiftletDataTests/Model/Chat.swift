//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletData
import Foundation

struct Chat: EntityModel, Codable {
    let id: String
    
    @HasMany(\.users, inverse: \.chats)
    var users: [User]?
    
    @HasMany(\.messages, inverse: \.chat)
    var messages: [Message]?
    
    @HasMany(\.admins, inverse: \.adminInChats)
    var admins: [User]?
    
    mutating func normalize() {
        $users.normalize()
        $messages.normalize()
        $admins.normalize()
    }
    
    func save(_ context: inout Context) throws {
        context.save(self)
        
        try save(\.$users, inverse: \.$chats, to: &context)
        try save(\.$messages, inverse: \.$chat, to: &context)
        try save(\.$admins, inverse: \.$adminInChats, to: &context)
    }
    
    func delete(_ context: inout Context) throws {
        context.remove(Chat.self, id: id)
        
        try delete(\.$messages, inverse: \.$chat, in: &context)
        detach(\.$users, inverse: \.$chats, in: &context)
        detach(\.$admins, inverse: \.$adminInChats, in: &context)
    }
    
}

