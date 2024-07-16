//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

public typealias HasOne = Relations.MutualToOneOptional

public typealias BelongsTo = Relations.MutualToOneRequired

public typealias HasMany = Relations.MutualToManyRequired

public typealias HasManyNonEmpty = Relations.MutualToManyNonEmpty

public typealias ToOne = Relations.OneWayToOneOptional

public typealias FromOne = Relations.OneWayToOneRequired

public typealias ToMany = Relations.OneWayToManyRequired

public typealias ToManyNonEmpty = Relations.OneWayToManyNonEmpty

public typealias MutualRelation = Relations.MutualRelation

public typealias OneWayRelation = Relations.OneWayRelation

public typealias MutualToOne = Relations.MutualToOne

public typealias MutualToMany = Relations.MutualToMany

public typealias OneWayToOne = Relations.OneWayToOne

public typealias OneWayToMany = Relations.OneWayToMany

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
    enum Required: ConstraintsProtocol, RequiredRelation { }
    
    enum Optional: ConstraintsProtocol, OptionalRelation {
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

public extension Relations {
    
    typealias MutualToOneOptional<T: EntityModel> = Relation<T, Mutual, ToOne, Optional>

    typealias MutualToOneRequired<T: EntityModel> = Relation<T, Mutual, ToOne, Required>

    typealias MutualToManyRequired<T: EntityModel> = Relation<T, Mutual, ToMany, Required>

    typealias MutualToManyNonEmpty<T: EntityModel> = Relation<T, Mutual, ToMany, NonEmpty>

    typealias OneWayToOneOptional<T: EntityModel> = Relation<T, OneWay, ToOne, Optional>

    typealias OneWayToOneRequired<T: EntityModel> = Relation<T, OneWay, ToOne, Required>

    typealias OneWayToManyRequired<T: EntityModel> = Relation<T, OneWay, ToMany, Required>

    typealias OneWayToManyNonEmpty<T: EntityModel> = Relation<T, OneWay, ToMany, NonEmpty>

    typealias MutualToOne<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Mutual, ToOne, Constraint>

    typealias MutualToMany<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Mutual, ToMany, Constraint>

    typealias OneWayToOne<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, OneWay, ToOne, Constraint>

    typealias OneWayToMany<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, OneWay, ToMany, Constraint>
    
    typealias MutualRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Mutual, Cardinality, Constraint>

    typealias OneWayRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, OneWay, Cardinality, Constraint>
}
