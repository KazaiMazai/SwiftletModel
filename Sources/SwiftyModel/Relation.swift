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
        Relation(state: .ids(ids: [id]))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .relation(items: [entity]))
    }
    
    static var null: Self {
        Relation(state: .none(explicitNil: true))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: RequiredRelation {
    static func relation(id: T.ID) -> Self {
        Relation(state: .ids(ids:[id]))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: .relation(items: [entity]))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: ToOneValidation,
                                Constraints.Entity == T {
    
    static func relation(id: T.ID) -> Self {
        Relation(state: .ids(ids:[id]))
    }
    
    static func relation(_ entity: T) throws -> Self {
        try Constraints.validate(model: entity)
        return Relation(state: .relation(items:[entity]))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: RequiredRelation {
    
    static func relation(ids: [T.ID]) -> Self {
        Relation(state: .ids(ids:ids))
    }
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: .relation(items:entities))
    }
    
    static func fragment(ids: [T.ID]) -> Self {
        Relation(state: .fragmentIds(ids: ids))
    }
    
    static func fragment(_ entities: [T]) -> Self {
        Relation(state: .fragment(items:entities))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: ToManyValidation,
                                Constraints.Entity == T {
    
    static func relation(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .ids(ids: ids))
    }
    
    static func relation(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .relation(items: entities))
    }
    
    static func fragment(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: .fragmentIds(ids: ids))
    }
    
    static func fragment(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: .fragment(items: entities))
    }
}

extension Relation: Codable where T: Codable {
    
}

extension Relation.State: Codable where T: Codable {
    
}

extension Relation {
    var directLinkSaveOption: Option {
        switch state {
        case .ids, .relation:
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
        case ids(ids: [T.ID])
        case relation(items: [T])
        case fragmentIds(ids: [T.ID])
        case fragment(items: [T])
        case none(explicitNil: Bool)
        
        var ids: [T.ID] {
            switch self {
            case .ids(let ids), .fragmentIds(let ids):
                return ids
            case .relation(let entities), .fragment(let entities):
                return entities.map { $0.id }
            case .none:
                return []
            }
        }
        
        var entities: [T] {
            switch self {
            case .ids, .fragmentIds:
                return []
            case .relation(let entities), .fragment(let entities):
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
        Relation(state: .relation(items: [entity]))
    }
}

extension Relation where Cardinality == Relations.ToMany {
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: .relation(items: entities))
    }
}
