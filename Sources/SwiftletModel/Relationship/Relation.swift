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

    private(set) var state: State<Entity>

    init(state: State<Entity>) {
        self.state = state
    }

    init() {
        state = .none
    }
}

public extension Relation {
    mutating func normalize() {
        state.normalize()
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

extension Relation where Cardinality == Relations.ToMany<Entity> {
    static func appending(_ entities: [Entity], fragment: Bool) -> Self {
        Relation(state: State(entities, slice: true, fragment: fragment))
    }

    static func relation(_ entities: [Entity], fragment: Bool) -> Self {
        Relation(state: State(entities, slice: false, fragment: fragment))
    }
}

extension Relation where Cardinality == Relations.ToOne<Entity> {
    static func relation(_ entity: Entity, fragment: Bool) -> Self {
        Relation(state: State(entity, fragment: fragment))
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
        case .entities(_, let slice, _), .ids(_, let slice):
            return slice ? .append : .replace
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

// MARK: - Private State

extension Relation {

    indirect enum State<T: EntityModelProtocol>: Hashable {
        case id(id: T.ID?)
        case entity(entity: T?, fragment: Bool)
        case ids(ids: [T.ID], slice: Bool)
        case entities(entities: [T], slice: Bool, fragment: Bool)
        case none

        init(_ items: [T], slice: Bool, fragment: Bool) {
            self = .entities(entities: items, slice: slice, fragment: fragment)
        }

        init(ids: [T.ID], slice: Bool) {
            self = .ids(ids: ids, slice: slice)
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

extension Relation.State {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.ids == rhs.ids
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ids)
    }
}
