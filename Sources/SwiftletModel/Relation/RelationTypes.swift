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
                                   Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

public typealias OneToOneRelation<T: EntityModelProtocol,
                                  Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

public typealias OneToManyRelation<T: EntityModelProtocol,
                                   Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

public typealias ManyToManyRelation<T: EntityModelProtocol,
                                    Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

public typealias ToOneRelation<T: EntityModelProtocol,
                               Directionality: DirectionalityProtocol,
                               Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToOne, Constraint>

public typealias ToManyRelation<T: EntityModelProtocol,
                                Directionality: DirectionalityProtocol,
                                Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToMany, Constraint>

// swiftlint:enable line_length

public protocol DirectionalityProtocol { }

public protocol ConstraintsProtocol { }

public protocol RequiredRelation: ConstraintsProtocol { }

public protocol OptionalRelation: ConstraintsProtocol { }

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
}

public enum Relations { }

public extension Relations {
    enum OneWay: DirectionalityProtocol { }

    enum Mutual: DirectionalityProtocol { }

    enum ToMany: CardinalityProtocol {
        public static var isToMany: Bool { true }
    }

    enum ToOne: CardinalityProtocol {
        public static var isToMany: Bool { false }
    }

    enum Required: RequiredRelation { }

    enum Optional: OptionalRelation { }
}
