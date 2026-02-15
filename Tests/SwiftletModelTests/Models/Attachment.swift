//
//  File.swift
//  
//
//  Created by Serge Kazakov on 03/03/2024.
//

import SwiftletModel
import Foundation

extension Schema.V1 {
    @EntityModel
    struct Attachment: Codable, Sendable {
        @HashIndex<Self>(\.kind) var kindIndex
        
        let id: String
        var kind: Kind
    
        @Relationship(.required, inverse: \.attachment)
        var message: Message?
        
        enum Kind: Codable, Hashable {
            case image(url: URL)
            case video(url: URL)
            case file(url: URL)
        }
    }
}

extension Schema.V1 {

    @EntityModel
    struct GenericAttachment<T: Codable & Sendable & Hashable>: Codable, Sendable {
        @HashIndex<Self>(\.kind) private var kindIndex
        
        let id: String
        var kind: T
        
        @Relationship
        var message: Message? = .none

        enum Kind: Codable, Hashable {
            case image(url: URL)
            case video(url: URL)
            case file(url: URL)
            case generic(T)
        }
    }
}

