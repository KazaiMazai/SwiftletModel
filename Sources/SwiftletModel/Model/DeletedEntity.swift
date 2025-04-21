//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 21/04/2025.
//

import Foundation


public struct Deleted<Entity: EntityModelProtocol> {
    public var id: Entity.ID
    
    public let entity: Entity
    
    init(_ entity: Entity) {
        self.id = entity.id
        self.entity = entity
    }
    
    
}

extension Deleted: EntityModelProtocol {
    public func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
        var copy = self
        try copy.willSave(to: &context)
        
        
        
        context.insert(copy.normalized(), options: options)
        
        
        try deleted?.delete(from: &context)
        try updateMetadata(.updatedAt, value: Date(), in: &context)
        try copy.didSave(to: &context)
    }
    public func delete(from context: inout Context) throws {
        try willDelete(from: &context)
        
        
        context.remove(Self.self, id: id)
        
        try removeFromMetadata(.updatedAt, valueType: Date.self, in: &context)
        try deleted?.save(to: &context)
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
            
        )
    }
}

 
public extension Deleted {
    var deleted: Deleted<Self>? { nil }
    
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
