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
    
    mutating func normalize() {
        state.normalize()
    }
    
    func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
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

extension Relation: Codable where Entity: Codable { }

extension Relation.State: Codable where T: Codable { }

extension Relation {
    var ids: [Entity.ID] {
        state.ids
    }
    
    var entities: [Entity] {
        state.entities
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
