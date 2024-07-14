//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation


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
    
    var entities: [T] {
        state.entities
    }
}

extension Relation: Storable {
    public func save(_ repository: inout Repository) {
        entities.forEach { entity in entity.save(&repository) }
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
        Relation(state: .faulted([id]))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .entities([entity]))
    }
    
    static var null: Self {
        Relation(state: .none(explicitNil: true))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: RequiredRelation {
    static func relation(id: T.ID) -> Self {
        Relation(state: .faulted([id]))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .entities([entity]))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: ToOneValidation,
                                Constraints.Entity == T {
    
    static func relation(id: T.ID) -> Self {
        Relation(state: .faulted([id]))
    }
    
    static func relation(_ entity: T) throws -> Self {
        try Constraints.validate(model: entity)
        return Relation(state: .entities([entity]))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: RequiredRelation {
    
    static func relation(ids: [T.ID]) -> Self {
        Relation(state: .faulted(ids))
    }
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: .entities(entities))
    }
    
    static func fragment(ids: [T.ID]) -> Self {
        Relation(state: .fragmentIds(ids))
    }
    
    static func fragment(_ entities: [T]) -> Self {
        Relation(state: .fragment(entities))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: ToManyValidation,
                                Constraints.Entity == T {
    
    static func relation(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .faulted(ids))
    }
    
    static func relation(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .entities(entities))
    }
    
    static func fragment(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .fragmentIds(ids))
    }
    
    static func fragment(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .fragment(entities))
    }
}

extension Relation: Codable where T: Codable {
    
}

extension Relation.State: Codable where T: Codable {
    
}

extension Relation {
    var directLinkSaveOption: Option {
        switch state {
        case .faulted, .entities:
            return .replace
        case .fragment, .fragmentIds:
            return .append
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
        case faulted([T.ID])
        case entities([T])
        case fragmentIds([T.ID])
        case fragment([T])
        
        case none(explicitNil: Bool)
        
        var ids: [T.ID] {
            switch self {
            case .faulted(let ids), .fragmentIds(let ids):
                return ids
            case .entities(let entities), .fragment(let entities):
                return entities.map { $0.id }
            case .none:
                return []
            }
        }
        
        var entities: [T] {
            switch self {
            case .faulted, .fragmentIds:
                return []
            case .entities(let entities), .fragment(let entities):
                return entities
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

extension Relation where Cardinality == Relations.ToOne {
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .entities([entity]))
    }
}

extension Relation where Cardinality == Relations.ToMany {
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: .entities(entities))
    }
}
