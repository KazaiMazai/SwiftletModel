//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletData
import Foundation

struct Message: EntityModel, Codable {
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
}

extension Message {
    mutating func normalize() {
        $author.normalize()
        $chat.normalize()
        $attachment.normalize()
        $replies.normalize()
        $replyTo.normalize()
        $viewedBy.normalize()
    }
    
    func save(_ context: inout Context) throws {
        context.insert(self)
        try save(\.$author, to: &context)
        try save(\.$chat, inverse: \.$messages, to: &context)
        try save(\.$attachment, inverse: \.$message, to: &context)
        try save(\.$replies, inverse: \.$replyTo, to: &context)
        try save(\.$replyTo, inverse: \.$replies, to: &context)
        try save(\.$viewedBy, to: &context)
    }
    
    func delete(_ context: inout SwiftletData.Context) throws {
        context.remove(Message.self, id: id)
        detach(\.$author, in: &context)
        detach(\.$chat, inverse: \.$messages, in: &context)
        detach(\.$replies, inverse: \.$replyTo, in: &context)
        detach(\.$replyTo, inverse: \.$replies, in: &context)
        detach(\.$viewedBy, in: &context)
        try delete(\.$attachment, inverse: \.$message, from: &context)
    }
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.$author)?.isMe
    }
}
