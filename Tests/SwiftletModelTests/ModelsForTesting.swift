//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation

extension User {
    static let bob = User(id: "1", name: "Bob", username: "@bob", email: "bob@gmail.com")
    static let alice = User(id: "2", name: "Alice", username: "@alice", email: "alice@gmail.com")
    static let john = User(id: "3", name: "John", username: "@john", email: "john@gmail.com")
    static let michael = User(id: "4", name: "Michael", username: "@michael", email: "michael@gmail.com")
    static let tom = User(id: "5", name: "Tom", username: "@tom", email: "tom@gmail.com")
}

extension Attachment {
    static let imageOne = Attachment(id: "1", kind: .file(url: URL(string: "http://google.com/image-1.jpg")!))
    static let imageTwo = Attachment(id: "2", kind: .file(url: URL(string: "http://google.com/image-2.jpg")!))
}

extension Chat {
    static let one = Chat(id: "1")
    static let two = Chat(id: "2")
}
