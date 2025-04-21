//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 21/04/2025.
//

import Foundation

@EntityModel
public struct Deleted<Entity: EntityModelProtocol> {
    public var id: Entity.ID
    
    public let entity: Entity
    
    init(_ entity: Entity) {
        self.id = entity.id
        self.entity = entity
    }
}
 
public extension Deleted {
    func deleted() -> Deleted<Self>? { nil }
    
    mutating func willSave(to context: inout Context) throws {
        try Entity.query(id, in: context)
            .resolve()?
            .delete(from: &context)
    }
    
    func recover(to context: inout Context) throws {
        try entity.save(to: &context, options: Entity.defaultMergeStrategy)
        try delete(from: &context)
    }
}
