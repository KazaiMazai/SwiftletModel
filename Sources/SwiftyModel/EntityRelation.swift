//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct EntityRelation<T: IdentifiableEntity, E: IdentifiableEntity & Codable> {
    let id: T.ID
    let name: String
    let inverseName: String?
    let relation: [Relation<E>]
    let option: SaveOption
    let inverseOption: SaveOption?
}
