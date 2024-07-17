//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/07/2024.
//

import Foundation

@propertyWrapper
struct HasMany<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                               Directionality: DirectionalityProtocol,
                                                               Constraints: ConstraintsProtocol {
    
    private var relation: ToManyRelation<T, Directionality, Constraints>
    
    var wrappedValue: [T]? {
        get { relation.entities }
    }
    
    var projectedValue: ToManyRelation<T, Directionality, Constraints> {
        get { relation }
        set { relation = newValue }
    }
}

extension HasMany where Directionality == Relations.Mutual, Constraints == Relations.Required   {
    init<EnclosingType>(inverse: KeyPath<T, EnclosingType?>, to: EnclosingType.Type) {
        self.init(relation: .none)
    }
    
    init<EnclosingType>(inverse: KeyPath<T, [EnclosingType]?>, to: EnclosingType.Type) {
        self.init(relation: .none)
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
    init(wrappedValue: ToManyRelation<T, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? .none)
    }
}

extension HasMany: Codable where T: Codable {
    
    func encode(to encoder: Encoder) throws {
        try relation.encode(to: encoder)
    }
    
    init(from decoder: Decoder) throws {
        try relation = .init(from: decoder)
    }
}
