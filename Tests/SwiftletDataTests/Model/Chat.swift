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
    
    @HasMany(\.admins, inverse: \.adminOf)
    var admins: [User]?
    
    mutating func normalize() {
        $users.normalize()
        $messages.normalize()
        $admins.normalize()
    }
    
    func save(_ context: inout Context) throws {
        context.insert(self)
        try save(\.$users, inverse: \.$chats, to: &context)
        try save(\.$messages, inverse: \.$chat, to: &context)
        try save(\.$admins, inverse: \.$adminOf, to: &context)
    }
    
    func delete(_ context: inout Context) throws {
        context.remove(Chat.self, id: id)
        detach(\.$users, inverse: \.$chats, in: &context)
        detach(\.$admins, inverse: \.$adminOf, in: &context)
        try delete(\.$messages, inverse: \.$chat, from: &context)
    }
    
}

