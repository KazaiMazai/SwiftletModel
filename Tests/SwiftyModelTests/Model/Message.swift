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
    private(set) var author: ToOne<User> = .none
    private(set) var chat: BelongsTo<Chat>
    private(set) var attachment: HasOne<Attachment> = .none
    private(set) var replies: HasMany<Message> = .none
    private(set) var replyTo: HasOne<Message> = .none
    private(set) var viewers: ToMany<User> = .none
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
       
        repository.save(relation(\.author))
        repository.save(relation(\.chat, inverse: \.messages))
        repository.save(relation(\.attachment, inverse: \.message))
        repository.save(relation(\.replies, inverse: \.replyTo))
        repository.save(relation(\.replyTo, inverse: \.replies))
        repository.save(relation(\.viewers))
        
        author.save(&repository)
        chat.save(&repository)
        attachment.save(&repository)
        replies.save(&repository)
        replyTo.save(&repository)
        viewers.save(&repository)
    }
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.author)?.isMe
    }
}
