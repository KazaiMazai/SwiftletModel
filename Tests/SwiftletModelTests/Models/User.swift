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

    private(set) var id: String = CurrentUser.id

    @HasOne
    var user: User? = nil

//    mutating func normalize() {
//        $user.normalize()
//    }
//
//    func save(to context: inout Context) throws {
//        context.insert(self)
//        try save(\.$user, to: &context)
//    }
//
//    func delete(from context: inout Context) throws {
//        detach(\.$user, in: &context)
//    }
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

//    mutating func normalize() {
//        $chats.normalize()
//        $adminOf.normalize()
//    }
//
//    func save(to context: inout Context) throws {
//        context.insert(self, options: Self.mergeStrategy)
//        try save(\.$chats, inverse: \.$users, to: &context)
//        try save(\.$adminOf, inverse: \.$admins, to: &context)
//    }
//
//    func delete(from context: inout Context) throws {
//        context.remove(User.self, id: id)
//        detach(\.$chats, inverse: \.$users, in: &context)
//        detach(\.$adminOf, inverse: \.$admins, in: &context)
//    }

    static var mergeStrategy: MergeStrategy<User> {
        MergeStrategy(
            .patch(\.name),
            .patch(\.profile),
            .patch(\.avatar)
        )
    }
//    static func patch() -> MergeStrategy<User> {
//        MergeStrategy(
//            .patch(\.name),
//            .patch(\.profile),
//            .patch(\.avatar)
//        )
//    }
}

extension Query where Entity == User {
    var isMe: Bool {
        CurrentUser
            .query(CurrentUser.id, in: context)
            .related(\.$user)?.id == id
    }
}
