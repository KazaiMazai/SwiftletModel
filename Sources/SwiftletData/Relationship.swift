//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16/07/2024.
//

import Foundation

@propertyWrapper
struct HasOne<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                               Directionality: DirectionalityProtocol,
                                                               Constraints: ConstraintsProtocol {
    
    private var relation: ToOneRelation<T, Directionality, Constraints>
    
    var wrappedValue: T? {
        get { relation.entities.first }
        set { relation = newValue.map { .relation($0) } ?? .none }
    }
    
    var projectedValue: ToOneRelation<T, Directionality, Constraints> {
        get { return relation }
        set { relation = newValue }
    }
}

extension HasOne where Directionality == Relations.Mutual, Constraints == Relations.Optional   {
    init<Parent>(
        inverse: KeyPath<T, Parent>
    ) {
        relation = .none
    }
    
    static func relation(id: T.ID) -> Self {
        HasOne(relation: .relation(id: id))
    }
    
    static func relation(_ entity: T) -> Self {
        HasOne(relation: .relation(entity))
    }
    
    static var null: Self {
        HasOne(relation: .null)
    }
}

extension HasOne where Directionality == Relations.OneWay, Constraints == Relations.Optional   {
    init(wrappedValue: ToOneRelation<T, Directionality, Constraints>?) {
        relation = wrappedValue ?? .none
    }
}

extension HasOne: Codable where T: Codable {
    
}

@propertyWrapper
struct BelongsTo<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                                     Directionality: DirectionalityProtocol,
                                                                     Constraints: ConstraintsProtocol {
    
    private var relation: ToOneRelation<T, Directionality, Constraints>
    
    var wrappedValue: T? {
        get { relation.entities.first }
    }
    
    var projectedValue: ToOneRelation<T, Directionality, Constraints> {
        get { return relation }
        set { relation = newValue }
    }
}

extension BelongsTo where Directionality == Relations.Mutual, Constraints == Relations.Required   {
    init<Parent>(
        inverse: KeyPath<T, Parent>
    ) {
        relation = .none
    }
    
    static func relation(id: T.ID) -> Self {
        BelongsTo(relation: .relation(id: id))
    }
    
    static func relation(_ entity: T) -> Self {
        BelongsTo(relation: .relation(entity))
    }
}

extension BelongsTo where Directionality == Relations.OneWay, Constraints == Relations.Required   {
    init(wrappedValue: ToOneRelation<T, Directionality, Constraints>?) {
        relation = wrappedValue ?? .none
    }
}

extension BelongsTo: Codable where T: Codable {
    
}

@propertyWrapper
struct HasMany<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                                Directionality: DirectionalityProtocol,
                                                                Constraints: ConstraintsProtocol {
    
    private var relation: ToManyRelation<T, Directionality, Constraints>
    
    var wrappedValue: [T]? {
        get { relation.entities }
    }
    
    var projectedValue: ToManyRelation<T, Directionality, Constraints> {
        get { return relation }
        set { relation = newValue }
    }
}

extension HasMany where Directionality == Relations.Mutual, Constraints == Relations.Required   {
    init<Parent>(
        inverse: KeyPath<T, Parent>
    ) {
        relation = .none
    }
    
    static func relation(ids: [T.ID]) -> Self {
        HasMany(relation: .relation(ids: ids))
    }
    
    static func relation(_ entities: [T]) -> Self {
        HasMany(relation: .relation(entities))
    }
    
    static func fragment(ids: [T.ID]) -> Self {
        HasMany(relation: .fragment(ids: ids))
    }
    
    static func fragment(_ entities: [T]) -> Self {
        HasMany(relation: .fragment(entities))
    }
}

extension HasMany where Directionality == Relations.OneWay, Constraints == Relations.Required   {
    init(wrappedValue: ToManyRelation<T, Directionality, Constraints>?) {
        relation = wrappedValue ?? .none
    }
}

extension HasMany: Codable where T: Codable {
    
}


