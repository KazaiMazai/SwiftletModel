//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToOne, Constraint.Optional>
 
public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToMany, Constraint.Optional>
 
public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, Constraint.Optional>

public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, Constraint.Optional>

public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, Constraint.Optional>

public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, Constraint.Optional>



public enum Required {
    public typealias RelationConstraint = Constraint.Required
    
    public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToOne, RelationConstraint>
     
    public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToMany, RelationConstraint>
     
    public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, RelationConstraint>

    public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, RelationConstraint>

    public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, RelationConstraint>

    public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, RelationConstraint>
}

public enum NotEmpty {
    public typealias RelationConstraint = Constraint.NotEmpty
    
    public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToOne, RelationConstraint>
     
    public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToMany, RelationConstraint>
     
    public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, RelationConstraint>

    public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, RelationConstraint>

    public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, RelationConstraint>

    public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, RelationConstraint>
}

public enum Unidirectional { }

public enum Bidirectional { }
 
public protocol RelationProtocol {
    static var isCollection: Bool { get }
}

public enum Relation {
    public enum ToMany: RelationProtocol {
        public static var isCollection: Bool { true }
    }
    
   public enum ToOne: RelationProtocol {
       public static var isCollection: Bool { false }
   }
}

public enum Constraint {
    
    public enum Required {
        
    }

    public enum Optional {
        
    }

    public enum NotEmpty {
        
    }
}

public struct Relationship<T: IdentifiableEntity, Direction, RelationType: RelationProtocol, Constraints>: Hashable {
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


public extension Relationship {
    static var none: Self {
        Relationship(state: .none(explicitNil: false))
    }
}

public extension Relationship where Constraints == Constraint.Optional {
    static var null: Self {
        Relationship(state: .none(explicitNil: true))
    }
}

public extension Relationship where RelationType == Relation.ToMany, Constraints == Constraint.Optional {
    init(ids: [T.ID], elidable: Bool = true) {
        state = .faulted(ids, replace: elidable)
    }

    init(_ entities: [T], elidable: Bool = true) {
        state = .entity(entities, replace: elidable)
    }
}

public extension Relationship where RelationType == Relation.ToMany, Constraints == Constraint.Required {
    init(ids: [T.ID], elidable: Bool = true) {
        state = .faulted(ids, replace: elidable)
    }

    init(entities: [T], elidable: Bool = true) {
        state = .entity(entities, replace: elidable)
    }
}

public extension Relationship where RelationType == Relation.ToMany, Constraints == Constraint.NotEmpty {
    init?(ids: [T.ID], elidable: Bool = true) {
        guard !ids.isEmpty else {
            return nil
        }
        state = .faulted(ids, replace: elidable)
    }

    init?(_ entities: [T], elidable: Bool = true) {
        guard !entities.isEmpty else {
            return nil
        }
        state = .entity(entities, replace: elidable)
    }
}


public extension Relationship where RelationType == Relation.ToOne {
    init(id: T.ID) {
        state = .faulted([id], replace: true)
    }

    init(_ entity: T) {
        state = .entity([entity], replace: true)
    }
}

extension Relationship: Codable where T: Codable {
    
}

extension Relationship.State: Codable where T: Codable {
    
}
 
extension Relationship {
    var directLinkSaveOption: Option {
        switch state {
        case .faulted(_, let replace), .entity(_, let replace):
            return replace ? .replace : .append
        case .none(let explicitNil):
            return explicitNil ? .remove : .append
        }
    }
    
    var inverseLinkSaveOption: Option {
        RelationType.isCollection ? .append : .replace
    }
}

private extension Relationship {
   
   indirect enum State<T: IdentifiableEntity>: Hashable {
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
