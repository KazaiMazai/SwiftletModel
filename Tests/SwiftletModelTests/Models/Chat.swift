//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct Chat: Codable, Sendable {
    let id: String

    @Relationship(inverse: \.chats)
    var users: [User]?

    @Relationship(inverse: \.chat)
    var messages: [Message]?

    @Relationship(inverse: \.adminOf)
    var admins: [User]?

    func willDelete(from context: inout Context) throws {
        try delete(\.$messages, inverse: \.$chat, from: &context)
    }
}
 
//extension Query where Entity == Chat {
//    func nested(_ depth: NestedQuery) -> Query<Chat> {
//        switch depth {
//        case .shallow:
//            return self
//        case .ids:
//            return id(\.$users)
//        case .nested:
//            return with(\.$users) { $0.nested(depth: depth.next) }
//        }
//    }
//}
//
//extension Query where Entity == User {
//    func nested(depth: NestedQuery) -> Query<User> {
//        self
//    }
//}
// 
