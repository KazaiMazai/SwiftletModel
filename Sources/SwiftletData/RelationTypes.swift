//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

public typealias MutualRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Cardinality, Constraint>

public typealias OneWayRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.OneWay, Cardinality, Constraint>

public typealias ManyToOneRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

public typealias OneToOneRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

public typealias OneToManyRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

public typealias ManyToManyRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

public enum Relations { }

public extension Relations {
    enum OneWay: DirectionalityProtocol { }
    
    enum Mutual: DirectionalityProtocol { }
}

public extension Relations {
    enum ToMany: CardinalityProtocol {
        public static var isToMany: Bool { true }
    }
    
    enum ToOne: CardinalityProtocol {
        public static var isToMany: Bool { false }
    }
}

public extension Relations {
    enum Required: RequiredRelation { }
    
    enum Optional: OptionalRelation {
    }
}

public extension Relations {
    enum Errors: Error {
        case empty
        case null
        case wrongCardinality
    }
    
    struct NonEmpty: ConstraintsProtocol, ThrowingConstraint {
        public static func validate(_ relations: (any Collection)?) throws {
            guard let relations else {
                throw Errors.null
            }
            
            guard !relations.isEmpty else {
                throw Errors.empty
            }
        }
    }
}

public protocol DirectionalityProtocol { }

public protocol ConstraintsProtocol {
    static func validate(_ relations: (any Collection)?) throws
}

public protocol RequiredRelation: ConstraintsProtocol {
    
}

extension RequiredRelation {
    public static func validate(_ relations: (any Collection)?) throws {
         
    }
}

public protocol OptionalRelation: ConstraintsProtocol {
     
}

public extension OptionalRelation {
    static func validate(_ relations: (any Collection)?) throws { }
}

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
    
    static func validate(toMany: Bool) throws
    
}

public extension CardinalityProtocol {
    static func validate(toMany: Bool) throws {
        guard isToMany == toMany else {
            throw Relations.Errors.wrongCardinality
        }
    }
}
public protocol ThrowingConstraint: ConstraintsProtocol {
   
}

typealias ToOneRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToOne, Constraint>

typealias ToManyRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToMany, Constraint>

