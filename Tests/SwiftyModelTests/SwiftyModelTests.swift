import XCTest
@testable import SwiftyModel

final class SwiftyModelTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
    }
    
    
    struct User: IdentifiableEntity, Codable {
        
        let id: String
        let name: String
        var messages: [Relation<Message>]?
        var follows: [MutualRelation<User>]?
        var followedBy: [MutualRelation<User>]?
        
        mutating func normalize() {
            messages?.normalize()
            follows?.normalize()
        }
    }

    struct Message: IdentifiableEntity, Codable {
        let id: String
        let text: String
        var attachments: [MutualRelation<Attachment>]?
        
        mutating func normalize() {
            attachments?.normalize()
        }
    }

    struct Attachment: IdentifiableEntity, Codable {
        let id: String
        let link: String
        var message: MutualRelation<Message>?
        
        mutating func normalize() {
            message?.normalize()
        }
    }


    func test() {
        let attachment = Attachment(id: "1", link: "")
        let message = Message(id: "1", text: "the message", attachments: [MutualRelation(attachment)])
        
        var storage = Repository()
        let user = User(id: "2", name: "alice", messages: [Relation(message)])
        
        
        storage.save(user)
        storage.save(user.follows)
        storage.save(user.relation(\.follows, option: .append, inverse: \.followedBy))
        
        storage.save(message)
        storage.save(attachment)
        
        let retrievedUser: [User] = storage
            .find(User.self, id: "2")
            .related(\.followedBy)
            .resolve()
            .compactMap { $0 } ?? []
        
        
        storage.save(message.relation(\.attachments, option: .append, inverse: \.message))
        storage.save(attachment.relation(\.message, inverse: \.attachments))
        storage.save(user.relation(\.messages, option: .append))
        
        let attachments = Message
            .find("1", in: storage)
            .related(\.attachments)
            .resolve()
        
        
        
        storage.find(Message.self, id: "1")
            .related(\.attachments)
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

