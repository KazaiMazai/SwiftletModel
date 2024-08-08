//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 04/08/2024.
//

import Foundation

public extension Relation {
    static var none: Self {
        Relation(state: .none)
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: OptionalRelation {

    static var null: Self {
        Relation(state: State(nil, fragment: false))
    }
}

public extension Relation where Cardinality == Relations.ToOne {
    static func id(_ id: Entity.ID) -> Self {
        Relation(state: State(id: id))
    }
    
    static func relation(_ entity: Entity) -> Self {
        Relation(state: State(entity, fragment: false))
    }
    
    static func fragment(_ entity: Entity) -> Self {
        Relation(state: State(entity, fragment: true))
    }
}

public extension Relation where Cardinality == Relations.ToMany {
    static func relation(_ entities: [Entity]) -> Self {
        Relation(state: State(entities, chunk: false, fragment: false))
    }
    
    static func fragment(_ entities: [Entity]) -> Self {
        Relation(state: State(entities, chunk: false, fragment: true))
    }
    
    static func ids(_ ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, chunk: false))
    }

    static func appending(relation entities: [Entity]) -> Self {
        Relation(state: State(entities, chunk: true, fragment: false))
    }
    
    static func appending(fragment entities: [Entity]) -> Self {
        Relation(state: State(entities, chunk: true, fragment: true))
    }
 
    static func appending(ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, chunk: true))
    }
}
