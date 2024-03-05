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
        case image(URL)
        case video(URL)
        case file(URL)
    }
}

struct Attachment: IdentifiableEntity, Codable {
    let id: String 
    var kind: Kind
    var message = OneToOne<Message>()
    
    mutating func normalize() {
        message.normalize()
    }
}
