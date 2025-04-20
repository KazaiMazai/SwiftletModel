//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 18/04/2025.
//

import Foundation
import SwiftletModel

@EntityModel
struct Schema {
    var id: String { "\(Schema.self)"}
    
    @Relationship
    var v1: Schema.V1? = .none
    
    init() {
        $v1 = .id(V1.version)
    }
    
    static func batchSchemaQuery(in context: Context) -> QueryList<Self> {
        Schema
            .batchQuery(with: .entities, .snapshot(.updatedAt(Date.distantPast...Date.distantFuture)), .ids, in: context)
        
    }
}


extension Schema {
    @EntityModel
    struct V1 {
        static let version = "\(V1.self)"
        
        var id: String { Self.version }
        
        @Relationship var attachments: [Attachment]? = .none
        @Relationship var chats: [Chat]? = .none
        @Relationship var messages: [Message]? = .none
        @Relationship var users: [User]? = .none
        
        @Relationship var attachmentsMetadata: [Metadata<Attachment>]? = .none
        @Relationship var chatsMetadata: [Metadata<Chat>]? = .none
        @Relationship var messagesMetadata: [Metadata<Message>]? = .none
        @Relationship var usersMetadata: [Metadata<User>]? = .none
    }
}
