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
    
    @_HasMany(inverse: \.chats)
    var users: [User]?
    
    @_HasMany(inverse: \.chat)
    var messages: [Message]?
    
    @_HasMany(inverse: \.adminInChats)
    var admins: [User]?
    
    mutating func normalize() {
        $users.normalize()
        $messages.normalize()
        $admins.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        
        save(\.$users, inverse: \.chats, to: &repository)
        save(\.$messages, inverse: \.chat, to: &repository)
        save(\.$admins, inverse: \.adminInChats, to: &repository)
    }
}

