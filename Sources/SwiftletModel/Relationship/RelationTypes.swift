//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

// swiftlint:disable line_length
public typealias MutualRelation<T: EntityModelProtocol,
                                Cardinality: CardinalityProtocol,
                                Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Cardinality, Constraint>

public typealias OneWayRelation<T: EntityModelProtocol,
                                Cardinality: CardinalityProtocol,
                                Constraint: ConstraintsProtocol> = Relation<T, Relations.OneWay, Cardinality, Constraint>

public typealias ManyToOneRelation<T: EntityModelProtocol,
                                   Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne<T>, Constraint>

public typealias OneToOneRelation<T: EntityModelProtocol,
                                  Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne<T>, Constraint>

public typealias OneToManyRelation<T: EntityModelProtocol,
                                   Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany<T>, Constraint>

public typealias ManyToManyRelation<T: EntityModelProtocol,
                                    Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany<T>, Constraint>

public typealias ToOneRelation<T: EntityModelProtocol,
                               Directionality: DirectionalityProtocol,
                               Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToOne<T>, Constraint>

public typealias ToManyRelation<T: EntityModelProtocol,
                                Directionality: DirectionalityProtocol,
                                Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToMany<T>, Constraint>

// swiftlint:enable line_length

public protocol DirectionalityProtocol { }

public protocol ConstraintsProtocol { }


public protocol RequiredRelation: ConstraintsProtocol { }

public protocol OptionalRelation: ConstraintsProtocol { }


public protocol CardinalityProtocol {
    
    
    static var isToMany: Bool { get }
    
    
}

public enum Relations { }
 
public protocol EntityResolver {
    associatedtype Value
    associatedtype Entity: EntityModelProtocol
    
    static func entity<Directionality, Cardinality, Constraint>(_ relation: Relation<Entity, Directionality, Cardinality, Constraint>) -> Value
}

public extension Relations {
    enum OneWay: DirectionalityProtocol { }

    enum Mutual: DirectionalityProtocol { }

    enum ToMany<Entity: EntityModelProtocol>: CardinalityProtocol, EntityResolver {
        public static var isToMany: Bool { true }
        
        public static func entity<Directionality, Cardinality, Constraint>(
            _ relation: Relation<Entity, Directionality, Cardinality, Constraint>) -> [Entity]?
        where
        Entity: EntityModelProtocol,
        Directionality: DirectionalityProtocol,
        Cardinality: CardinalityProtocol,
        Constraint: ConstraintsProtocol {
        
        relation.entities
    }
    }

    enum ToOne<Entity: EntityModelProtocol>: CardinalityProtocol, EntityResolver {
        
        public static func entity<Directionality, Cardinality, Constraint>(
            _ relation: Relation<Entity, Directionality, Cardinality, Constraint>) -> Entity?
        where
        Entity: EntityModelProtocol,
        Directionality: DirectionalityProtocol,
        Cardinality: CardinalityProtocol,
        Constraint: ConstraintsProtocol {
        
        relation.entities.first
    }
        
        
        public static var isToMany: Bool { false }
        

    }

    enum Required: RequiredRelation {
        
    }
    
    enum Optional: OptionalRelation { 
         
    }
}
 
public struct Constraint<C: ConstraintsProtocol> {
     
}

public extension Constraint {
    static var required: Constraint<Relations.Required> {
        Constraint<Relations.Required>()
    }
}

public extension Constraint {
    static var optional: Constraint<Relations.Optional> {
        Constraint<Relations.Optional>()
    }
}
