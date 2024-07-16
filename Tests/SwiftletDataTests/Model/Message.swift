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
    
    @HasOne
    var author: User? = nil
    
    @BelongsTo(inverse: \.messages)
    var chat: Chat?
    
    @HasOne(inverse: \.message)
    var attachment: Attachment?
    
    @HasMany(inverse: \.replyTo)
    var replies: [Message]?
    
    @HasMany(inverse: \.replies)
    var replyTo: [Message]?
    
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
    
    func save(_ repository: inout Repository) {
        repository.save(self)
       
        save(\.$author, to: &repository)
        save(\.$chat, inverse: \.$messages, to: &repository)
        save(\.$attachment, inverse: \.$message, to: &repository)
        save(\.$replies, inverse: \.$replyTo, to: &repository)
        save(\.$replyTo, inverse: \.$replies, to: &repository)
        save(\.$viewedBy, to: &repository)
    }
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.$author)?.isMe
    }
}
