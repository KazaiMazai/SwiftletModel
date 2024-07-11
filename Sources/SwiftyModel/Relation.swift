//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias ToOne<T: EntityModel> = Relation<T, Relations.OneWay, Relations.ToOne, Relations.Optional>
 
public typealias ToMany<T: EntityModel> = Relation<T, Relations.OneWay, Relations.ToMany, Relations.Optional>
 
public typealias ManyToOne<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToOne, Relations.Optional>

public typealias OneToOne<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToOne, Relations.Optional>

public typealias OneToMany<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToMany, Relations.Optional>

public typealias ManyToMany<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToMany, Relations.Optional>

typealias MutualRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Cardinality, Constraint>

typealias OneWayRelation<T: EntityModel, Cardinality: CardinalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Relations.OneWay, Cardinality, Constraint>

typealias ManyToOneRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

typealias OneToOneRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToOne, Constraint>

typealias OneToManyRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

typealias ManyToManyRelation<T: EntityModel, Constraint: ConstraintsProtocol> = Relation<T, Relations.Mutual, Relations.ToMany, Constraint>

typealias ToOneRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToOne, Constraint>

typealias ToManyRelation<T: EntityModel, Directionality: DirectionalityProtocol, Constraint: ConstraintsProtocol> = Relation<T, Directionality, Relations.ToMany, Constraint>

public enum Required {
    public typealias RelationConstraint = Relations.Required
    
    public typealias ToOne<T: EntityModel> = Relation<T, Relations.OneWay, Relations.ToOne, RelationConstraint>
     
    public typealias ToMany<T: EntityModel> = Relation<T, Relations.OneWay, Relations.ToMany, RelationConstraint>
     
    public typealias ManyToOne<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToOne, RelationConstraint>

    public typealias OneToOne<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToOne, RelationConstraint>

    public typealias OneToMany<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToMany, RelationConstraint>

    public typealias ManyToMany<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToMany, RelationConstraint>
}

public enum NotEmpty {
    public typealias RelationConstraint = Relations.NotEmpty
    
    public typealias ToOne<T: EntityModel> = Relation<T, Relations.OneWay, Relations.ToOne, RelationConstraint>
     
    public typealias ToMany<T: EntityModel> = Relation<T, Relations.OneWay, Relations.ToMany, RelationConstraint>
     
    public typealias ManyToOne<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToOne, RelationConstraint>

    public typealias OneToOne<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToOne, RelationConstraint>

    public typealias OneToMany<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToMany, RelationConstraint>

    public typealias ManyToMany<T: EntityModel> = Relation<T, Relations.Mutual, Relations.ToMany, RelationConstraint>
}

public protocol DirectionalityProtocol {
    
}

public protocol CardinalityProtocol {
    static var isToMany: Bool { get }
}

public protocol ConstraintsProtocol {
    
}

public enum Relations {
    
    public enum OneWay: DirectionalityProtocol { }

    public enum Mutual: DirectionalityProtocol { }
     
    public enum ToMany: CardinalityProtocol {
        public static var isToMany: Bool { true }
    }
    
   public enum ToOne: CardinalityProtocol {
       public static var isToMany: Bool { false }
   }
    
    public enum Required: ConstraintsProtocol {
        
    }
    
    public enum Optional: ConstraintsProtocol {
        
    }
    
    public enum NotEmpty: ConstraintsProtocol {
        
    }
}

public struct Relation<T, Directionality, Cardinality, Constraints>: Hashable where T: EntityModel,
                                                                                    Directionality: DirectionalityProtocol,
                                                                                    Cardinality: CardinalityProtocol,
                                                                                    Constraints: ConstraintsProtocol {
        
    private var state: State<T>
    
    public mutating func normalize() {
        state.normalize()
    }
    
    public func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(state)
    }
    
    var ids: [T.ID] {
        state.ids
    }
    
    var entity: [T] {
        state.entity
    }
}

extension Relation: Storable {
    public func save(_ repository: inout Repository) {
        entity.forEach { $0.save(&repository) }
    }
}

public extension Relation {
    static var none: Self {
        Relation(state: .none(explicitNil: false))
    }
}

public extension Relation where Constraints == Relations.Optional {
    static var null: Self {
        Relation(state: .none(explicitNil: true))
    }
}

public extension Relation where Cardinality == Relations.ToMany, Constraints == Relations.Optional {
    init(ids: [T.ID], elidable: Bool = true) {
        state = .faulted(ids, replace: elidable)
    }

    init(_ entities: [T], elidable: Bool = true) {
        state = .entity(entities, replace: elidable)
    }
}

public extension Relation where Cardinality == Relations.ToMany, Constraints == Relations.Required {
    init(ids: [T.ID], elidable: Bool = true) {
        state = .faulted(ids, replace: elidable)
    }

    init(entities: [T], elidable: Bool = true) {
        state = .entity(entities, replace: elidable)
    }
}

public extension Relation where Cardinality == Relations.ToMany, Constraints == Relations.NotEmpty {
    init?(ids: [T.ID], elidable: Bool = true) {
        guard !ids.isEmpty else {
            return nil
        }
        state = .faulted(ids, replace: elidable)
    }

    init?(entities: [T], elidable: Bool = true) {
        guard !entities.isEmpty else {
            return nil
        }
        state = .entity(entities, replace: elidable)
    }
}


public extension Relation where Cardinality == Relations.ToOne {
    init(id: T.ID) {
        state = .faulted([id], replace: true)
    }

    init(_ entity: T) {
        state = .entity([entity], replace: true)
    }
}

extension Relation: Codable where T: Codable {
    
}

extension Relation.State: Codable where T: Codable {
    
}
 
extension Relation {
    var directLinkSaveOption: Option {
        switch state {
        case .faulted(_, let replace), .entity(_, let replace):
            return replace ? .replace : .append
        case .none(let explicitNil):
            return explicitNil ? .remove : .append
        }
    }
    
    var inverseLinkSaveOption: Option {
        Cardinality.isToMany ? .append : .replace
    }
}

private extension Relation {
   
   indirect enum State<T: EntityModel>: Hashable {
       case faulted([T.ID], replace: Bool)
       case entity([T], replace: Bool)
       case none(explicitNil: Bool)
       
       var ids: [T.ID] {
           switch self {
           case .faulted(let ids, _):
               return ids
           case .entity(let entity, _):
               return entity.map { $0.id }
           case .none:
               return []
           }
       }
       
       var entity: [T] {
           switch self {
           case .faulted:
               return []
           case .entity(let entity, _):
               return entity
           case .none:
               return []
           }
       }
       
       mutating func normalize() {
           self = .none(explicitNil: false)
       }
       
       static func == (lhs: Self, rhs: Self) -> Bool {
           lhs.ids == rhs.ids
       }
       
       func hash(into hasher: inout Hasher) {
           hasher.combine(ids)
       }
   }
}
