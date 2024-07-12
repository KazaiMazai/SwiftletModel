import XCTest
@testable import SwiftyModel

final class SwiftyModelTests: XCTestCase {
   
    func test() throws {
        var repository = Repository()
        
        let bob = User(id: "1", name: "Bob")
        let alice = User(id: "2", name: "Alice")
        
        let chat = Chat(
            id: "1",
            users: .relation([bob, alice]),
            messages: .relation([
                Message(
                    id: "1",
                    text: "Hey Alice",
                    author: .relation(bob),
                    attachment: .nullify
                ),
                
                Message(
                    id: "2",
                    text: "Hey Bob",
                    author: .relation(alice)
                )
            ])
        )
         
        chat.save(&repository)
        let currentUser = Current(user: .relation(alice))
        currentUser.save(&repository)
        
        
        let updatedChat = Chat(
            id: "1",
            messages: .insert([
                Message(
                    id: "3",
                    text: "It's late, I'm gonna leave",
                    author: .relation(User(id: "1"))
                ),
                Message(
                    id: "4",
                    text: "Bye Alice",
                    author: .relation(User(id: "1"))
                ),
                Message(
                    id: "5",
                    text: "Bye Bye",
                    author: .relation(User(id: "2"))
                )
            ])
        )
        
        updatedChat.save(&repository)
       
           
        let allMessages: [Message] = repository.all()
        
        let retrievedUser: [Chat] = repository
            .query(User.self, id: "2")
            .related(\.chats)
            .resolve()
            .compactMap { $0 }


        let attachments: Attachment? = Message
            .query("1", in: repository)
            .related(\.attachment)?
            .resolve()
        
        let messages = Chat
            .query("1", in: repository)
            .related(\.messages)
            .resolve()
            .compactMap { $0 }
          
        XCTAssertEqual(Chat.query("1", in: repository).related(\.messages).count, 5)
        XCTAssertEqual(
            Attachment
                .query("1", in: repository)
                .related(\.message)?
                .related(\.chat)?
                .related(\.messages).count, 
            5
        )

        let messageAttachment = repository
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
        
        let retrievedMessage = repository
            .query(Attachment.self, id: "1")
            .related(\.message)?
            .resolve()
        
        print(retrievedMessage?.text)
        
        let users: [User] = repository.all()
    }
    
}

