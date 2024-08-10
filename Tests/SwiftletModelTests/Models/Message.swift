//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct Message: Codable {
    let id: String
    let text: String

    @Relationship(.required)
    var author: User?
     
    @Relationship(\.chat, inverse: \.messages)
    var chat: Chat?

    @Relationship(\.attachment, inverse: \.message)
    var attachment: Attachment?

    @Relationship(\.replies, inverse: \.replyTo)
    var replies: [Message]?

    @Relationship(\.replyTo, inverse: \.replies)
    var replyTo: Message?

    @Relationship
    var viewedBy: [User]? = nil
    
    func willDelete(from context: inout Context) throws {
        try delete(\.$attachment, inverse: \.$message, from: &context)
    }
    

}


func foo() {
    var msg = Message(id: "1", text: "text")
    var msg2 = Message(id: "1", text: "text")
    
}


extension Query where Entity == Message {
    var isMyMessage: Bool? {
        related(\.$author)?.isMe
    }
}
