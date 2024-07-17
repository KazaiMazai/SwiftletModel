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
    
    @HasMany(inverse: \.chats, to: Chat.self)
    var users: [User]?
    
    @HasMany(inverse: \.chat, to: Chat.self)
    var messages: [Message]?
    
    @HasMany(inverse: \.adminInChats, to: Chat.self)
    var admins: [User]?
    
    mutating func normalize() {
        $users.normalize()
        $messages.normalize()
        $admins.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        
        save(\.$users, inverse: \.$chats, to: &repository)
        save(\.$messages, inverse: \.$chat, to: &repository)
        save(\.$admins, inverse: \.$adminInChats, to: &repository)
    }
}

