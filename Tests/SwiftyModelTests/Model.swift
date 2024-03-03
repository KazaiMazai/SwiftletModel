//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

@testable import SwiftyModel

struct CurrentUser: IdentifiableEntity, Codable {
   static let me = "me"
    
    private(set) var id: String = CurrentUser.me
    var user: Relation<User>?
    
    mutating func normalize() {
        user?.normalize()
    }
}
    
struct User: IdentifiableEntity, Codable {
    let id: String
    let name: String
    var profileDescription: String?
    
    var messages: [Relation<Message>]?
    var follows: [MutualRelation<User>]?
    var users: [MutualRelation<User>] = []
    var followedBy: [MutualRelation<User>]?
    var chats: [MutualRelation<Chat>]?
    
    mutating func normalize() {
        messages?.normalize()
        follows?.normalize()
        followedBy?.normalize()
        chats?.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self, options: .merge())
        repository.save(follows)
        repository.save(users)
        repository.save(followedBy)
        repository.save(chats)
        
        repository.save(relation(\.follows, option: .replace, inverse: \.followedBy))
        repository.save(relation(\.followedBy, option: .replace, inverse: \.follows))
        repository.save(relation(\.chats, option: .append, inverse: \.users))
    }
}

extension Merge {
    static func merge() -> Merge<User> {
        
        Merge<User> { exisingUser, newUser in
            
            newUser
                .merge(\.profileDescription, with: exisingUser, by: .keepingOldIfNil())
                .merge(\.messages, with: exisingUser, by: .appending())
                .merge(\.follows, with: exisingUser, by: .appending())
                .merge(\.followedBy, with: exisingUser, by: .appending())
                .merge(\.chats, with: exisingUser, by: .appending())
        }
    }
}

extension Entity where T == User {
    var isMe: Bool {
        repository
            .find(CurrentUser.self, id: CurrentUser.me)
            .related(\.user)?.id == id
    }
}

struct Chat: IdentifiableEntity, Codable {
    let id: String
    var users: [MutualRelation<User>]?
    var messages: [MutualRelation<Message>]?
    
    mutating func normalize() {
        users?.normalize()
        messages?.normalize()
    }
}

struct Message: IdentifiableEntity, Codable {
    let id: String
    let text: String
    var fromUser: MutualRelation<User>?
    var attachments: [MutualRelation<Attachment>]?
    
    mutating func normalize() {
        fromUser?.normalize()
        attachments?.normalize()
    }
}

extension Entity where T == Message {
    var isMyMessage: Bool? {
        related(\.fromUser)?.isMe
    }
}

struct Attachment: IdentifiableEntity, Codable {
    let id: String
    let url: String
    var message: MutualRelation<Message>?
    
    mutating func normalize() {
        message?.normalize()
    }
}
