//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
import Foundation

struct Chat: IdentifiableEntity, Codable {
    let id: String
    var users: [MutualRelation<User>]?
    var messages: [MutualRelation<Message>]?
    
    mutating func normalize() {
        users?.normalize()
        messages?.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        repository.save(users, options: .mergingWithExising)
        repository.save(relation(\.users, inverse: \.chats))
        
        repository.save(messages)
        repository.save(relation(\.messages, inverse: \.chat))
    }
}
