//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

public typealias HasOne<T: EntityModel> = MutualRelation<T, Relations.ToOne, Relations.Optional>

public typealias BelongsTo<T: EntityModel> = MutualRelation<T, Relations.ToOne, Relations.Required>

public typealias HasMany<T: EntityModel> = MutualRelation<T, Relations.ToMany, Relations.Required>

public typealias HasManyNonEmpty<T: EntityModel> = MutualRelation<T, Relations.ToMany, Relations.NonEmpty<T>>

public typealias ToOne<T: EntityModel> = OneWayRelation<T, Relations.ToOne, Relations.Optional>

public typealias FromOne<T: EntityModel> = OneWayRelation<T, Relations.ToOne, Relations.Required>

public typealias ToMany<T: EntityModel> = OneWayRelation<T, Relations.ToMany, Relations.Required>

public typealias ToManyNonEmpty<T: EntityModel> = OneWayRelation<T, Relations.ToMany, Relations.NonEmpty<T>>

public typealias MutualRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Cardinality, Constraint>

public typealias OneWayRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.OneWay, Cardinality, Constraint>

public enum Relations {
    
    public enum OneWay: DirectionalityProtocol { }
    
    public enum Mutual: DirectionalityProtocol { }
    
    public enum ToMany: CardinalityProtocol {
        public static var isToMany: Bool { true }
    }
    
    public enum ToOne: CardinalityProtocol {
        public static var isToMany: Bool { false }
    }
    
    public enum Required: ConstraintsProtocol, RequiredRelation {
        
    }
    
    public enum Optional: ConstraintsProtocol, OptionalRelation {
        
    }
    
    public struct NonEmpty<T: EntityModel>: ConstraintsProtocol, ToManyRelationValidator {
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

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
}

public protocol DirectionalityProtocol { }

public protocol ConstraintsProtocol { }

public protocol RequiredRelation { }

public protocol OptionalRelation { }

public protocol ToManyRelationValidator: ConstraintsProtocol {
    associatedtype Entity: EntityModel
    
    static func validate(models: [Entity]) throws
    
    static func validate(ids: [Entity.ID]) throws
}

public protocol ToOneRelationValidator: ConstraintsProtocol {
    associatedtype Entity: EntityModel
    
    static func validate(model: Entity) throws
}

