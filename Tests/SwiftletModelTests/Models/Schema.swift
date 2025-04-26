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
    
    var id: String { "\(Schema.self)"}
    
    @Relationship
    var versions: [SchemaVersions]? = .relation([
        .v1(schema: V1())
    ])
}

typealias User = Schema.V1.User
typealias Chat = Schema.V1.Chat
typealias Message = Schema.V1.Message
typealias Attachment = Schema.V1.Attachment

extension Schema {
    enum Version: String {
        case v1
    }
    
    @EntityModel
    enum SchemaVersions: Codable {
        case v1(schema: V1)
        
        var id: String { version.rawValue }
        
        var version: Version {
            switch self {
            case .v1(let model):
                return model.version
            }
        }
    }
}

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
    static func fullSchemaQuery(updated range: ClosedRange<Date>, in context: Context) -> QueryList<Self> {
        Schema.queryAll(
            with: .schemaEntities, .schemaEntities(filter: .updated(within: range)), .ids,
            in: context
        )
    }
    
    static func fullSchemaQuery(in context: Context) -> QueryList<Self> {
        Schema.queryAll(
            with: .schemaEntities, .schemaEntities, .ids,
            in: context
        )
    }
    
    static func fullSchemaQueryFragments(in context: Context) -> QueryList<Self> {
        Schema.queryAll(
            with: .schemaEntities, .schemaFragments, .ids,
            in: context
        )
    }
}
