//
//  Index.ComparableValue.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

import Foundation
import BTree
import Collections

enum SortIndex<Entity: EntityModelProtocol> {
    
}

extension SortIndex {
    
    @EntityModel
    struct ComparableValue<Value: Comparable> {
        var id: String { name }
        
        let name: String
        
        private var index: Map<Value, OrderedSet<Entity.ID>> = [:]
        private var indexedValues: [Entity.ID: Value] = [:]
        
        init(name: String){
            self.name = name
        }
        
        var sorted: [Entity.ID] { index.flatMap { $0.1.elements } }
    }
}

extension SortIndex.ComparableValue {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension SortIndex.ComparableValue {
    mutating func add(_ entity: Entity, value: Value, in: inout Context) throws {
        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = index[existingValue] {
            ids.remove(entity.id)
            index[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = index[value] else {
            index[value] = OrderedSet(arrayLiteral: entity.id)
            indexedValues[entity.id] = value
            return
        }
        
        ids.append(entity.id)
        index[value] = ids
        indexedValues[entity.id] = value
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              var ids = index[value]
        else {
            return
        }
        
        indexedValues[entity.id] = nil
        ids.remove(entity.id)
        index[value] = ids
    }
}

extension SortIndex.ComparableValue {
    func filter(_ value: Value) -> [Entity.ID] {
        index[value]?.elements ?? []
    }
    
    func filter(range: Range<Value>) -> [Entity.ID] {
        index
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }
    
    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(index.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
        
    }
}


