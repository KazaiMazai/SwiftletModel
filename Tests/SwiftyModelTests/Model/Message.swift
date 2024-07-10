//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
import Foundation

struct Message: IdentifiableEntity, Codable {
    let id: String
    let text: String
    var author: ToOne<User> = .none
    var chat: ManyToOne<Chat> = .none
    var attachment: OneToOne<Attachment> = .none
    var replies: ManyToOne<Message> = .none
    var replyTo: OneToOne<Message> = .none
    var viewers: ToMany<User> = .none
}

extension Message {
    mutating func normalize() {
        author.normalize()
        chat.normalize()
        attachment.normalize()
        replies.normalize()
        replyTo.normalize()
        viewers.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        repository.save(author)
        repository.save(relation(\.author))

        repository.save(chat)
        repository.save(relation(\.chat, inverse: \.messages))
    }
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.author)?.isMe
    }
}
