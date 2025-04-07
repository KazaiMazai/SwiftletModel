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


struct User: Codable, Sendable {
    @Unique<Self>(\.username, collisions: .upsert) static var uniqueUsername
    @Unique<Self>(\.email, collisions: .throw) static var uniqueEmail
    
    @Unique<Self>(\.isCurrent, collisions: .updateCurrentUser) static var currentUserIndex
    
    
    let id: String
    private(set) var name: String?
    private(set) var avatar: Avatar?
    private(set) var profile: Profile?
    private(set) var username: String
    private(set) var email: String
     
    var isCurrent: Bool = false
    
    @Relationship(inverse: \.users)
    var chats: [Chat]?

    @Relationship(inverse: \.admins)
    var adminOf: [Chat]?
}

extension User: EntityModelProtocol {
    func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
        try willSave(to: &context)
        try updateUniqueIndex(\.username, collisions: .upsert, in: &context)
        try updateUniqueIndex(\.email, collisions: .throw, in: &context)
        try updateUniqueIndex(\.isCurrent, collisions: .updateCurrentUser, in: &context)
        
        
        context.insert(self, options: options)
        try save(\.$chats, inverse: \.$users, to: &context)
        try save(\.$adminOf, inverse: \.$admins, to: &context)
        try didSave(to: &context)
    }
    func delete(from context: inout Context) throws {
        try willDelete(from: &context)
        try removeFromUniqueIndex(\.username, in: &context)
        try removeFromUniqueIndex(\.email, in: &context)
        try removeFromUniqueIndex(\.isCurrent, in: &context)
        
        context.remove(Self.self, id: id)
        detach(\.$chats, inverse: \.$users, in: &context)
        detach(\.$adminOf, inverse: \.$admins, in: &context)
        try didDelete(from: &context)
    }
    mutating func normalize() {
        $chats.normalize()
        $adminOf.normalize()
    }
    
    static func nestedQueryModifier(_ query: Query<Self>, nested: [Nested]) -> Query<Self> {
        guard let relation = nested.first else {
            return query
        }
        
        let next = Array(nested.dropFirst())
        return switch relation {
        case .ids:
            query
                .id(\.$chats)
                .id(\.$adminOf)
        case .fragments:
            query
                .fragment(\.$chats) {
                    $0.with(next)
                }
                .fragment(\.$adminOf) {
                    $0.with(next)
                }
        case .entities:
            query
                .with(\.$chats) {
                    $0.with(next)
                }
                .with(\.$adminOf) {
                    $0.with(next)
                }
        }
    }
    
    static var patch: MergeStrategy<Self> {
        MergeStrategy(
            .patch(\.name),
            .patch(\.avatar),
            .patch(\.profile)
        )
    }
}

 
extension CollisionResolver where Entity == User {
    static var updateCurrentUser: Self {
        CollisionResolver { existingId, _, _, context in
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
 
