//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct CurrentUser: Codable, Sendable {
    static let id: String = "current"

    var id: String = CurrentUser.id

    @Relationship
    var user: User? = nil
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


@EntityModel
struct User: Codable, Sendable {
    @Unique<User>(\.username, collisions: .throw) static var uniqueUsername
    @Unique<User>(\.email, collisions: .throw) static var uniqueEmail
    
    @Index<User>(\.username) static var usernameIndex
    @Unique<User>(\.isCurrent, collisions: .updateCurrentUser) static var currentUserIndex
     
    let id: String
    private(set) var name: String?
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?
    private(set) var username: String
    private(set) var email: String = ""
    private(set) var age: Int = 12
    var isCurrent: Bool = false
    var isCurrentValue: String { isCurrent ? "isCurrent" : ""}
    
    @Relationship(inverse: \.users)
    var chats: [Chat]?

    @Relationship(inverse: \.admins)
    var adminOf: [Chat]?
}
 
extension CollisionResolver where Entity == User {
    static var updateCurrentUser: Self {
        CollisionResolver { existingId, context in
            guard var user = Query<Entity>(context: context, id: existingId).resolve(),
                user.isCurrent
            else {
                return
            }
               
            user.isCurrent = false
            try user.save(to: &context)
        }
    }
}

extension Query where Entity == User {
    
    var isMe: Bool {
        CurrentUser
            .query(CurrentUser.id, in: context)
            .related(\.$user)?.id == id
    }
}
 
