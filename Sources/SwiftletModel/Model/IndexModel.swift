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
    var id: String { name }
    
    let name: String
    
    var index: Map<Value, OrderedSet<Entity.ID>> = [:]
    var values: [Entity.ID: Value] = [:]
    
    @Relationship
    var entities: [Entity]? = nil
    
    
    
    mutating func update(_ entity: Entity, value: Value) {
        let existingValue = values[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = index[existingValue] {
            ids.remove(entity.id)
            index[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = index[value] else {
            index[value] = OrderedSet(arrayLiteral: entity.id)
            values[entity.id] = value
            $entities = .ids([entity.id])
            return
        }
        
        ids.append(entity.id)
        index[value] = ids
        $entities = .ids(ids.elements)
        values[entity.id] = value
    }
}
 
