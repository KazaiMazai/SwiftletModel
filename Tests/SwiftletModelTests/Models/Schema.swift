//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 18/04/2025.
//

import Foundation
import SwiftletModel

@EntityModel
struct Schema: Codable {
    enum Version: String { case v1 }
    
    var id: String { "\(Schema.self)"}
    
    @Relationship
    var v1: V1? = .relation(V1())
}

typealias User = Schema.V1.User
typealias Chat = Schema.V1.Chat
typealias Message = Schema.V1.Message
typealias Attachment = Schema.V1.Attachment
 
extension Schema {
    
    @EntityModel
    struct V1: Codable {
        var version: Version { .v1 }
        
        var id: String { version.rawValue }
        
        @Relationship var attachments: [Attachment]? = .none
        @Relationship var chats: [Chat]? = .none
        @Relationship var messages: [Message]? = .none
        @Relationship var users: [User]? = .none
        
        @Relationship var deletedAttachments: [Deleted<Attachment>]? = .none
        @Relationship var deletedChats: [Deleted<Chat>]? = .none
        @Relationship var deletedMessages: [Deleted<Message>]? = .none
        @Relationship var deletedUsers: [Deleted<User>]? = .none
    }
}

extension Schema {
    static func fullSchemaQuery(updated range: ClosedRange<Date>) -> QueryList<Self> {
        Schema.queryAll(
            with: .entities, .schemaEntities(filter: .updated(within: range)), .ids
        )
    }
    
    static func fullSchemaQuery() -> QueryList<Self> {
        Schema.queryAll(
            with: .entities, .schemaEntities, .ids
        )
    }
    
    static func fullSchemaQueryFragments() -> QueryList<Self> {
        Schema.queryAll(
            with: .entities, .schemaFragments, .ids
        )
    }
}
