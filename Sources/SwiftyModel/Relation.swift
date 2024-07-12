//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
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

public protocol DirectionalityProtocol {
    
}

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
}

public protocol ConstraintsProtocol {
    
}

public protocol RequiredRelation {
    
}

public protocol OptionalRelation {
    
}

public protocol ToManyRelationValidator: ConstraintsProtocol {
    associatedtype Entity: EntityModel
    
    static func validate(models: [Entity]) throws
    
    static func validate(ids: [Entity.ID]) throws
}


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

public struct Relation<T, Directionality, Cardinality, Constraints>: Hashable where T: EntityModel,
                                                                                    Directionality: DirectionalityProtocol,
                                                                                    Cardinality: CardinalityProtocol,
                                                                                    Constraints: ConstraintsProtocol {
    
    private var state: State<T>
    
    public mutating func normalize() {
        state.normalize()
    }
    
    public func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
    
    var ids: [T.ID] {
        state.ids
    }
    
    var entity: [T] {
        state.entity
    }
}

extension Relation: Storable {
    public func save(_ repository: inout Repository) {
        entity.forEach { $0.save(&repository) }
    }
}

public extension Relation {
    static var none: Self {
        Relation(state: .none(explicitNil: false))
    }
}

public extension Relation where Cardinality == Relations.ToOne {
    static func set(id: T.ID) -> Self {
        Relation(state: .faulted([id], replace: true))
    }
    
    static func set(_ entity: T) -> Self {
        Relation(state: .entity([entity], replace: true))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: OptionalRelation {
    static var null: Self {
        Relation(state: .none(explicitNil: true))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: RequiredRelation {
    
    static func set(ids: [T.ID]) -> Self {
        Relation(state: .faulted(ids, replace: true))
    }
    
    static func set(_ entities: [T]) -> Self {
        Relation(state: .entity(entities, replace: true))
    }
    
    static func append(ids: [T.ID]) -> Self {
        Relation(state: .faulted(ids, replace: false))
    }
    
    static func append(_ entities: [T]) -> Self {
        Relation(state: .entity(entities, replace: false))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: ToManyRelationValidator,
                                Constraints.Entity == T {
    
    static func set(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .faulted(ids, replace: true))
    }
    
    static func set(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .entity(entities, replace: true))
    }
    
    static func append(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .faulted(ids, replace: false))
    }
    
    static func append(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .entity(entities, replace: false))
    }
}


extension Relation: Codable where T: Codable {
    
}

extension Relation.State: Codable where T: Codable {
    
}

extension Relation {
    var directLinkSaveOption: Option {
        switch state {
        case .faulted(_, let replace), .entity(_, let replace):
            return replace ? .replace : .append
        case .none(let explicitNil):
            return explicitNil ? .remove : .append
        }
    }
    
    var inverseLinkSaveOption: Option {
        Cardinality.isToMany ? .append : .replace
    }
}

private extension Relation {
    
    indirect enum State<T: EntityModel>: Hashable {
        case faulted([T.ID], replace: Bool)
        case entity([T], replace: Bool)
        case none(explicitNil: Bool)
        
        var ids: [T.ID] {
            switch self {
            case .faulted(let ids, _):
                return ids
            case .entity(let entity, _):
                return entity.map { $0.id }
            case .none:
                return []
            }
        }
        
        var entity: [T] {
            switch self {
            case .faulted:
                return []
            case .entity(let entity, _):
                return entity
            case .none:
                return []
            }
        }
        
        mutating func normalize() {
            self = .none(explicitNil: false)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.ids == rhs.ids
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ids)
        }
    }
}
