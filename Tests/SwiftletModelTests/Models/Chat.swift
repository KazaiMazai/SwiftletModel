//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct Chat: Codable {
    let id: String

    @Relationship(\.users, inverse: \.chats)
    var users: [User]?

    @Relationship(\.messages, inverse: \.chat)
    var messages: [Message]?

    @Relationship(\.admins, inverse: \.adminOf)
    var admins: [User]?
    
    func willDelete(from context: inout Context) throws {
        try delete(\.$messages, inverse: \.$chat, from: &context)
    }
}
