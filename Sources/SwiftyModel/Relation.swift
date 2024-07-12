//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
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

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: OptionalRelation {
    static func relation(id: T.ID) -> Self {
        Relation(state: .faulted([id], replace: true))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .entity([entity], replace: true))
    }
    
    static var nullify: Self {
        Relation(state: .none(explicitNil: true))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: RequiredRelation {
    static func relation(id: T.ID) -> Self {
        Relation(state: .faulted([id], replace: true))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .entity([entity], replace: true))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: ToOneValidation,
                                Constraints.Entity == T {
    
    static func relation(id: T.ID) -> Self {
        Relation(state: .faulted([id], replace: true))
    }
    
    static func relation(_ entity: T) throws -> Self {
        try Constraints.validate(model: entity)
        return Relation(state: .entity([entity], replace: true))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: RequiredRelation {
    
    static func relation(ids: [T.ID]) -> Self {
        Relation(state: .faulted(ids, replace: true))
    }
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: .entity(entities, replace: true))
    }
    
    static func insert(ids: [T.ID]) -> Self {
        Relation(state: .faulted(ids, replace: false))
    }
    
    static func insert(_ entities: [T]) -> Self {
        Relation(state: .entity(entities, replace: false))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: ToManyValidation,
                                Constraints.Entity == T {
    
    static func relation(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .faulted(ids, replace: true))
    }
    
    static func relation(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .entity(entities, replace: true))
    }
    
    static func insert(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .faulted(ids, replace: false))
    }
    
    static func insert(_ entities: [T]) throws -> Self {
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
