//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 04/08/2024.
//

import Foundation

//MARK: - Relation Extensions

public extension Relation {
    static var none: Self {
        Relation(state: .none)
    }
}

public extension Relation where Cardinality == Relations.ToOne<Entity>,
                                Constraints: OptionalRelation {

    static var null: Self {
        Relation(state: State(nil, fragment: false))
    }
}

public extension Relation where Cardinality == Relations.ToOne<Entity> {
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

public extension Relation where Cardinality == Relations.ToMany<Entity> {
    static func relation(_ entities: [Entity]) -> Self {
        Relation(state: State(entities, slice: false, fragment: false))
    }
    
    static func fragment(_ entities: [Entity]) -> Self {
        Relation(state: State(entities, slice: false, fragment: true))
    }
    
    static func ids(_ ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, slice: false))
    }

    static func appending(relation entities: [Entity]) -> Self {
        Relation(state: State(entities, slice: true, fragment: false))
    }
    
    static func appending(fragment entities: [Entity]) -> Self {
        Relation(state: State(entities, slice: true, fragment: true))
    }
 
    static func appending(ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, slice: true))
    }
}

//MARK: - Relationship Extensions

public extension Relationship where Cardinality == Relations.ToOne<Entity> {

    static func id(_ id: Entity.ID) -> Self {
        Relationship(relation: .id(id))
    }

    static func relation(_ entity: Entity) -> Self {
        Relationship(relation: .relation(entity))
    }
    
    static func fragment(_ entity: Entity) -> Self {
        Relationship(relation: .fragment( entity))
    }
}

public extension Relationship where Cardinality == Relations.ToMany<Entity> {

    static func ids(_ ids: [Entity.ID]) -> Self {
        Relationship(relation: .ids(ids))
    }

    static func relation(_ entities: [Entity]) -> Self {
        Relationship(relation: .relation(entities))
    }
    
    static func fragment(_ entities: [Entity]) -> Self {
        Relationship(relation: .fragment(entities))
    }

    static func appending(ids: [Entity.ID]) -> Self {
        Relationship(relation: .appending(ids: ids))
    }

    static func appending(relation entities: [Entity]) -> Self {
        Relationship(relation: .appending(relation: entities))
    }
    
    static func appending(fragment entities: [Entity]) -> Self {
        Relationship(relation: .appending(fragment: entities))
    }
}

public extension Relationship where Cardinality == Relations.ToOne<Entity>, Constraints: OptionalRelation {
   
    static var null: Self {
        Relationship(relation: .null)
    }
}

public extension Relationship {

    static var none: Self {
        Relationship(relation: .none)
    }
}
