//
//  File.swift
//  
//
//  Created by Serge Kazakov on 03/03/2024.
//

import SwiftletModel
import Foundation

extension Schema.V1 {

    @EntityModel
    struct Message: Codable, Sendable {

        @Index<Self>(\.timestamp) private static var timestampIndex
        @FullTextIndex<Self>(\.text) private static var textSearchIndex1

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
}

extension Query<Message> {
    var isMyMessage: Bool? {
        related(\.$author)
            .resolve()?.isCurrent == true
    }
}

