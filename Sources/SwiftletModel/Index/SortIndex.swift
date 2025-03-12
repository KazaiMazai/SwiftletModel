//
//  SortIndex.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

import Foundation
import BTree
import Collections

@EntityModel
struct SortIndex<Entity: EntityModelProtocol, Value: Comparable> {
    var id: String { name }
    
    let name: String
    
    private var sortIndex: Map<Value, OrderedSet<Entity.ID>> = [:]
    private var indexedValues: [Entity.ID: Value] = [:]
    
    init(name: String){
        self.name = name
    }
    
    init(name: String, indexType: IndexType<Entity>) {
        self.name = name
    }
    
    var sorted: [Entity.ID] { sortIndex.flatMap { $0.1.elements } }
}

extension SortIndex {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension SortIndex {
    mutating func add(_ entity: Entity, value: Value, in: inout Context) throws {
        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = sortIndex[existingValue] {
            ids.remove(entity.id)
            sortIndex[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = sortIndex[value] else {
            sortIndex[value] = OrderedSet(arrayLiteral: entity.id)
            indexedValues[entity.id] = value
            return
        }
        
        ids.append(entity.id)
        sortIndex[value] = ids
        indexedValues[entity.id] = value
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
            var ids = sortIndex[value]
        else {
            return
        }
        
        indexedValues[entity.id] = nil
        ids.remove(entity.id)
        sortIndex[value] = ids
    }
}

extension SortIndex {
    func filter(_ value: Value) -> [Entity.ID] {
        sortIndex[value]?.elements ?? []
    }
    
    func filter(range: Range<Value>) -> [Entity.ID] {
        sortIndex
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }
    
    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(sortIndex.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
            
    }
}

 
