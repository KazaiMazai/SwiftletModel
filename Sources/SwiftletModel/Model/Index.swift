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
    static var order: Int { 100 }
    
    let id: String
    
    var map: Map<Value, OrderedSet<Entity.ID>> = [:]
    
    @Relationship
    var entities: [Entity]? = nil
    
    init(keyPath: KeyPath<Entity, Value>) {
        id = keyPath.name
    }
    
    static func query(_ keyPath: KeyPath<Entity, Value>,
                      in context: Context) -> [Query<Entity>] {
        
        EntityIndex<Entity, Value>
            .query(keyPath.name, in: context)
            .related(\.$entities)
    }
    
    mutating func insert(_ entity: Entity, keyPath: KeyPath<Entity, Value>) {
        guard var ids = map[entity[keyPath: keyPath]] else {
            map[entity[keyPath: keyPath]] = OrderedSet(arrayLiteral: entity.id)
            return
        }
        
        ids.append(entity.id)
        map[entity[keyPath: keyPath]] = ids
        $entities = .ids(ids.elements)
    }
    
    func willSave(to context: inout Context) throws {
        $entities = .ids(ids.elements)
    }
}
 
//func foo() {
//    var context = Context()
//    let messages: [Message] = Index
//            .query(\Message.createdAt, in: context)
//            .resolve()
    
     

    
//}
