//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public protocol DirectionalityProtocol { }

public protocol ConstraintsProtocol { }

public protocol RequiredRelation: ConstraintsProtocol { }

public protocol OptionalRelation: ConstraintsProtocol { }

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
}

public struct Relation<Entity, Directionality, Cardinality, Constraints>: Hashable where Entity: EntityModel,
                                                                                         Directionality: DirectionalityProtocol,
                                                                                         Cardinality: CardinalityProtocol,
                                                                                         Constraints: ConstraintsProtocol {
    
    private var state: State<Entity>
    
    fileprivate init(state: State<Entity>) {
        self.state = state
    }
}

public extension Relation {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
}

public extension Relation {
    static var none: Self {
        Relation(state: .none)
    }
}

public extension Relation where Cardinality == Relations.ToOne,
                                Constraints: OptionalRelation {
    
    static var null: Self {
        Relation(state: State(nil))
    }
}

public extension Relation where Cardinality == Relations.ToOne {
    static func relation(id: Entity.ID) -> Self {
        Relation(state: State(id: id))
    }
    
    static func relation(_ entity: Entity) -> Self {
        Relation(state: State(entity))
    }
}

public extension Relation where Cardinality == Relations.ToMany {
    static func relation(_ entities: [Entity]) -> Self {
        Relation(state: State(entities, fragment: false))
    }
    
    static func relation(ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, fragment: false))
    }
    
    static func fragment(_ entities: [Entity]) -> Self {
        Relation(state: State(entities, fragment: true))
    }
    
    static func fragment(ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, fragment: true))
    }
}

public extension Relation {
    
    mutating func normalize() {
        state.normalize()
    }
}

extension Relation {
    var ids: [Entity.ID] {
        state.ids
    }
    
    var entities: [Entity] {
        state.entities
    }
}

extension Relation {
    var directLinkUpdateOption: Option {
        switch state {
        case .entity, .id, .entities, .ids:
            return .replace
        case .entitiesFragment, .idsFragment:
            return .append
        case .none:
            return .append
        }
    }
    
    static var inverseLinkUpdateOption: Option {
        Cardinality.isToMany ? .append : .replace
    }
}

extension Relation {
    public func save(_ context: inout Context) throws {
        try entities.forEach { entity in try entity.save(to: &context) }
    }
}


//MARK: -  Private State

private extension Relation {
    
    indirect enum State<T: EntityModel>: Hashable {
        case id(id: T.ID?)
        case entity(entity: T?)
        case ids(ids: [T.ID])
        case entities(entities: [T])
        case idsFragment(ids: [T.ID])
        case entitiesFragment(entities: [T])
        case none
        
        init(_ items: [T], fragment: Bool) {
            self = fragment ? .entitiesFragment(entities: items) : .entities(entities: items)
        }
        
        init(ids: [T.ID], fragment: Bool) {
            self = fragment ? .idsFragment(ids: ids) : .ids(ids: ids)
        }
        
        init(id: T.ID?) {
            self = .id(id: id)
        }
        
        init(_ entity: T?) {
            self = .entity(entity: entity)
        }
    }
}

private extension Relation.State {
    var ids: [T.ID] {
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
    
    var entities: [T] {
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
}

private extension Relation.State {
    mutating func normalize() {
        self = .none
    }
}

private extension Relation.State {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.ids == rhs.ids
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ids)
    }
}


//MARK: - Codable

extension Relation.State: Codable where T: Codable { }

extension Relation: Codable where Entity: Codable {
    public func encode(to encoder: any Encoder) throws {
        switch encoder.relationEncodingStrategy {
        case .plain:
            try encodePlainContainer(to: encoder)
        case .keyedContainer:
            try encodeKeyedContainer(to: encoder)
        case .explicitKeyedContainer:
            try encodeExplicitKeyedContainer(to: encoder)
        }
    }
    
    public init(from decoder: any Decoder) throws {
        if decoder.relationDecodingStrategy.contains(.explicitKeyedContainer),
           let relation = try? Self.decodeExplicitKeyedContainer(from: decoder) {
            
            self = relation
            return
        }
        
        if decoder.relationDecodingStrategy.contains(.keyedContainer),
           let relation = try? Self.decodeKeyedContainer(from: decoder) {
            
            self = relation
            return
        }
        
        self = try Self.decodePlainContainer(from: decoder)
    }
}

//MARK: - Codable Explicitly

