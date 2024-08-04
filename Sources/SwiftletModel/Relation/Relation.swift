//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public struct Relation<Entity, Directionality, Cardinality, Constraints>: Hashable
    where
    Entity: EntityModelProtocol,
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
        Relation(state: State(nil, fragment: false))
    }
}

public extension Relation where Cardinality == Relations.ToOne {
    static func relation(id: Entity.ID) -> Self {
        Relation(state: State(id: id))
    }
    
    static func relation(_ entity: Entity, fragment: Bool = false) -> Self {
        Relation(state: State(entity, fragment: fragment))
    }
    
    static func relation(fragment entity: Entity) -> Self {
        Relation(state: State(entity, fragment: true))
    }
}

public extension Relation where Cardinality == Relations.ToMany {
    static func relation(_ entities: [Entity], fragment: Bool = false) -> Self {
        Relation(state: State(entities, chunk: false, fragment: fragment))
    }
    
    static func relation(ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, chunk: false))
    }

    static func chunk(_ entities: [Entity], fragment: Bool = false) -> Self {
        Relation(state: State(entities, chunk: true, fragment: fragment))
    }
 
    static func chunk(ids: [Entity.ID]) -> Self {
        Relation(state: State(ids: ids, chunk: true))
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
        case .entity, .id:
            return .replace
        case .entities(_, let chunk, _), .ids(_, let chunk):
            return chunk ? .append : .replace
        case .none:
            return .append
        }
    }

    static var inverseLinkUpdateOption: Option {
        Cardinality.isToMany ? .append : .replace
    }
    
    var isFragment: Bool {
        switch state {
        case .entity(_, let fragment), .entities(_, _, let fragment):
            return fragment
        case .id, .ids, .none:
            return false
        }
    }
}

extension Relation {
    public func save(_ context: inout Context) throws {
        try entities.forEach {
            try $0.save(
                to: &context,
                options: isFragment ? .fragment : .default
            )
        }
    }
}

// MARK: - Codable

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

// MARK: - Codable Explicitly

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
        case .entity(let value, _):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .entity)
        case .ids(let value, _):
            var container = encoder.container(keyedBy: RelationCodingKeys.self)
            try container.encode(value, forKey: .ids)
        case .entities(let value, _, _):
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
            return Relation(state: .entity(entity: value, fragment: false))
        case .ids:
            let value = try container.decode([Entity.ID].self, forKey: .ids)
            return Relation(state: .ids(ids: value, chunk: false))
        case .entities:
            let value = try container.decode([Entity].self, forKey: .entities)
            return Relation(state: .entities(entities: value, chunk: false, fragment: false))
        case .none:
            return .none
        }
    }
}

// MARK: - Codable Exactly

extension Relation where Entity: Codable {
    enum RelationExplicitCodingKeys: String, CodingKey {
        case id = "id"
        case entity = "object"
        case ids = "ids"
        case entities = "objects"
        case idsChunk = "chunk_ids"
        case chunk = "chunk"
        case none
    }

    func encodeExplicitKeyedContainer(to encoder: Encoder) throws {
        switch state {
        case .id(let value):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .id)
        case .entity(let value, _):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            try container.encode(value, forKey: .entity)
        case .ids(let value, let chunk):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            chunk ?
            try container.encode(value, forKey: .idsChunk)
            : try container.encode(value, forKey: .ids)
           
        case .entities(let value, let chunk, _):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            chunk ? 
            try container.encode(value, forKey: .chunk)
            : try container.encode(value, forKey: .entities)
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
            return Relation(state: .entity(entity: value, fragment: false))
        case .ids:
            let value = try container.decode([Entity.ID].self, forKey: .ids)
            return Relation(state: .ids(ids: value, chunk: false))
        case .entities:
            let value = try container.decode([Entity].self, forKey: .entities)
            return Relation(state: .entities(entities: value, chunk: false, fragment: false))
        case .idsChunk:
            let value = try container.decode([Entity.ID].self, forKey: .idsChunk)
            return Relation(state: .ids(ids: value, chunk: true))
        case .chunk:
            let value = try container.decode([Entity].self, forKey: .chunk)
            return Relation(state: .entities(entities: value, chunk: true, fragment: false))
        case .none:
            return .none
        }
    }
}

// MARK: - Codable Flattaned

extension Relation where Entity: Codable {
    // swiftlint:disable:next type_name
    struct ID<T: EntityModelProtocol>: Codable {
        let id: T.ID
    }

    func encodePlainContainer(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch state {
        case .id(let value):
            try container.encode(value.map { ID<Entity>(id: $0) })
        case .entity(let value, _):
            try container.encode(value)
        case .ids(let value, _):
            try container.encode(value.map { ID<Entity>(id: $0) })
        case .entities(let value, _, _):
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
            return Relation(state: .entity(entity: value, fragment: false))
        }

        if let value = try? container.decode(ID<Entity>?.self) {
            return Relation(state: .id(id: value.id))
        }

        if let value = try? container.decode([Entity].self) {
            return Relation(state: .entities(entities: value, chunk: false, fragment: false))
        }

        if let value = try? container.decode([ID<Entity>].self) {
            return Relation(state: .ids(ids: value.map { $0.id }, chunk: false))
        }

        return .none
    }
}

// MARK: - Private State
// swiftlint:disable file_length
private extension Relation {

    indirect enum State<T: EntityModelProtocol>: Hashable {
        case id(id: T.ID?)
        case entity(entity: T?, fragment: Bool)
        case ids(ids: [T.ID], chunk: Bool)
        case entities(entities: [T], chunk: Bool, fragment: Bool)
        case none

        init(_ items: [T], chunk: Bool, fragment: Bool) {
            self = .entities(entities: items, chunk: chunk, fragment: fragment)
        }

        init(ids: [T.ID], chunk: Bool) {
            self = .ids(ids: ids, chunk: chunk)
        }

        init(id: T.ID?) {
            self = .id(id: id)
        }

        init(_ entity: T?, fragment: Bool) {
            self = .entity(entity: entity, fragment: fragment)
        }
    }
}

private extension Relation.State {
    var ids: [T.ID] {
        switch self {
        case .id(let id):
            return [id].compactMap { $0 }
        case .entity(let entity, _):
            return [entity].compactMap { $0?.id }
        case .ids(let ids, _):
            return ids
        case .entities(let entities, _, _):
            return entities.map { $0.id }
        case .none:
            return []
        }
    }

    var entities: [T] {
        switch self {
        case .id, .ids:
            return []
        case .entity(let entity, _):
            return [entity].compactMap { $0 }
        case .entities(let entities, _, _):
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
