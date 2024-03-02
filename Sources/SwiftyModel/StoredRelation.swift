//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

extension RelationsRepository {
    enum Option {
        case append
        case replace
    }
}

struct StoredRelation<T: IdentifiableEntity, E: IdentifiableEntity & Codable> {
    let id: T.ID
    let name: String
    let inverseName: String?
    let relation: [Relation<E>]
    let option: RelationsRepository.Option
    let inverseOption: RelationsRepository.Option?
}
