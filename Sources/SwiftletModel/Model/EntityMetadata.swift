//
//  Metadata.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 19/04/2025.
//

import Foundation


public struct Metadata<Entity: EntityModelProtocol> {
    public var id: Entity.ID
    
    var updatedAt: Date = .distantPast
    var isDeleted: Bool?
   
    init(_ entity: Entity) {
        self.id = entity.id
    }
    
    init(id: Entity.ID) {
        self.id = id
    }
}

extension Metadata: EntityModelProtocol {
    public func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
        var copy = self
        try copy.willSave(to: &context)
        
        
        
        context.insert(copy.normalized(), options: options)
        
        
        try copy.metadata?.save(to: &context)
        try copy.didSave(to: &context)
    }
    public func delete(from context: inout Context) throws {
        try willDelete(from: &context)
        
        
        context.remove(Self.self, id: id)
        
        try metadata?.deleted().save(to: &context)
        try didDelete(from: &context)
    }
    public mutating func normalize() {
        
    }
    
    public static func nestedQueryModifier(_ query: ContextQuery<Self, Optional<Self>, Self.ID>, nested: [Nested]) -> ContextQuery<Self, Optional<Self>, Self.ID> {
        guard let relation = nested.first else {
            return query
        }
        
        let next = Array(nested.dropFirst())
        return switch relation {
        case .ids:
            query
            
        case .fragments:
            query
            
        case .entities:
            query
            
        case .snapshot(let predicate):
            query
            
        }
    }
    
    public static var patch: MergeStrategy<Self> {
        MergeStrategy(
            .patch(\.isDeleted)
        )
    }
}

 
public extension Metadata {
    mutating func willSave(to context: inout Context) throws {
        updatedAt = Date()
        
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
}
