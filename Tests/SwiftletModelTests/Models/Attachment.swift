//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import SwiftletModel
import Foundation

extension Schema.V1 {
    
    @EntityModel
    struct Attachment: Codable, Sendable {
        let id: String
        var kind: Kind
        
        @Relationship(.required, inverse: \.attachment)
        var message: Message?
        
        enum Kind: Codable {
            case image(url: URL)
            case video(url: URL)
            case file(url: URL)
        }
    }
}
  
