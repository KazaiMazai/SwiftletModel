//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct CurrentUser: Codable {
    static let id: String = "current"

    var id: String = CurrentUser.id

    @HasOne
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
struct User: Codable {
    let id: String
    private(set) var name: String?
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?

    @HasMany(\.chats, inverse: \.users)
    var chats: [Chat]?

    @HasMany(\.adminOf, inverse: \.admins)
    var adminOf: [Chat]?
}

extension Query where Entity == User {
    var isMe: Bool {
        CurrentUser
            .query(CurrentUser.id, in: context)
            .related(\.$user)?.id == id
    }
}
