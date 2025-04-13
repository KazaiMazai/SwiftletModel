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
    @Index<Self>(\.timestamp) private static var timestampIndex
    @FullTextIndex<Self>(\.text) static var textSearchIndex1
    
    public let id: String
    let text: String
    var timestamp: Date = .distantPast
 
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

    public func willDelete(from context: inout Context) throws {
        try delete(\.$attachment, inverse: \.$message, from: &context)
    }
}

extension Query<Message> {
    var isMyMessage: Bool? {
        related(\.$author).isMe
    }
}
 
