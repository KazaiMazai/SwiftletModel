import XCTest
@testable import SwiftyModel

final class SwiftyModelTests: XCTestCase {
   
    func test() {
        var storage = Repository()
        
        let attachment = Attachment(id: "1", kind: .file(URL(string: "http://google.com")!))
        let message = Message(id: "1", text: "the message", attachment: OneToOne(attachment))
        let chat = Chat(id: "1", messages: OneToMany([message]))
         
        
        var user = User(id: "2", name: "alice")
        user.chats = ManyToMany([chat])
 
        let currentUser = CurrentUser(user: ToOne(user))
 
        user.save(&storage)
        storage.save(user)
        storage.save(user.chats)
        storage.save(user.relation(\.chats, inverse: \.users))

        storage.save(currentUser)
        storage.save(currentUser.user)
        storage.save(currentUser.relation(\.user))

        storage.save(message)
        storage.save(attachment)
        
        let retrievedUser: [Chat] = storage
            .query(User.self, id: "2")
            .related(\.chats)
            .resolve()
            .compactMap { $0 }


        storage.save(message.relation(\.attachment, inverse: \.message))
        storage.save(attachment.relation(\.message, inverse: \.attachment))
        storage.save(user.relation(\.chats, inverse: \.users))

        let attachments: Attachment? = Message
            .query("1", in: storage)
            .related(\.attachment)?
            .resolve()
        
        let messages = Chat.query("1", in: storage)
            .related(\.messages)
            .resolve()
            .compactMap { $0 }
         
        messages
            .map { message in
            (message,
             message
                .query(in: storage)
                .related(\.author)
            )
        }

        let messageAttachment = storage
            .query(Message.self, id: "1")
            .related(\.attachment)?
            .resolve()
        
//        let messages: [Message?]?  = storage
//            .query(User.self, id: "2")
//            .related(\.chats)
//            .related(\.messages)
        
//            .related(\.attachment)?
//            .related(\.message)?
//            .resolve() ?? []
        
        let retrievedMessage = storage
            .query(Attachment.self, id: "1")
            .related(\.message)?
            .resolve()
        
        print(retrievedMessage?.text)
        
        let users: [User] = storage.all()
    }
    
}

