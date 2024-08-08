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

    @HasMany(\.users, inverse: \.chats)
    var users: [User]?

    @HasMany(\.messages, inverse: \.chat)
    var messages: [Message]?

    @HasMany(\.admins, inverse: \.adminOf)
    var admins: [User]?
    
    func willDelete(from context: inout Context) throws {
        try delete(\.$messages, inverse: \.$chat, from: &context)
    }
}
