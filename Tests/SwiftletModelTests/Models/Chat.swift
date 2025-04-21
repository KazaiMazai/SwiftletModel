//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import SwiftletModel
import Foundation

@EntityModel
struct Chat: Codable, Sendable {
    let id: String

    @Relationship(inverse: \.chats)
    var users: [User]?

    @Relationship(deleteRule: .cascade, inverse: \.chat)
    var messages: [Message]?

    @Relationship(inverse: \.adminOf)
    var admins: [User]?

    func willDelete(from context: inout Context) throws {
        try delete(\.$messages, inverse: \.$chat, from: &context)
    }
}
 
   
