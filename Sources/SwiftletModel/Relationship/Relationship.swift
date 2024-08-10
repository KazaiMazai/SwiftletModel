//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 09/08/2024.
//

import Foundation

 
@propertyWrapper
public struct Relationship<Value, Entity, Directionality, Cardinality, Constraints>: Hashable
    where
    Cardinality: CardinalityProtocol,
    Cardinality: EntityResolver,
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
}


public extension Relationship where Directionality == Relations.Mutual,
                                    Constraints == Relations.Optional,
                                    Cardinality == Relations.ToOne<Entity> {
    
    init<EnclosingType>(_ direct: KeyPath<EnclosingType, Entity?>, inverse: KeyPath<Entity, EnclosingType?>) {
        self.init(relation: Relation())
    }

    init<EnclosingType>(_ direct: KeyPath<EnclosingType, Entity?>, inverse: KeyPath<Entity, [EnclosingType]?>) {
        self.init(relation: Relation())
    }
}

public extension Relationship where Directionality == Relations.Mutual,
                                    Cardinality == Relations.ToOne<Entity> {
    
    init<EnclosingType>(_ direct: KeyPath<EnclosingType, Entity?>,
                        inverse: KeyPath<Entity, EnclosingType?>,
                        _ constraint: Constraint<Constraints>) {
        self.init(relation: Relation())
    }

    init<EnclosingType>(_ direct: KeyPath<EnclosingType, Entity?>,
                        inverse: KeyPath<Entity, [EnclosingType]?>,
                        _ constraint: Constraint<Constraints>) {
        self.init(relation: Relation())
    }
}

public extension Relationship where Directionality == Relations.Mutual,
                                    Constraints == Relations.Required,
                                    Cardinality == Relations.ToMany<Entity> {
    
    init<EnclosingType>(_ direct: KeyPath<EnclosingType, [Entity]?>, inverse: KeyPath<Entity, EnclosingType?>) {
        self.init(relation: Relation())
    }

    init<EnclosingType>(_ direct: KeyPath<EnclosingType, [Entity]?>, inverse: KeyPath<Entity, [EnclosingType]?>) {
        self.init(relation: Relation())
    }
}

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToOne<Entity>,
                                    Constraints == Relations.Required {
    /**
     This initializer is used by the Swift compiler to autogenerate a convenient initializer
     for the enclosing type that utilizes this property wrapper. It is specifically designed
     for one-way relations.
     
     This is particularly useful when the property
     wrapper is used with a directly provided relation as a default wrapped value.
     
     The initializer takes an optional `ToOneRelation` instance
     and initializes the `Relationship` relation. If the wrapped value is nil, it defaults to `.initial`,
     ensuring that the relation is always properly initialized.
     
     - Parameter wrappedValue: An optional `ToOneRelation` instance that represents the one-way relation.
     */
    init(wrappedValue: Entity) {
        self.init(relation: .relation(wrappedValue))
    }
    
    init(wrappedValue: Entity.ID) {
        self.init(relation: .id(wrappedValue))
    }
}

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToOne<Entity> {
    
    init(_ constraint: Constraint<Constraints>) {
        self.init(relation: Relation())
    }
}

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToOne<Entity>,
                                    Constraints == Relations.Optional {
    /**
     This initializer is used by the Swift compiler to autogenerate a convenient initializer
     for the enclosing type that utilizes this property wrapper. It is specifically designed
     for one-way relations.
     
     This is particularly useful when the property
     wrapper is used with a directly provided relation as a default wrapped value.
     
     The initializer takes an optional `ToOneRelation` instance
     and initializes the `Relationship` relation. If the wrapped value is nil, it defaults to `.initial`,
     ensuring that the relation is always properly initialized.
     
     - Parameter wrappedValue: An optional `ToOneRelation` instance that represents the one-way relation.
     */
    init(wrappedValue: ToOneRelation<Entity, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? Relation())
    }
}

public extension Relationship where Directionality == Relations.OneWay,
                                    Cardinality == Relations.ToMany<Entity>,
                                    Constraints == Relations.Required {
    /**
     This initializer is used by the Swift compiler to autogenerate a convenient initializer
     for the enclosing type that utilizes this property wrapper. It is specifically designed
     for one-way relations.
     
     This is particularly useful when the property
     wrapper is used with a directly provided relation as a default wrapped value.
     
     The initializer takes an optional `ToManyRelation` instance
     and initializes the `HasMany` relation. If the wrapped value is nil, it defaults to `.initial`,
     ensuring that the relation is always properly initialized.
     
     - Parameter wrappedValue: An optional `ToManyRelation` instance that represents the one-way relation.
     */
    init(wrappedValue: ToManyRelation<Entity, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? Relation())
    }
}

public extension Relationship where Cardinality == Relations.ToOne<Entity> {

    static func id(_ id: Entity.ID) -> Self {
        Relationship(relation: .id(id))
    }

    static func relation(_ entity: Entity) -> Self {
        Relationship(relation: .relation(entity))
    }
    
    static func fragment(_ entity: Entity) -> Self {
        Relationship(relation: .fragment( entity))
    }
}


public extension Relationship where Cardinality == Relations.ToMany<Entity> {

    static func ids(_ ids: [Entity.ID]) -> Self {
        Relationship(relation: .ids(ids))
    }

    static func relation(_ entities: [Entity]) -> Self {
        Relationship(relation: .relation(entities))
    }
    
    static func fragment(_ entities: [Entity]) -> Self {
        Relationship(relation: .fragment(entities))
    }

    static func appending(ids: [Entity.ID]) -> Self {
        Relationship(relation: .appending(ids: ids))
    }

    static func appending(relation entities: [Entity]) -> Self {
        Relationship(relation: .appending(relation: entities))
    }
    
    static func appending(fragment entities: [Entity]) -> Self {
        Relationship(relation: .appending(fragment: entities))
    }
}


public extension Relationship where Cardinality == Relations.ToOne<Entity>, Constraints: OptionalRelation {
    static var null: Self {
        Relationship(relation: .null)
    }
}

public extension Relationship where Constraints: OptionalRelation {

    static var none: Self {
        Relationship(relation: Relation())
    }
}

extension Relationship: Codable where Value: Codable, Entity: Codable {

    public func encode(to encoder: Encoder) throws {
        try relation.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try relation = .init(from: decoder)
    }
}



