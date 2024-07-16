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
    var users: HasMany<User> = .none
    var messages: HasMany<Message> = .none
    
    @One(Relations.OneWay.self, constraints: Relations.Optional.self)
    var admin: User?
    
    mutating func normalize() {
        users.normalize()
        messages.normalize()
        $admin.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        
        save(\.users, inverse: \.chats, to: &repository)
        save(\.messages, inverse: \.chat, to: &repository)
        save(\.$admin, to: &repository)
        
    }
}

