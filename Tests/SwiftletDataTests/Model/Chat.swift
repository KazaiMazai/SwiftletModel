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
    
    @Relationship(inverse: \.chats)
    var users: [User]?
    
    @Relationship(inverse: \.chat)
    var messages: [Message]?
    
    @Relationship(inverse: \.adminInChats)
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

