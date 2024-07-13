//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
import Foundation

struct Message: EntityModel, Codable {
    let id: String
    let text: String
    var author: ToOne<User> = .none
    var chat: BelongsTo<Chat> = .none
    var attachment: HasOne<Attachment> = .none
    var replies: HasMany<Message> = .none
    var replyTo: HasOne<Message> = .none
    var viewedBy: ToMany<User> = .none
}

extension Message {
    mutating func normalize() {
        author.normalize()
        chat.normalize()
        attachment.normalize()
        replies.normalize()
        replyTo.normalize()
        viewedBy.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
       
        save(\.author, to: &repository)
        save(\.chat, inverse: \.messages, to: &repository)
        save(\.attachment, inverse: \.message, to: &repository)
        save(\.replies, inverse: \.replyTo, to: &repository)
        save(\.replyTo, inverse: \.replies, to: &repository)
        save(\.viewedBy, to: &repository)
    }
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.author)?.isMe
    }
}
