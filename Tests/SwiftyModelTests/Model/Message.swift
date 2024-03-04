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
    var author: ToOne<User>?
    var chat: ToOneMutual<Chat>?
    var attachment: ToOneMutual<Attachment>?
    var replies: ToManyMutual<Message>?
    var replyTo: ToOneMutual<Message>?
    var viewers: ToMany<User>?
    
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

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.author)?.isMe
    }
}
