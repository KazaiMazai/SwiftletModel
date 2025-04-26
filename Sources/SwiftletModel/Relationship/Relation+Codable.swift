//
//  File.swift
//  
//
//  Created by Serge Kazakov on 04/08/2024.
//

import Foundation

// MARK: - Codable

extension Relation: Codable where Entity: Codable, Entity.ID: Codable {
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

extension Relation where Entity: Codable, Entity.ID: Codable {
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
            return Relation(state: .ids(ids: value, slice: false))
        case .entities:
            let value = try container.decode([Entity].self, forKey: .entities)
            return Relation(state: .entities(entities: value, slice: false, fragment: false))
        case .none:
            return .none
        }
    }
}

// MARK: - Codable Exactly

extension Relation where Entity: Codable, Entity.ID: Codable {
    enum RelationExplicitCodingKeys: String, CodingKey {
        case id = "id"
        case entity = "object"
        case ids = "ids"
        case entities = "objects"
        case idsSlice = "slice_ids"
        case slice = "slice"
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
        case .ids(let value, let slice):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            slice ?
            try container.encode(value, forKey: .idsSlice)
            : try container.encode(value, forKey: .ids)

        case .entities(let value, let slice, _):
            var container = encoder.container(keyedBy: RelationExplicitCodingKeys.self)
            slice ?
            try container.encode(value, forKey: .slice)
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
            return Relation(state: .ids(ids: value, slice: false))
        case .entities:
            let value = try container.decode([Entity].self, forKey: .entities)
            return Relation(state: .entities(entities: value, slice: false, fragment: false))
        case .idsSlice:
            let value = try container.decode([Entity.ID].self, forKey: .idsSlice)
            return Relation(state: .ids(ids: value, slice: true))
        case .slice:
            let value = try container.decode([Entity].self, forKey: .slice)
            return Relation(state: .entities(entities: value, slice: true, fragment: false))
        case .none:
            return .none
        }
    }
}

// MARK: - Codable Flattaned

extension Relation.ID: Codable where Entity.ID: Codable {

}

extension Relation where Entity: Codable, Entity.ID: Codable {
    // swiftlint:disable:next type_name
    struct ID {
        let id: Entity.ID
    }

    func encodePlainContainer(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch state {
        case .id(let value):
            try container.encode(value.map { ID(id: $0) })
        case .entity(let value, _):
            try container.encode(value)
        case .ids(let value, _):
            try container.encode(value.map { ID(id: $0) })
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

        if let value = try? container.decode(ID?.self) {
            return Relation(state: .id(id: value.id))
        }

        if let value = try? container.decode([Entity].self) {
            return Relation(state: .entities(entities: value, slice: false, fragment: false))
        }

        if let value = try? container.decode([ID].self) {
            return Relation(state: .ids(ids: value.map { $0.id }, slice: false))
        }

        return .none
    }
}
