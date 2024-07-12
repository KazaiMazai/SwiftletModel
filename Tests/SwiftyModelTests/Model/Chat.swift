//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
import Foundation

struct Chat: EntityModel, Codable {
    let id: String
    var users: HasMany<User> = .none
    var messages: HasMany<Message> = .none
    
    mutating func normalize() {
        users.normalize()
        messages.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        repository.save(relation(\.users, inverse: \.chats))
        repository.save(relation(\.messages, inverse: \.chat))
        
        users.save(&repository)
        messages.save(&repository)
    }
}
