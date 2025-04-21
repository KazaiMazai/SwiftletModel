//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 21/04/2025.
//

import Foundation

@EntityModel
public struct Deleted<Entity: EntityModelProtocol> {
    public var id: Entity.ID { entity.id }
    public let entity: Entity
    
    init(_ entity: Entity) {
        self.entity = entity
    }
}
 
public extension Deleted {
    func asDeleted() -> Deleted<Self>? { nil }
    
    mutating func willSave(to context: inout Context) throws {
        try Entity.delete(id: id, from: &context)
    }
    
    func restore(in context: inout Context) throws {
        try entity.save(to: &context, options: Entity.defaultMergeStrategy)
        try delete(from: &context)
    }
}
