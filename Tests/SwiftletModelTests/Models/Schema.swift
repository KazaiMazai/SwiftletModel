//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 18/04/2025.
//

import Foundation
import SwiftletModel

@EntityModel
struct Schema: Codable {
    var id: String { "\(Schema.self)"}
    
    @Relationship
    var v1: Schema.V1? = .relation(V1())
}

typealias User = Schema.V1.User
typealias Chat = Schema.V1.Chat
typealias Message = Schema.V1.Message
typealias Attachment = Schema.V1.Attachment

extension Schema {
    
    @EntityModel
    struct V1: Codable {
        static let version = "\(V1.self)"
        
        var id: String { Self.version }
        
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
    static func schemaQuery(updated range: ClosedRange<Date>, in context: Context) -> QueryList<Self> {
        Schema.queryAll(
            with: .entities, .schemaEntities(filter: .updated(within: range)), .ids,
            in: context
        )
    }
}
 
