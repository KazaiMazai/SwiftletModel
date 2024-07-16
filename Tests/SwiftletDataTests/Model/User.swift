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
    
    @_HasOne
    var user: User? = nil
    
    mutating func normalize() {
        $user.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        save(\.$user, to: &repository)
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
    
    @_HasMany(inverse: \.users)
    var chats: [Chat]?
    
    @_HasMany(inverse: \.admins)
    var adminInChats: [Chat]?
    
    mutating func normalize() {
        $chats.normalize()
        $adminInChats.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        save(\.$chats, inverse: \.$users, to: &repository)
        save(\.$adminInChats, inverse: \.$admins, to: &repository)
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
        repository
            .query(CurrentUser.self, id: CurrentUser.id)
            .related(\.$user)?.id == id
    }
}
