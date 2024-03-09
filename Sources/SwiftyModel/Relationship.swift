//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToOne, Constraint.Nullable>
 
public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToMany, Constraint.Nullable>
 
public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, Constraint.Nullable>

public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, Constraint.Nullable>

public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, Constraint.Nullable>

public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, Constraint.Nullable>

public enum Required {
    
    public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToOne, Constraint.Required>
     
    public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, Relation.ToMany, Constraint.Required>
     
    public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, Constraint.Required>

    public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToOne, Constraint.Required>

    public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, Constraint.Required>

    public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, Relation.ToMany, Constraint.Required>

}

typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Bidirectional, Relation, Constraint.Nullable>

typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Unidirectional, Relation, Constraint.Nullable>

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

    public enum Nullable {
        
    }

    public enum NotEmpty {
        
    }
}

public struct Relationship<T: IdentifiableEntity, Direction, RelationType: RelationProtocol, Optionality>: Hashable {
    var state: State<T>
    
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

public extension Relationship where RelationType == Relation.ToMany, Optionality == Constraint.Nullable {
    init(ids: [T.ID]?, elidable: Bool = true) {
        guard let ids else {
            state = .none(explicitNil: elidable)
            return
        }
        
        state = .faulted(ids)
    }

    init(_ entities: [T]?, elidable: Bool = true) {
        guard let entities else {
            state = .none(explicitNil: elidable)
            return
        }
        
        state = .entity(entities)
    }
}

public extension Relationship where RelationType == Relation.ToMany, Optionality == Constraint.Required {
    init(ids: [T.ID]) {
        state = .faulted(ids)
    }

    init(_ entities: [T]) {
        state = .entity(entities)
    }
}

public extension Relationship where RelationType == Relation.ToMany, Optionality == Constraint.NotEmpty {
    init?(ids: [T.ID]) {
        guard !ids.isEmpty else {
            return nil
        }
        state = .faulted(ids)
    }

    init?(_ entities: [T]) {
        guard !entities.isEmpty else {
            return nil
        }
        state = .entity(entities)
    }
}

public extension Relationship where Optionality == Constraint.Nullable {
    init() {
        state = .none(explicitNil: false)
    }
}

public extension Relationship where RelationType == Relation.ToOne, Optionality == Constraint.Required {
    init(id: T.ID) {
        state = .faulted([id])
    }

    init(_ entity: T) {
        state = .entity([entity])
    }
}

public extension Relationship where RelationType == Relation.ToOne, Optionality == Constraint.Nullable {
   
    init(id: T.ID?, elidable: Bool = true) {
        guard let id else {
            state = .none(explicitNil: elidable)
            return
        }
        
        state = .faulted([id])
    }

    init(_ entity: T?, elidable: Bool = true) {
        guard let entity else {
            state = .none(explicitNil: elidable)
            return
        }
        
        state = .entity([entity])
    }
}

extension Relationship: Codable where T: Codable {
    
}

extension Relationship.State: Codable where T: Codable {
    
}
 
extension Relationship {
    
    indirect enum State<T: IdentifiableEntity>: Hashable {
        case faulted([T.ID])
        case entity([T])
        case none(explicitNil: Bool)
        
        var ids: [T.ID] {
            switch self {
            case .faulted(let ids):
                return ids
            case .entity(let entity):
                return entity.map { $0.id }
            case .none:
                return []
            }
        }
        
        var entity: [T] {
            switch self {
            case .faulted:
                return []
            case .entity(let entity):
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
