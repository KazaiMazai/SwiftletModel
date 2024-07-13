//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation
import XCTest
@testable import SwiftyModel

final class ToOneTests: XCTestCase {
    var repository = Repository()
    let initialMessage: Message = Message(
        id: "1", text: "hello",
        attachment: .relation(Attachment.imageOne)
    )
    
    override func setUp() async throws {
        initialMessage.save(&repository)
    }
    
    func test_WhenDirectAdded_InverseIsAdded() {
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id, in: repository)
            .related(\.message)?
            .resolve()
        
        XCTAssertEqual(messageForAttachment?.id, Attachment.imageOne.id)
    }
    
    func test_WhenDirectReplaced_InverseIsUpdated() {
        var message = initialMessage
        message.attachment = .relation(Attachment.imageTwo)
        message.save(&repository)
        
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id, in: repository)
            .related(\.message)
        
        XCTAssertNil(messageForAttachment)
    }
    
    func test_WhenNullify_InverseIsRemoved() {
        var message = initialMessage
        message.attachment = .nullify
        message.save(&repository)
        
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id, in: repository)
            .related(\.message)
        
        XCTAssertNil(messageForAttachment)
    }
    
    func test_WhenNullify_RelationIsRemoved() {
        var message = initialMessage
        message.attachment = .nullify
        message.save(&repository)
        
        let attachment = message
            .query(in: repository)
            .related(\.attachment)
        
        XCTAssertNil(attachment)
    }
}
