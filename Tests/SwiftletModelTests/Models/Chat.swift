//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import SwiftletModel
import Foundation


struct Chat: Codable, Sendable {
    let id: String

    @Relationship(inverse: \.chats)
    var users: [User]?

    @Relationship(deleteRule: .cascade, inverse: \.chat)
    var messages: [Message]?

    @Relationship(inverse: \.adminOf)
    var admins: [User]?

    func willDelete(from context: inout Context) throws {
        try delete(\.$messages, inverse: \.$chat, from: &context)
    }
    

}

extension Chat: EntityModelProtocol {
    func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
        var copy = self
        try copy.willSave(to: &context)
        
        
        
        context.insert(copy.normalized(), options: options)
        try copy.save(\.$users, inverse: \.$chats, to: &context)
        try copy.save(\.$messages, inverse: \.$chat, to: &context)
        try copy.save(\.$admins, inverse: \.$adminOf, to: &context)
        
        try copy.metadata?.save(to: &context)
        try copy.didSave(to: &context)
    }
    func delete(from context: inout Context) throws {
        try willDelete(from: &context)
        
        
        context.remove(Self.self, id: id)
        detach(\.$users, inverse: \.$chats, in: &context)
        try delete(\.$messages, inverse: \.$chat, from: &context)
        detach(\.$admins, inverse: \.$adminOf, in: &context)
        try metadata?.deleted().save(to: &context)
        try didDelete(from: &context)
    }
    mutating func normalize() {
        $users.normalize()
        $messages.normalize()
        $admins.normalize()
    }
    
    static func nestedQueryModifier(_ query: ContextQuery<Self, Optional<Self>, Self.ID>, nested: [Nested]) -> ContextQuery<Self, Optional<Self>, Self.ID> {
        guard let relation = nested.first else {
            return query
        }
        
        let next = Array(nested.dropFirst())
        return switch relation {
        case .ids:
            query
                .id(\.$users)
                .id(\.$messages)
                .id(\.$admins)
        case .fragments:
            query
                .fragment(\.$users) {
                    $0.with(next)
                }
                .fragment(\.$messages) {
                    $0.with(next)
                }
                .fragment(\.$admins) {
                    $0.with(next)
                }
        case .entities:
            query
                .with(\.$users) {
                    $0.with(next)
                }
                .with(\.$messages) {
                    $0.with(next)
                }
                .with(\.$admins) {
                    $0.with(next)
                }
        case .snapshot(let predicate):
            query
                .with(\.$users) {
                    $0.filter(predicate).with(next)
                }
                .with(\.$messages) {
                    $0.filter(predicate).with(next)
                }
                .with(\.$admins) {
                    $0.filter(predicate).with(next)
                }
        }
    }
    
    static var patch: MergeStrategy<Self> {
        MergeStrategy(
            
        )
    }
}


   