extension Relation where Entity: Codable {
    enum RelationCodingKeys: String, CodingKey {
        case id = "id"
        case entity = "object"
        case ids = "ids"
        case entities = "objects"
        case none
    }
    
    func encodeKeyedContainer(to encoder: Encoder) throws {
        switch state {
        case .id(let value):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .id)
        case .entity(let value):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .entity)
        case .ids(let value):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .ids)
        case .entities(let value):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .entities)
        case .idsFragment(let value):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .ids)
        case .entitiesFragment(let value):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .entities)
        case .none:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
    static func decodeKeyedContainer(from decoder: any Decoder) throws -> Relation {
        guard let container = try? decoder.container(keyedBy: RelationCodingKeys.self),
              let key = container.allKeys.first
        else {
            return .none
        }
        
        switch key {
        case .id:
            let value = try? container.decode(Entity.ID?.self, forKey: .id)
            return Relation(state: .id(id: value))
        case .entity:
            let value = try? container.decode(Entity?.self, forKey: .entity)
            return Relation(state: .entity(entity: value))
        case .ids:
            let value = try container.decode([Entity.ID].self, forKey: .ids)
            return Relation(state: .ids(ids: value))
        case .entities:
            let value = try container.decode([Entity].self, forKey: .entities)
            return Relation(state: .entities(entities: value))
        case .none:
            return .none
        }
    }
}

//MARK: - Codable Exactly

extension Relation where Entity: Codable {
    enum RelationExplicitCodingKeys: String, CodingKey {
        case id = "id"
        case entity = "object"
        case ids = "ids"
        case entities = "objects"
        case idsFragment = "fragment_ids"
        case entitiesFragment = "fragment"
        case none
    }
    
    func encodeExplicitKeyedContainer(to encoder: Encoder) throws {
        switch state {
        case .id(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .id)
        case .entity(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .entity)
        case .ids(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .ids)
        case .entities(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .entities)
        case .idsFragment(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .idsFragment)
        case .entitiesFragment(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .entitiesFragment)
        case .none:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
    
    static func decodeExplicitKeyedContainer(from decoder: any Decoder) throws -> Relation {
        guard let container = try? decoder.container(keyedBy: RelationExplicitCodingKeys.self),
              let key = container.allKeys.first
        else {
            return .none
        }
        
        switch key {
        case .id:
            let value = try? container.decode(Entity.ID?.self, forKey: .id)
            return Relation(state: .id(id: value))
        case .entity:
            let value = try? container.decode(Entity?.self, forKey: .entity)
            return Relation(state: .entity(entity: value))
        case .ids:
            let value = try container.decode([Entity.ID].self, forKey: .ids)
            return Relation(state: .ids(ids: value))
        case .entities:
            let value = try container.decode([Entity].self, forKey: .entities)
            return Relation(state: .entities(entities: value))
        case .idsFragment:
            let value = try container.decode([Entity.ID].self, forKey: .idsFragment)
            return Relation(state: .idsFragment(ids: value))
        case .entitiesFragment:
            let value = try container.decode([Entity].self, forKey: .entitiesFragment)
            return Relation(state: .entitiesFragment(entities: value))
        case .none:
            return .none
        }
    }
}

//MARK: - Codable Flattaned

extension Relation where Entity: Codable {
    struct ID<T: EntityModel>: Codable {
        let id: T.ID
    }
    
    func encodePlainContainer(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch state {
        case .id(let value):
            try container.encode(value.map { ID<Entity>(id: $0) })
        case .entity(let value):
            try container.encode(value)
        case .ids(let value):
            try container.encode(value.map { ID<Entity>(id: $0) })
        case .entities(let value):
            try container.encode(value)
        case .idsFragment(let value):
            try container.encode(value.map{ ID<Entity>(id: $0) })
        case .entitiesFragment(let value):
            try container.encode(value)
        case .none:
            try container.encodeNil()
        }
    }
    
    static func decodePlainContainer(from decoder: any Decoder) throws -> Relation {
        guard let container = try? decoder.singleValueContainer() else {
            return .none
        }
        
        if let value = try? container.decode(Entity?.self) {
            return Relation(state: .entity(entity: value))
        }
        
        if let value = try? container.decode(ID<Entity>?.self) {
            return Relation(state: .id(id: value.id))
        }
        
        if let value = try? container.decode([Entity].self) {
            return Relation(state: .entities(entities: value))
        }
        
        if let value = try? container.decode([ID<Entity>].self) {
            return Relation(state: .ids(ids: value.map { $0.id }))
        }
        
        return .none
    }
}
