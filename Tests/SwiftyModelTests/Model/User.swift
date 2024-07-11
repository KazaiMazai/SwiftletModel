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
    
    func save(_ repostory: inout Repository) {
        repostory.save(self)
        repostory.save(relation(\.user))
        
        user.save(&repostory)
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
    let name: String
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?
    private(set) var chats: ManyToMany<Chat> = .none
     
    mutating func normalize() {
        chats.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        repository.save(relation(\.chats, inverse: \.users))
        chats.save(&repository)
    }
    
    static func defaultMergeStraregy() -> MergeStrategy<User> {
        MergeStrategy(
            .patch(\.profile),
            .patch(\.avatar)
        )
    }
}

extension Query where Entity == User {
    var isMe: Bool {
        repository
            .query(Current.self, id: Current.id)
            .related(\.user)?.id == id
    }
}
