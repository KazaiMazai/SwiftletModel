//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
import Foundation

struct CurrentUser: IdentifiableEntity, Codable {
   static let me = "me"
    
    private(set) var id: String = CurrentUser.me
    var user: ToOne<User> = .none
    
    mutating func normalize() {
        user.normalize()
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
    
struct User: IdentifiableEntity, Codable {
    let id: String
    let name: String
    var avatar: Avatar?
    var profile: Profile?
    
    var chats: ManyToMany<Chat> = .none
    
    mutating func normalize() {
        chats.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self, options: .mergingWithExising)
       
        repository.save(chats)
        repository.save(relation(\.chats, inverse: \.users))
    }
}

extension MergeStrategy {
    static var mergingWithExising: MergeStrategy<User> {
        
        MergeStrategy<User> { exisingUser, newUser in
            
            newUser
                .merge(\.profile, with: exisingUser, using: .keepingOldIfNil())
                .merge(\.avatar, with: exisingUser, using: .keepingOldIfNil())
        }
    }
}

extension Query where Entity == User {
    var isMe: Bool {
        repository
            .query(CurrentUser.self, id: CurrentUser.me)
            .related(\.user)?.id == id
    }
}
