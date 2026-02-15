//
//  GenericAttachment.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 15/02/2026.
//

import SwiftletModel
import Foundation

extension Schema.V1 {

    @EntityModel
    struct GenericAttachment<T: Codable & Sendable & Hashable>: Codable, Sendable {
        @HashIndex<Self>(\.kind) private var kindIndex
        
        let id: String
        var kind: Kind<T>
        
        @Relationship
        var message: Message? = .none

        enum Kind<C: Hashable & Codable>: Codable, Hashable {
            case image(url: URL)
            case video(url: URL)
            case file(url: URL)
            case custom(C)
        }
    }
}
