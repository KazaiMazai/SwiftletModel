//
//  File.swift
//
//
//  Created by Serge Kazakov on 03/03/2024.
//

import SwiftletModel
import Foundation

extension Schema.V1 {

    @EntityModel
    struct User: Codable, Sendable {
        @HashIndex<Self>(\.username) var userNameIndex
        
        @Unique<Self>(\.username, collisions: .upsert) var uniqueUsername
        @Unique<Self>(\.email, collisions: .throw) var uniqueEmail
        @Unique<Self>(\.isCurrent, collisions: .updateCurrentUser) var currentUserIndex

        let id: String
        private(set) var name: String?
        private(set) var avatar: Avatar?
        private(set) var profile: Profile?
        private(set) var username: String
        private(set) var email: String

        var isCurrent: Bool = false
        
        var fullname: String? { name }

        @Relationship(inverse: \.users)
        var chats: [Chat]?

        @Relationship(inverse: \.admins)
        var adminOf: [Chat]?
    }

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

extension CollisionResolver where Entity == User {
    static var updateCurrentUser: Self {
        CollisionResolver { existingId, _, _, context in
            guard var user = Entity.query(existingId).resolve(in: context),
                  user.isCurrent
            else {
                return
            }

            user.isCurrent = false
            try user.save(to: &context)
        }
    }
    
}
