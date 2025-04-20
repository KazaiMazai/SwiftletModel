//
//  Metadata.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 19/04/2025.
//

import Foundation

@EntityModel
public struct Metadata<Entity: EntityModelProtocol> {
    public var id: Entity.ID
    
    var updatedAt: Date = .distantPast
    var isDeleted: Bool?
    
    @Relationship
    var entity: Entity? = .none
    
    init(_ entity: Entity) {
        self.id = entity.id
    }
    
    init(id: Entity.ID) {
        self.id = id
    }
}
 
public extension Metadata {
    mutating func willSave(to context: inout Context) throws {
        updatedAt = Date()
        $entity = .id(id)
        guard let isDeleted, isDeleted else { return }
        try Entity.query(id, in: context)
            .resolve()?
            .delete(from: &context)
    }
  
    func deleted() -> Self {
        var copy = self
        copy.isDeleted = true
        return copy
    }
    
    var metadata: Metadata<Self>? { nil }
    
    static var defaultMergeStrategy: MergeStrategy<Self> { Self.patch }
}
