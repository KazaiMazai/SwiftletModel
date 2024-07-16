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
    
    fileprivate init(state: State<T>) {
        self.state = state
    }
}


extension Relation: Storable {
    public func save(_ repository: inout Repository) {
        entities.forEach { entity in entity.save(&repository) }
    }
}

public extension Relation {
    static var none: Self {
        Relation(state: .none)
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: OptionalRelation {
    static func relation(id: T.ID) -> Self {
        Relation(state: State(id: id))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: State(entity))
    }
    
    static var null: Self {
        Relation(state: State(nil))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: RequiredRelation {
    static func relation(id: T.ID) -> Self {
        Relation(state: State(id: id))
    }
    
    static func relation(_ entity: T) -> Self {
        Relation(state: State(entity))
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: ThrowingConstraint {
    
    static func relation(id: T.ID) throws -> Self {
        try Constraints.validate([id])
        return Relation(state: State(id: id))
    }
    
    static func relation(_ entity: T) throws -> Self {
        try Constraints.validate([entity])
        return Relation(state: State(entity))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: RequiredRelation {
    
    static func relation(ids: [T.ID]) -> Self {
        Relation(state: State(ids: ids, fragment: false))
    }
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: State(entities, fragment: false))
    }
    
    static func fragment(ids: [T.ID]) -> Self {
        Relation(state: State(ids: ids, fragment: true))
    }
    
    static func fragment(_ entities: [T]) -> Self {
        Relation(state: State(entities, fragment: true))
    }
}

public extension Relation where Cardinality == Relations.ToMany,
                                Constraints: ThrowingConstraint {
    
    static func relation(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids)
        return Relation(state: State(ids: ids, fragment: false))
    }
    
    static func relation(_ entities: [T]) throws -> Self {
        try Constraints.validate(entities)
        return Relation(state: State(entities, fragment: false))
    }
    
    static func fragment(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids)
        return Relation(state: State(ids: ids, fragment: true))
    }
    
    static func fragment(_ entities: [T]) throws -> Self {
        try Constraints.validate(entities)
        return Relation(state: State(entities, fragment: true))
    }
}

extension Relation: Codable where T: Codable {
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case entity = "object"
        case ids = "ids"
        case entities = "objects"
        case idsFragment = "fragment_ids"
        case entitiesFragment = "fragment"
        case none
    }
    
    public func encode(to encoder: Encoder) throws {
        switch state {
        case .id(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .id)
        case .entity(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .entity)
        case .ids(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .ids)
        case .entities(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .entities)
        case .idsFragment(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .idsFragment)
        case .entitiesFragment(let value):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(value, forKey: .entitiesFragment)
        case .none:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
    public init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self),
              let key = container.allKeys.first else {
            self = .none
            return
        }
        
        switch key {
        case .id:
           let value = try? container.decode(T.ID?.self, forKey: .id)
           try Cardinality.validate(toMany: false)
           try Constraints.validate(value.map { [$0] })
           state = .id(id: value)
        case .entity:
           let value = try? container.decode(T?.self, forKey: .entity)
           try Cardinality.validate(toMany: false)
           try Constraints.validate(value.map { [$0] })
           state = .entity(entity: value)
        case .ids:
            let value = try container.decode([T.ID].self, forKey: .ids)
            try Constraints.validate(value)
            state = .ids(ids: value)
        case .entities:
            let value = try container.decode([T].self, forKey: .entities)
            try Constraints.validate(value)
            state = .entities(entities: value)
        case .idsFragment:
            let value = try container.decode([T.ID].self, forKey: .idsFragment)
            state = .idsFragment(ids: value)
        case .entitiesFragment:
            let value =  try container.decode([T].self, forKey: .entitiesFragment)
            state = .entitiesFragment(entities: value)
        case .none:
            state = .none
        }
    }
}

extension Relation {
    var directLinkSaveOption: Option {
        switch state {
        case .entity, .id, .entities, .ids:
            return .replace
        case .entitiesFragment, .idsFragment:
            return .append
        case .none:
            return .append
        }
    }
    
    var inverseLinkSaveOption: Option {
        Cardinality.isToMany ? .append : .replace
    }
}

private extension Relation {
    
    indirect enum State<Entity: EntityModel>: Hashable {
        case id(id: Entity.ID?)
        case entity(entity: Entity?)
        case ids(ids: [Entity.ID])
        case entities(entities: [Entity])
        case idsFragment(ids: [Entity.ID])
        case entitiesFragment(entities: [Entity])
        case none
        
        init(_ items: [Entity], fragment: Bool) {
            self = fragment ? .entitiesFragment(entities: items) : .entities(entities: items)
        }
        
        init(ids: [Entity.ID], fragment: Bool) {
            self = fragment ? .idsFragment(ids: ids) : .ids(ids: ids)
        }
        
        init(id: Entity.ID?) {
            self = .id(id: id)
        }
        
        init(_ entity: Entity?) {
            self = .entity(entity: entity)
        }
        
        var ids: [Entity.ID] {
            switch self {
            case .id(let id):
                return [id].compactMap { $0 }
            case .entity(let entity):
                return [entity].compactMap { $0?.id }
            case .ids(let ids), .idsFragment(let ids):
                return ids
            case .entities(let entities), .entitiesFragment(let entities):
                return entities.map { $0.id }
            case .none:
                return []
            }
        }
        
        var entities: [Entity] {
            switch self {
            case .id, .ids, .idsFragment:
                return []
            case .entity(let entity):
                return [entity].compactMap { $0 }
            case .entities(let entities), .entitiesFragment(let entities):
                return entities
            case .none:
                return []
            }
        }
        
        mutating func normalize() {
            self = .none
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
        Relation(state: State(entity))
    }
    
    static func relation(id: T.ID) -> Self {
        Relation(state: State(id: id))
    }
}

extension Relation where Cardinality == Relations.ToMany {
    static func relation(_ entities: [T]) -> Self {
        Relation(state: State(entities, fragment: false))
    }
    
    static func relation(ids: [T.ID]) -> Self {
        Relation(state: State(ids: ids, fragment: false))
    }
    
    static func fragment(_ entities: [T]) -> Self {
        Relation(state: State(entities, fragment: true))
    }
    
    static func fragment(ids: [T.ID]) -> Self {
        Relation(state: State(ids: ids, fragment: true))
    }
     
}
