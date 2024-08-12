//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct Message: Codable, Sendable {
    let id: String
    let text: String

    @Relationship(.required)
    var author: User?

    @Relationship(inverse: \.messages)
    var chat: Chat?

    @Relationship(deleteRule: .cascade, inverse: \.message)
    var attachment: Attachment?

    @Relationship(inverse: \.replyTo)
    var replies: [Message]?

    @Relationship(inverse: \.replies)
    var replyTo: Message?

    @Relationship
    var viewedBy: [User]? = nil
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.$author)?.isMe
    }
}
 
