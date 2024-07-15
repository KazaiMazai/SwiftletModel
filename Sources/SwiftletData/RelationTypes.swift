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
    
    enum Optional: ConstraintsProtocol, OptionalRelation { }
}

public extension Relations {
    
    struct NonEmpty<T: EntityModel>: ConstraintsProtocol, ToManyValidation {
        public enum Errors: Error {
            case empty
        }
         
        public static func validate(models: [T]) throws {
            guard !models.isEmpty else {
                throw Errors.empty
            }
        }
        
        public static func validate(ids: [T.ID]) throws {
            guard !ids.isEmpty else {
                throw Errors.empty
            }
        }
    }
}

public protocol DirectionalityProtocol { }

public protocol ConstraintsProtocol { }

public protocol RequiredRelation { }

public protocol OptionalRelation { }

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
}

public protocol ToManyValidation: ConstraintsProtocol {
    associatedtype Entity: EntityModel
    
    static func validate(models: [Entity]) throws
    
    static func validate(ids: [Entity.ID]) throws
}

public protocol ToOneValidation: ConstraintsProtocol {
    associatedtype Entity: EntityModel
    
    static func validate(model: Entity) throws
}

typealias ToOneRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToOne, Constraint>

typealias ToManyRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToMany, Constraint>

public extension Relations {
    
    typealias MutualToOneOptional<T: EntityModel> = Relation<T, Mutual, ToOne, Optional>

    typealias MutualToOneRequired<T: EntityModel> = Relation<T, Mutual, ToOne, Required>

    typealias MutualToManyRequired<T: EntityModel> = Relation<T, Mutual, ToMany, Required>

    typealias MutualToManyNonEmpty<T: EntityModel> = Relation<T, Mutual, ToMany, NonEmpty<T>>

    typealias OneWayToOneOptional<T: EntityModel> = Relation<T, OneWay, ToOne, Optional>

    typealias OneWayToOneRequired<T: EntityModel> = Relation<T, OneWay, ToOne, Required>

    typealias OneWayToManyRequired<T: EntityModel> = Relation<T, OneWay, ToMany, Required>

    typealias OneWayToManyNonEmpty<T: EntityModel> = Relation<T, OneWay, ToMany, NonEmpty<T>>

    typealias MutualToOne<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Mutual, ToOne, Constraint>

    typealias MutualToMany<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Mutual, ToMany, Constraint>

    typealias OneWayToOne<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, OneWay, ToOne, Constraint>

    typealias OneWayToMany<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, OneWay, ToMany, Constraint>
    
    typealias MutualRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Mutual, Cardinality, Constraint>

    typealias OneWayRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, OneWay, Cardinality, Constraint>
}
