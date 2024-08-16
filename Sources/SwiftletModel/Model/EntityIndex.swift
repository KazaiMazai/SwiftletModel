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
struct EntityIndex<Entity: EntityModelProtocol, Value: Comparable> {
    let id: String
    
    var map: Map<Value, OrderedSet<Entity.ID>> = [:]
    
    
    @Relationship
    var entities: [Entity]? = nil
    
    init(keyPath: KeyPath<Entity, Value>) {
        id = keyPath.name
    }
    
    init<T0, T1>(_ kp0: KeyPath<Entity, T0>,
                 _ kp1: KeyPath<Entity, T1>) where Value == Pair<T0, T1>{
        id = [kp0.name, kp1.name].joined(separator: "-")
    }
    
    init(id: String) {
        self.id = id
    }
    
    static func query(_ keyPath: KeyPath<Entity, Value>,
                      in context: Context) -> [Query<Entity>] {
        
        EntityIndex<Entity, Value>
            .query(keyPath.name, in: context)
            .related(\.$entities)
            
    }
    
    mutating func insert(_ entity: Entity, value keyPath: KeyPath<Entity, Value>) {
        guard var ids = map[entity[keyPath: keyPath]] else {
            map[entity[keyPath: keyPath]] = OrderedSet(arrayLiteral: entity.id)
            return
        }
        
        ids.append(entity.id)
        map[entity[keyPath: keyPath]] = ids
        $entities = .ids(ids.elements)
    }
    
    mutating func insert(_ entity: Entity, value: (Entity) -> Value) {
        guard var ids = map[value(entity)] else {
            map[value(entity)] = OrderedSet(arrayLiteral: entity.id)
            return
        }
        
        ids.append(entity.id)
        map[value(entity)] = ids
        $entities = .ids(ids.elements)
    }
}

extension Query {
    static func indexed<Value: Comparable>(_ keyPath: KeyPath<Entity, Value>,
                             in context: Context) -> [Query<Entity>] {
        
        EntityIndex<Entity, Value>
            .query(keyPath, in: context)
    }
}
 
