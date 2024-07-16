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
    init<Parent>(inverse: KeyPath<T, Parent>) {
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
