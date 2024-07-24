//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation
import XCTest
@testable import SwiftletData

final class ToOneTests: XCTestCase {
    var context = Context()
    let initialMessage: Message = Message(
        id: "1", text: "hello",
        attachment: .relation(Attachment.imageOne)
    )
    
    override func setUp() async throws {
        try! initialMessage.save(to: &context)
    }
    
    func test_WhenDirectAdded_InverseIsAdded() {
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id, in: context)
            .related(\.$message)?
            .resolve()
        
        XCTAssertEqual(messageForAttachment?.id, Attachment.imageOne.id)
    }
    
    func test_WhenDirectReplaced_InverseIsUpdated() {
        var message = initialMessage
        message.$attachment = .relation(Attachment.imageTwo)
        try! message.save(to: &context)
        
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id, in: context)
            .related(\.$message)
        
        XCTAssertNil(messageForAttachment)
    }
    
    func test_WhenNullify_InverseIsRemoved() {
        var message = initialMessage
        message.$attachment = .null
        try! message.save(to: &context)
        
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id, in: context)
            .related(\.$message)
        
        XCTAssertNil(messageForAttachment)
    }
    
    func test_WhenNullify_RelationIsRemoved() {
        var message = initialMessage
        message.$attachment = .null
        try! message.save(to: &context)
        
        let attachment = message
            .query(in: context)
            .related(\.$attachment)
        
        XCTAssertNil(attachment)
    }
}
