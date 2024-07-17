//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

public typealias MutualRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Cardinality, Constraint>

public typealias OneWayRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.OneWay, Cardinality, Constraint>

public typealias ManyToOneRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

public typealias OneToOneRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

public typealias OneToManyRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

public typealias ManyToManyRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

public enum Relations { }

public extension Relations {
    enum OneWay: DirectionalityProtocol { }
    
    enum Mutual: DirectionalityProtocol { }
}

public extension Relations {
    enum ToMany: CardinalityProtocol {
        public static var isToMany: Bool { true }
    }
    
    enum ToOne: CardinalityProtocol {
        public static var isToMany: Bool { false }
    }
}

public extension Relations {
    enum Required: RequiredRelation { }
    
    enum Optional: OptionalRelation { }
}
  
typealias ToOneRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToOne, Constraint>

typealias ToManyRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToMany, Constraint>

