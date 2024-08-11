//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

@testable import SwiftletModel
import Foundation

extension Attachment {
    enum Kind: Codable {
        case image(url: URL)
        case video(url: URL)
        case file(url: URL)
    }
}

@EntityModel
struct Attachment: Codable {
    let id: String
    var kind: Kind

    @Relationship(inverse: \.attachment, .required)
    var message: Message?
}
