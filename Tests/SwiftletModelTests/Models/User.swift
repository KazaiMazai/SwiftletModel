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
    let id: String
    private(set) var name: String?
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?
    private(set) var username: String = ""
    private(set) var email: String = ""
    private(set) var age: Int = 12
    
    @Index<User>(\.age)
    static var ageIndex
    
    @Index<User>(\.username, \.email)
    static var usernameIndex
    
    @Relationship(inverse: \.users)
    var chats: [Chat]?

    @Relationship(inverse: \.admins)
    var adminOf: [Chat]?
}

extension Query where Entity == User {
    var isMe: Bool {
        CurrentUser
            .query(CurrentUser.id, in: context)
            .related(\.$user)?.id == id
    }
}
 
