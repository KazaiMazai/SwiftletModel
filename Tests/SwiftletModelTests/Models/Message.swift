//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
public struct Message: Codable, Sendable {
    public let id: String
    let text: String

    @Relationship(.required)
    var author: User?

    @Relationship(inverse: \.messages)
    var chat: Chat?

    @Relationship(deleteRule: .cascade, inverse: \.message)
    var attachment: Attachment?

    @Relationship(inverse: \.replyTo)
    var replies: [Message]?

    @Relationship(inverse: \.replies)
    var replyTo: Message?

    @Relationship
    var viewedBy: [User]? = nil


    func willDelete(from context: inout Context) throws {
        try delete(\.$attachment, inverse: \.$message, from: &context)
    }
    
    var indexValue: Pair<String, String> {
        map((id, text))
    }
    
    var indexValue1: any Collection {
        [self[keyPath: \.id], self[keyPath: \.text]]
    }
    
    var index: any IndexProtocol {
        Index.makeIndex(self, \.id, \.text)
    }
    
    func indexEntity<Value>() -> EntityIndex<Message, Value> {
        
    }
    
    func willSave(to context: inout Context) throws {
        var index = EntityIndex(\Message.id, \.text)
            .query(in: context)
            .resolve() ?? EntityIndex(\Message.id, \.text)
        
        index.insert(self, value: \.indexValue)
        try index.save(to: &context)
    }
}

extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.$author)?.isMe
    }
}
 
