//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct Message: Codable {
    let id: String
    let text: String

    @BelongsTo
    var author: User? = nil

    @BelongsTo(\.chat, inverse: \.messages)
    var chat: Chat?

    @HasOne(\.attachment, inverse: \.message)
    var attachment: Attachment?

    @HasMany(\.replies, inverse: \.replyTo)
    var replies: [Message]?

    @HasOne(\.replyTo, inverse: \.replies)
    var replyTo: Message?

    @HasMany
    var viewedBy: [User]? = nil
    
    func willDelete(from context: inout Context) throws {
        try delete(\.$attachment, inverse: \.$message, from: &context)
    }
}



extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.$author)?.isMe
    }
}
