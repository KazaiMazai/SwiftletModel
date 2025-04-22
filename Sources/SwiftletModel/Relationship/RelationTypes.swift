//
//  File.swift
//  
//
//  Created by Serge Kazakov on 12/07/2024.
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

public enum Relations { }

public extension Relations {
    enum DeleteRule {
        case cascade
        case nullify
    }
}

//MARK: - Directionality

public protocol DirectionalityProtocol { }

public extension Relations {
    enum OneWay: DirectionalityProtocol { }
    
    enum Mutual: DirectionalityProtocol { }
}

//MARK: - Cardinality

public protocol CardinalityProtocol {
    associatedtype Value
    associatedtype Entity: EntityModelProtocol

    static var isToMany: Bool { get }

    static func entity<Directionality, Cardinality, Constraint>(
        _ relation: Relation<Entity, Directionality, Cardinality, Constraint>
    ) -> Value
}

public extension Relations {
    enum ToMany<Entity: EntityModelProtocol> { }
    
    enum ToOne<Entity: EntityModelProtocol> { }
}

extension Relations.ToMany: CardinalityProtocol {

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

extension Relations.ToOne: CardinalityProtocol {

    public static var isToMany: Bool { false }

    public static func entity<Directionality, Cardinality, Constraint>(
        _ relation: Relation<Entity, Directionality, Cardinality, Constraint>) -> Entity?
    where
    Entity: EntityModelProtocol,
    Directionality: DirectionalityProtocol,
    Cardinality: CardinalityProtocol,
    Constraint: ConstraintsProtocol {

        relation.entities.first
    }
}

//MARK: - Constraints

public protocol ConstraintsProtocol { }

public extension Relations {
    enum Required: ConstraintsProtocol { }

    enum Optional: ConstraintsProtocol { }
}

public struct Constraint<C: ConstraintsProtocol> { }

public extension Constraint {
    static var required: Constraint<Relations.Required> {
        Constraint<Relations.Required>()
    }

    static var optional: Constraint<Relations.Optional> {
        Constraint<Relations.Optional>()
    }
}
