//
//  File.swift
//
//
//  Created by Sergey Kazakov on 17/07/2024.
//

import Foundation

@propertyWrapper
public struct HasMany<T, Directionality>: Hashable where T: EntityModelProtocol,
                                                  Directionality: DirectionalityProtocol {

    private var relation: ToManyRelation<T, Directionality, Relations.Required>

    public var wrappedValue: [T]? {
        relation.entities
    }

    public var projectedValue: ToManyRelation<T, Directionality, Relations.Required> {
        get { relation }
        set { relation = newValue }
    }
}

public extension HasMany where Directionality == Relations.Mutual {
    init<EnclosingType>(_ direct: KeyPath<EnclosingType, [T]?>, inverse: KeyPath<T, EnclosingType?>) {
        self.init(relation: .none)
    }

    init<EnclosingType>(_ direct: KeyPath<EnclosingType, [T]?>, inverse: KeyPath<T, [EnclosingType]?>) {
        self.init(relation: .none)
    }
}

public extension HasMany {

    static func relation(ids: [T.ID]) -> Self {
        HasMany(relation: .relation(ids: ids))
    }

    static func relation(_ entities: [T]) -> Self {
        HasMany(relation: .relation(entities, fragment: false))
    }
    
    static func relation(fragment entities: [T]) -> Self {
        HasMany(relation: .relation(entities, fragment: true))
    }

    static func chunk(ids: [T.ID]) -> Self {
        HasMany(relation: .chunk(ids: ids))
    }

    static func chunk(_ entities: [T]) -> Self {
        HasMany(relation: .chunk(entities, fragment: false))
    }
    
    static func chunk(fragment entities: [T]) -> Self {
        HasMany(relation: .chunk(entities, fragment: true))
    }
}

public extension HasMany where Directionality == Relations.OneWay {
    /**
     This initializer is used by the Swift compiler to autogenerate a convenient initializer
     for the enclosing type that utilizes this property wrapper. It is specifically designed
     for one-way relations.
     
     This is particularly useful when the property
     wrapper is used with a directly provided relation as a default wrapped value.
     
     The initializer takes an optional `ToManyRelation` instance
     and initializes the `HasMany` relation. If the wrapped value is nil, it defaults to `.none`,
     ensuring that the relation is always properly initialized.
     
     - Parameter wrappedValue: An optional `ToManyRelation` instance that represents the one-way relation.
     */
    init(wrappedValue: ToManyRelation<T, Directionality, Relations.Required>?) {
        self.init(relation: wrappedValue ?? .none)
    }
}

extension HasMany: Codable where T: Codable {

    public func encode(to encoder: Encoder) throws {
        try relation.encode(to: encoder)
    }

    public init(from decoder: Decoder) throws {
        try relation = .init(from: decoder)
    }
}
