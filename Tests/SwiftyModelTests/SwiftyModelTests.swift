import XCTest
@testable import SwiftyModel

final class SwiftyModelTests: XCTestCase {
   
    func test() {
        var repository = Repository()
        
        let author = User(id: "1", name: "Bob")
        let attachment = Attachment(id: "1", kind: .file(URL(string: "http://google.com")!))
        let message = Message(id: "1", text: "Hello world", author: HasOne(author), attachment: HasOneMutual(attachment))
        let chat = Chat(id: "1", users: HasManyMutual([author], elidable: false), messages: HasManyMutual([message]))
        let user = User(id: "2", name: "Alice", chats: HasManyMutual([chat], elidable: false))
        let currentUser = Current(user: HasOne(user))
        
        currentUser.save(&repository)
           
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
          
        XCTAssertEqual(Chat.query("1", in: repository).related(\.users).count, 2)

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

