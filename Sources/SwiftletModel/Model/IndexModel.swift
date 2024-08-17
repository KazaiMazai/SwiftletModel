//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 15/08/2024.
//

import Foundation
import BTree
import Collections

@EntityModel
struct IndexModel<Entity: EntityModelProtocol, Value: Comparable> {
    typealias IndexMap = Map<Value, OrderedSet<Entity.ID>>
    var id: String { name }
    
    let name: String
    
    private var indexMap: IndexMap = [:]
    private var values: [Entity.ID: Value] = [:]
    
    init(name: String) {
        self.name = name
    }
    
    var ids: [Entity.ID] { indexMap.flatMap { $0.1.elements } }
}

extension IndexModel {
    mutating func add(_ entity: Entity, value: Value) {
        let existingValue = values[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = indexMap[existingValue] {
            ids.remove(entity.id)
            indexMap[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = indexMap[value] else {
            indexMap[value] = OrderedSet(arrayLiteral: entity.id)
            values[entity.id] = value
            return
        }
        
        ids.append(entity.id)
        indexMap[value] = ids
        values[entity.id] = value
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = values[entity.id] else {
            return
        }
        
        guard var ids = indexMap[value] else {
            return
        }
        
        ids.remove(entity.id)
        indexMap[value] = ids
    }
}

extension IndexModel {
    func filter(_ value: Value) -> [Entity.ID] {
        indexMap[value]?.elements ?? []
    }
    
    func filter(range: Range<Value>) -> [Entity.ID] {
        indexMap
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }
    
    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(indexMap.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
            
    }
}
 
 
