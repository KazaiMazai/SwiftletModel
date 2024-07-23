//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletData
import Foundation

struct CurrentUser: EntityModel, Codable {
    static let id: String = "current"
    
    private(set) var id: String = CurrentUser.id
    
    @HasOne
    var user: User? = nil
    
    mutating func normalize() {
        $user.normalize()
    }
    
    func save(_ repository: inout Repository) throws {
        repository.save(self)
        try save(\.$user, to: &repository)
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
    
    @HasMany(\.chats, inverse: \.users)
    var chats: [Chat]?
    
    @HasMany(\.adminInChats, inverse: \.admins)
    var adminInChats: [Chat]?
    
    mutating func normalize() {
        $chats.normalize()
        $adminInChats.normalize()
    }
    
    func save(_ repository: inout Repository) throws {
        repository.save(self)
        try save(\.$chats, inverse: \.$users, to: &repository)
        try save(\.$adminInChats, inverse: \.$admins, to: &repository)
    }
    
    static func mergeStraregy() -> MergeStrategy<User> {
        MergeStrategy(
            .patch(\.name),
            .patch(\.profile),
            .patch(\.avatar)
        )
    }
}

extension Query where Entity == User {
    var isMe: Bool {
        CurrentUser
            .query(CurrentUser.id, in: repository)
            .related(\.$user)?.id == id
    }
}
