//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/07/2024.
//

import Foundation

@propertyWrapper
struct BelongsTo<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                                 Directionality: DirectionalityProtocol,
                                                                 Constraints: ConstraintsProtocol {
    
    private var relation: ToOneRelation<T, Directionality, Constraints>
    
    var wrappedValue: T? {
        get { relation.entities.first }
    }
    
    var projectedValue: ToOneRelation<T, Directionality, Constraints> {
        get { relation }
        set { relation = newValue }
    }
}

extension BelongsTo where Directionality == Relations.Mutual, Constraints == Relations.Required   {
    init<Parent>(inverse: KeyPath<T, Parent>) {
        self.init(relation: .none)
    }
    
    static func relation(id: T.ID) -> Self {
        BelongsTo(relation: .relation(id: id))
    }
    
    static func relation(_ entity: T) -> Self {
        BelongsTo(relation: .relation(entity))
    }
}


extension BelongsTo where Directionality == Relations.OneWay, Constraints == Relations.Required   {
    /**
     This initializer is used by the Swift compiler to autogenerate a convenient initializer
     for the parent struct that utilizes this property wrapper. It is specifically designed
     for one-way relations.
     
     This is particularly useful when the property
     wrapper is used with a directly provided relation as a default wrapped value.
     
     The initializer takes an optional `ToOneRelation` instance
     and initializes the `BelongsTo` relation. If the wrapped value is nil, it defaults to `.none`,
     ensuring that the relation is always properly initialized.
     
     - Parameter wrappedValue: An optional `ToOneRelation` instance that represents the one-way relation.
    */
    init(wrappedValue: ToOneRelation<T, Directionality, Constraints>?) {
        self.init(relation: wrappedValue ?? .none)
    }
}

extension BelongsTo: Codable where T: Codable {
    
    func encode(to encoder: Encoder) throws {
        try relation.encode(to: encoder)
    }
    
    init(from decoder: Decoder) throws {
        try relation = .init(from: decoder)
    }
}
