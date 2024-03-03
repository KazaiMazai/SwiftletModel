import XCTest
@testable import SwiftyModel

final class SwiftyModelTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
    }
  

    func test() {
        var storage = Repository()
        
        let attachment = Attachment(id: "1", kind: .file(URL(string: "http://google.com")!))
        let message = Message(id: "1", text: "the message", attachment: MutualRelation(attachment))
        let chat = Chat(id: "1", messages: [MutualRelation(message)])
        
       
        var user = User(id: "2", name: "alice")
        user.chats = [MutualRelation(chat)]
        
        let currentUser = CurrentUser(user: Relation(user))
        
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
            .find(User.self, id: "2")
            .related(\.chats)
            .resolve()
            .compactMap { $0 }
        
      
        storage.save(message.relation(\.attachment, inverse: \.message))
        storage.save(attachment.relation(\.message, inverse: \.attachment))
        storage.save(user.relation(\.chats, inverse: \.users))
        
        let attachments = Message
            .find("1", in: storage)
            .related(\.attachment)?
            .resolve()
        
        
        
        
        storage.find(Message.self, id: "1")
            .related(\.attachment)?
            .resolve()
        //
        //let attachments = storage
        //    .get(User.self, id: "2")
        //    .get(\.messages)?
        //    .compactMap { $0 }
        //    .get(\.attachments)
        //    .resolve()
        //    .get(\.messages)?
        //    .get(\.attachments)
        //    .compactMap { $0 }
        //    .get(\Message.attachments)?
        //    .resolve()
        //    .compactMap { $0 } ?? []
        
        let retrievedMessage = storage.find(Attachment.self, id: "1")
            .related(\.message)?
            .resolve()
        
        print(retrievedMessage?.text)
        
        let users: [User] = storage.all()
    }
    
}

