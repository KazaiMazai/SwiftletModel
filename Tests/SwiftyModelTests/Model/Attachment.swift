//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftyModel
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
    var message: BelongsTo<Message> = .none
    
    mutating func normalize() {
        message.normalize()
    }
    
    func save(_ repository: inout Repository) {
        repository.save(self)
        save(\.message, inverse: \.attachment, to: &repository)
    }
}
