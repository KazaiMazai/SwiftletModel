//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletData
import Foundation

extension Attachment {
    enum Kind: Codable {
        case image(url: URL)
        case video(url:URL)
        case file(url: URL)
    }
}

struct Attachment: EntityModel, Codable {
    let id: String
    var kind: Kind
    
    @BelongsTo(\.message, inverse: \.attachment)
    var message: Message?
    
    mutating func normalize() {
        $message.normalize()
    }
    
    func save(_ repository: inout Repository) throws {
        repository.save(self)
        try save(\.$message, inverse: \.$attachment, to: &repository)
    }
    
    func delete(_ repository: inout Repository) throws {
        repository.remove(Attachment.self, id: id)
        detach(\.$message, inverse: \.$attachment, in: &repository)
    }
    
}
