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
    var author: Relation<User>?
    var chat: MutualRelation<Chat>?
    var attachment: MutualRelation<Attachment>?
    var replies: [MutualRelation<Message>]?
    var replyTo: MutualRelation<Message>?
    var viewers: [Relation<User>]?
    
    mutating func normalize() {
        author?.normalize()
        chat?.normalize()
        attachment?.normalize()
        replies?.normalize()
        replyTo?.normalize()
        viewers?.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        repository.save(author, options: .mergingWithExising)
       
        repository.save(chat)
        repository.save(relation(\.chat, inverse: \.messages))
    }
}

extension Entity where T == Message {
    var isMyMessage: Bool? {
        related(\.author)?.isMe
    }
}
