//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 21/04/2025.
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

extension Deleted: Codable where Entity: Codable { }

public extension Deleted {
    func asDeleted(in context: Context) -> Deleted<Self>? { nil }

    mutating func willSave(to context: inout Context) throws {
        try Entity.delete(id: id, from: &context)
    }

    func restore(in context: inout Context) throws {
        try entity.save(to: &context, options: Entity.defaultMergeStrategy)
        try delete(from: &context)
    }
}
