//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

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

