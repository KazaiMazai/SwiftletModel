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

extension Relation: Codable where T: Codable {
    
    public init(from decoder: Decoder) throws where T: Codable {
        let topLevelContainer = try decoder.singleValueContainer()
        state = try topLevelContainer.decode(State.self)
    }

    public func encode(to encoder: Encoder) throws where T: Codable {
       try state.encode(to: encoder)
//        var topLevelContainer = encoder.singleValueContainer()
//        if state == .none {
//            try topLevelContainer.encodeNil()
//            return
//        }
//        try topLevelContainer.encode(state)
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
                                Constraints: ToOneValidation,
                                Constraints.Entity == T {
    
    static func relation(id: T.ID) -> Self {
        Relation(state: State(id: id))
    }
    
    static func relation(_ entity: T) throws -> Self {
        try Constraints.validate(model: entity)
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
                                Constraints: ToManyValidation,
                                Constraints.Entity == T {
    
    static func relation(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: State(ids: ids, fragment: false))
    }
    
    static func relation(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: State(entities, fragment: false))
    }
    
    static func fragment(ids: [T.ID]) throws -> Self {
        try Constraints.validate(ids: ids)
        return Relation(state: State(ids: ids, fragment: true))
    }
    
    static func fragment(_ entities: [T]) throws -> Self {
        try Constraints.validate(models: entities)
        return Relation(state: State(entities, fragment: true))
    }
}

extension Relation {
    var directLinkSaveOption: Option {
        switch state {
        case .entity:
            return .replace
        case .entities(_, _, let fragment):
            return fragment ? .append : .replace
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
        case entity(id: Entity.ID?, entity: Entity?)
        case entities(ids: [Entity.ID], items: [Entity]?, fragment: Bool)
        case none
        
        init(_ items: [Entity], fragment: Bool) {
            self = .entities(ids: items.map { $0.id} , items: items, fragment: fragment)
        }
        
        init(ids: [Entity.ID], fragment: Bool) {
            self = .entities(ids: ids , items: nil, fragment: fragment)
        }
        
        init(id: Entity.ID?) {
            self = .entity(id: id, entity: nil)
        }
        
        init(_ entity: Entity?) {
            self = .entity(id: entity?.id, entity: entity)
        }
        
        var ids: [Entity.ID] {
            switch self {
            case .entity(let ids, _):
                return [ids].compactMap { $0 }
            case .entities(let ids, _, _):
                return ids
            case .none:
                return []
            }
        }
        
        var entities: [Entity] {
            switch self {
            case .entity(_, let entity):
                return [entity].compactMap { $0 }
            case .entities(_, let entities, _):
                return entities ?? []
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

extension Relation.State: Codable where Entity: Codable {
//    enum CodingKeys: String, CodingKey {
//        case ids
//        case included = "items"
//        case fragmentIds
//        case fragment
//        case none
//    }
//    
//    enum IdsCodingKeys: String, CodingKey {
//        case ids = "relation"
//    }
//    
//    enum IncludedCodingKeys: String, CodingKey {
//        case items = "relation"
//    }
//    
//    enum FragmentIdsCodingKeys: String, CodingKey {
//        case ids = "relation"
//    }
//    
//    enum FragmentCodingKeys: String, CodingKey {
//        case items = "relation"
//    }

//    init(from decoder: Decoder) throws where T: Codable {
//        var topLevelContainer = try decoder.singleValueContainer()
//        self = try topLevelContainer.decode(RelationState.self)
//    }
//
//    func encode(to encoder: Encoder) throws where T: Codable {
//        var topLevelContainer = encoder.singleValueContainer()
//        try topLevelContainer.encode(self)
//    }
    
//    
//    func encode(to encoder: Encoder) throws {
//        
//        switch self {
//        case .ids(let state):
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(state, forKey: .ids)
//        case .included(items: let items):
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(items, forKey: .included)
//        case .fragmentIds(let ids):
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(ids, forKey: .fragmentIds)
//        case .fragment(let items):
//            var container = encoder.container(keyedBy: CodingKeys.self)
//            try container.encode(items, forKey: .fragment)
//        case .none:
//            var container = encoder.singleValueContainer()
//            try container.encodeNil()
//        }
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        guard let key = container.allKeys.first else {
//            self = .none
//            return
//        }
//        
//        switch key {
//        case .ids:
//            self = .ids(ids: try container.decode([Entity.ID].self, forKey: .ids))
//        case .included:
//            self = .included(items: try container.decode([Entity].self, forKey: .included))
//        case .fragmentIds:
//            self = .fragmentIds(ids: try container.decode([Entity.ID].self, forKey: .fragmentIds))
//        case .fragment:
//            self = .fragment(items: try container.decode([Entity].self, forKey: .fragment))
//        case .none:
//            self = .none
//        }
//    }
}


extension Relation where Cardinality == Relations.ToOne {
    
    static func relation(_ entity: T) -> Self {
        Relation(state: State(entity))
    }
}

extension Relation where Cardinality == Relations.ToMany {
    
    static func relation(_ entities: [T]) -> Self {
        Relation(state: State(entities, fragment: false))
    }
}

struct SomeDetails: Codable {
    let count: Int
    let name: String
    let type: String
}


struct SomeObject: Codable {
    let id: Int
    let details: SomeDetails

    enum CodingKeys: String, CodingKey {
        case id
    }

    enum DetailKeys: String, CodingKey {
        case count, name, type
    }

    init(from decoder: Decoder) throws {
        let topLevelContainer = try decoder.container(keyedBy: CodingKeys.self)
        let detailContainer = try decoder.container(keyedBy: DetailKeys.self)

        id = try topLevelContainer.decode(Int.self, forKey: .id)
        details = SomeDetails(
            count: try detailContainer.decode(Int.self, forKey: .count),
            name: try detailContainer.decode(String.self, forKey: .name),
            type: try detailContainer.decode(String.self, forKey: .type))
    }

    func encode(to encoder: Encoder) throws {
        var topLevelContainer = encoder.container(keyedBy: CodingKeys.self)
        try topLevelContainer.encode(id, forKey: .id)

        var detailContainer = encoder.container(keyedBy: DetailKeys.self)
        try detailContainer.encode(details.count, forKey: .count)
        try detailContainer.encode(details.name, forKey: .name)
        try detailContainer.encode(details.type, forKey: .type)
    }
}
