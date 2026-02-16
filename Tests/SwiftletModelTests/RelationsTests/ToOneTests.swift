//
//  File.swift
//
//
//  Created by Serge Kazakov on 13/07/2024.
//

import Foundation
import Testing
import SwiftletModel

@Suite(.tags(.relations, .toOne, .mutual))
struct ToOneTests {
    let initialMessage: Message = Message(
        id: "1", text: "hello",
        attachment: .relation(Attachment.imageOne)
    )

    private func makeContext() throws -> Context {
        var context = Context()
        try initialMessage.save(to: &context)
        return context
    }

    @Test("Direct relation adds inverse relation")
    func whenDirectAdded_InverseIsAdded() throws {
        let context = try makeContext()
        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id)
            .related(\.$message)
            .resolve(in: context)

        #expect(messageForAttachment?.id == Attachment.imageOne.id)
    }

    @Test("Replacing direct relation updates inverse")
    func whenDirectReplaced_InverseIsUpdated() throws {
        var context = try makeContext()
        var message = initialMessage
        message.$attachment = .relation(Attachment.imageTwo)
        try message.save(to: &context)

        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id)
            .related(\.$message)
            .resolve(in: context)

        #expect(messageForAttachment == nil)
    }

    @Test("Nullifying relation removes inverse")
    func whenNullify_InverseIsRemoved() throws {
        var context = try makeContext()
        var message = initialMessage
        message.$attachment = .null
        try message.save(to: &context)

        let messageForAttachment = Attachment
            .query(Attachment.imageOne.id)
            .related(\.$message)
            .resolve(in: context)

        #expect(messageForAttachment == nil)
    }

    @Test("Nullifying relation removes the relation")
    func whenNullify_RelationIsRemoved() throws {
        var context = try makeContext()
        var message = initialMessage
        message.$attachment = .null
        try message.save(to: &context)

        let attachment = message
            .query()
            .related(\.$attachment)
            .resolve(in: context)

        #expect(attachment == nil)
    }
}