@propertyWrapper
struct Relationship<Value, T, Directionality, Cardinality, Constraints> where T: EntityModel,
                                                                              Value: WrappedEntityValue,
                                                                              Value.Related == T,
                                                                              Directionality: DirectionalityProtocol,
                                                                              Cardinality: CardinalityProtocol,
                                                                              Constraints: ConstraintsProtocol {
    
    private var relation: Relation<T, Directionality, Cardinality, Constraints>
    
    var projectedValue: Relation<T, Directionality, Cardinality, Constraints> {
        get { return relation }
        set { relation = newValue }
    }

    var wrappedValue: Value? {
        get { Value(related: relation.entities) }
    }
}

protocol WrappedEntityValue {
    associatedtype Related: EntityModel
    
    init?(related: [Related])
}

extension Array: WrappedEntityValue where Element: EntityModel {
    init?(related: [Element]) {
        self.init(related)
    }
}

extension WrappedEntityValue where Related == Self {
    init?(related: [Related]) {
        guard let first = related.first else {
            return nil
        }
        self = first
    }
}
 


extension Relationship where Value == Array<T>, Cardinality == Relations.ToMany {
    init(relation: ToManyRelation<T, Directionality, Constraints>) where Value == Array<T>, Cardinality == Relations.ToMany {
        self.relation = relation
    }
}

extension Relationship where Value == T, Cardinality == Relations.ToOne {
    init(relation: ToOneRelation<T, Directionality, Constraints>) where Value == T, Cardinality == Relations.ToOne {
        self.relation = relation
    }
}

extension Relationship where Value == T,
                             Directionality == Relations.Mutual,
                             Constraints == Relations.Optional,
                             Cardinality == Relations.ToOne   {
     
    static var null: Self {
        Relationship(relation: .null)
    }
}

extension Relationship where Value == T,
                             Directionality == Relations.Mutual,
                             Cardinality == Relations.ToOne   {
    init<Parent, InverseCardinality, InverseConstraint>(
        inverse: KeyPath<T, MutualRelation<Parent, InverseCardinality, InverseConstraint>>
    ) {
        self.init(relation: .none)
    }
    
    static func relation(id: T.ID) -> Self {
        Relationship(relation: .relation(id: id))
    }
    
    static func relation(_ entity: T) -> Self {
        Relationship(relation: .relation(entity))
    }
}

extension Relationship where Value == T,
                             Directionality == Relations.Mutual,
                             Cardinality == Relations.ToOne,
                            Constraints == Relations.Required   {
    
    init<Parent, InverseCardinality, InverseConstraint>(
        belongsTo: KeyPath<T, MutualRelation<Parent, InverseCardinality, InverseConstraint>>
    ) {
        self.init(relation: .none)
    }
}

extension Relationship where Value == Array<T>,
                             Directionality == Relations.Mutual,
                             Constraints == Relations.Required,
                             Cardinality == Relations.ToMany   {
    
    init<Parent, InverseCardinality, InverseConstraint>(
        inverse: KeyPath<T, MutualRelation<Parent, InverseCardinality, InverseConstraint>>
    ) {
        self.init(relation: .none)
    }
    
    static func relation(ids: [T.ID]) -> Self {
        Relationship(relation: .relation(ids: ids))
    }
    
    static func relation(_ entities: [T]) -> Self {
        Relationship(relation: .relation(entities))
    }
    
    static func fragment(ids: [T.ID]) -> Self {
        Relationship(relation: .fragment(ids: ids))
    }
    
    static func fragment(_ entities: [T]) -> Self {
        Relationship(relation: .fragment(entities))
    }
}


extension Relationship where Value == Array<T>,
                             Directionality == Relations.OneWay,
                             Constraints == Relations.Required,
                             Cardinality == Relations.ToMany   {
    
    init(wrappedValue: ToManyRelation<T, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? .none)
    }
}

extension Relationship where Value == T,
                             Directionality == Relations.OneWay,
                             Constraints == Relations.Required,
                             Cardinality == Relations.ToOne   {
    
    init(wrappedValue: ToOneRelation<T, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? .none)
    }
}

extension Relationship: Codable where T: Codable, Value: Codable {
    
}
