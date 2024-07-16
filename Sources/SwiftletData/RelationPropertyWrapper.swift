//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 16/07/2024.
//

import Foundation


@propertyWrapper
struct _HasMany<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                            Directionality: DirectionalityProtocol,
                                                            Constraints: ConstraintsProtocol {
    
    init(_: Directionality.Type, constraints: Constraints.Type) {
        
    }
    
    var relation: ToManyRelation<T, Directionality, Constraints> = .none
    
    var wrappedValue: ToManyRelation<T, Directionality, Constraints>  {
        get { relation }
        set { relation = newValue }
    }
    
    var projectedValue: _HasMany<T, Directionality, Constraints> {
        self
    }
    
    mutating func set(_ relation: ToManyRelation<T, Directionality, Constraints>) {
        self.relation = relation
    }
}


extension _HasMany: Codable where T: Codable {
    
}

@propertyWrapper
struct One<T, Directionality, Constraints>: Hashable where T: EntityModel,
                                                                         Directionality: DirectionalityProtocol,
                                                                         Constraints: ConstraintsProtocol {
    
    init(_: Directionality.Type, constraints: Constraints.Type) {
        
    }
    
    var relation: ToOneRelation<T, Directionality, Constraints> = .none
    
    var wrappedValue: T? {
        get { relation.entities.first }
//        set { relation = newValue.map { .relation($0) } ?? .none }
    }
    
    var projectedValue: ToOneRelation<T, Directionality, Constraints> {
        get { return relation }
        set { relation = newValue }
    }

}

extension One: Codable where T: Codable {
    
}
