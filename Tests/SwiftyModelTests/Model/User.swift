//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
import Foundation

struct Current: EntityModel, Codable {
    static let id: String = "current"
    
    private(set) var id: String = Current.id
    
    var user: ToOne<User> = .none
    
    mutating func normalize() {
        user.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        save(\.user, to: &repository)
    }
}

extension User {
    struct Profile: Codable {
        let bio: String?
        let url: String?
    }
    
    struct Avatar: Codable {
        let small: URL?
        let medium: URL?
        let large: URL?
    }
}
    
struct User: EntityModel, Codable {
    let id: String
    private(set) var name: String?
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?
    var chats: HasMany<Chat> = .none
     
    mutating func normalize() {
        chats.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        save(\User.chats, inverse: \Chat.users, to: &repository)
    }
    
    static func mergeStraregy() -> MergeStrategy<User> {
        MergeStrategy(
            .patch(\.name),
            .patch(\.profile),
            .patch(\.avatar)
        )
    }
}

extension User {
    
    struct Validation: ToOneValidation {
        
        static func validate(model: User) throws {
            
        }
    }
    
}

extension Query where Entity == User {
    var isMe: Bool {
        repository
            .query(Current.self, id: Current.id)
            .related(\.user)?.id == id
    }
}
