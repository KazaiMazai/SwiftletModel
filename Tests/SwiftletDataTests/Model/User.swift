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
    
    func save(_ context: inout Context) throws {
        context.save(self)
        try save(\.$user, to: &context)
    }
    
    func delete(_ context: inout Context) throws {
        detach(\.$user, in: &context)
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
    
    func save(_ context: inout Context) throws {
        context.save(self, options: User.patch())
        try save(\.$chats, inverse: \.$users, to: &context)
        try save(\.$adminInChats, inverse: \.$admins, to: &context)
    }
    
    func delete(_ context: inout Context) throws {
        context.remove(User.self, id: id)
        
        detach(\.$chats, inverse: \.$users, in: &context)
        detach(\.$adminInChats, inverse: \.$admins, in: &context)
    }
    
    static func patch() -> MergeStrategy<User> {
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
            .query(CurrentUser.id, in: context)
            .related(\.$user)?.id == id
    }
}
