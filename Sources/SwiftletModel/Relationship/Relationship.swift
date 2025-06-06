//
//  File.swift
//  
//
//  Created by Serge Kazakov on 09/08/2024.
//

import Foundation

@propertyWrapper
public struct Relationship<Value, Entity, Directionality, Cardinality, Constraints>: Hashable
    where
    Cardinality: CardinalityProtocol,
    Cardinality.Value == Value?,
    Cardinality.Entity == Entity,
    Entity: EntityModelProtocol,
    Directionality: DirectionalityProtocol,
    Constraints: ConstraintsProtocol {

    private var relation: Relation<Entity, Directionality, Cardinality, Constraints>

    public var wrappedValue: Value? {
        Cardinality.entity(relation)
    }

    public var projectedValue: Relation<Entity, Directionality, Cardinality, Constraints> {
        get { relation }
        set { relation = newValue }
    }

    init(relation: Relation<Entity, Directionality, Cardinality, Constraints>) {
        self.relation = relation
    }
}

// MARK: - Mutual Relationship

public extension Relationship where Directionality == Relations.Mutual,
                                    Constraints == Relations.Optional,
                                    Cardinality == Relations.ToOne<Entity> {

    init<EnclosingType>(deleteRule: Relations.DeleteRule = .nullify,
                        inverse: KeyPath<Entity, EnclosingType?>) {
        self.init(relation: .none)
    }
}

public extension Relationship where Directionality == Relations.Mutual,
                                    Cardinality == Relations.ToOne<Entity> {

    init<EnclosingType>(_ constraint: Constraint<Constraints>,
                        deleteRule: Relations.DeleteRule = .nullify,
                        inverse: KeyPath<Entity, EnclosingType?>) {
        self.init(relation: .none)
    }
}

public extension Relationship where Directionality == Relations.Mutual,
                                    Constraints == Relations.Required,
                                    Cardinality == Relations.ToMany<Entity> {

    init<EnclosingType>(deleteRule: Relations.DeleteRule = .nullify,
                        inverse: KeyPath<Entity, EnclosingType?>) {
        self.init(relation: .none)
    }
}

// MARK: - One Way Relationship

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToOne<Entity>,
                                    Constraints == Relations.Optional {

    init(wrappedValue: ToOneRelation<Entity, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? .none)
    }

}

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToOne<Entity> {

    init(_ constraint: Constraint<Constraints> = .optional,
         deleteRule: Relations.DeleteRule = .nullify) {
        self.init(relation: .none)
    }
}

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToMany<Entity>,
                                    Constraints == Relations.Required {

    init(deleteRule: Relations.DeleteRule = .nullify) {
        self.init(relation: .none)
    }

    init(wrappedValue: ToManyRelation<Entity, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? .none)
    }
}

// MARK: - Codable

extension Relationship: Codable where Value: Codable, Entity: Codable, Entity.ID: Codable {

    public func encode(to encoder: Encoder) throws {
        try relation.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try relation = .init(from: decoder)
    }
}

// MARK: - Sendable

extension Relationship: Sendable where Entity: Sendable, Entity.ID: Sendable { }
