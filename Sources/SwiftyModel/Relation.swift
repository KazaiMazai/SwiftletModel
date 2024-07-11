//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias ToOne<T: EntityModel> = Relation<T, Unidirectional, RelationKind.ToOne, Constraint.Optional>
 
public typealias ToMany<T: EntityModel> = Relation<T, Unidirectional, RelationKind.ToMany, Constraint.Optional>
 
public typealias ManyToOne<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToOne, Constraint.Optional>

public typealias OneToOne<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToOne, Constraint.Optional>

public typealias OneToMany<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToMany, Constraint.Optional>

public typealias ManyToMany<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToMany, Constraint.Optional>



public enum Required {
    public typealias RelationConstraint = Constraint.Required
    
    public typealias ToOne<T: EntityModel> = Relation<T, Unidirectional, RelationKind.ToOne, RelationConstraint>
     
    public typealias ToMany<T: EntityModel> = Relation<T, Unidirectional, RelationKind.ToMany, RelationConstraint>
     
    public typealias ManyToOne<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToOne, RelationConstraint>

    public typealias OneToOne<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToOne, RelationConstraint>

    public typealias OneToMany<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToMany, RelationConstraint>

    public typealias ManyToMany<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToMany, RelationConstraint>
}

public enum NotEmpty {
    public typealias RelationConstraint = Constraint.NotEmpty
    
    public typealias ToOne<T: EntityModel> = Relation<T, Unidirectional, RelationKind.ToOne, RelationConstraint>
     
    public typealias ToMany<T: EntityModel> = Relation<T, Unidirectional, RelationKind.ToMany, RelationConstraint>
     
    public typealias ManyToOne<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToOne, RelationConstraint>

    public typealias OneToOne<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToOne, RelationConstraint>

    public typealias OneToMany<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToMany, RelationConstraint>

    public typealias ManyToMany<T: EntityModel> = Relation<T, Bidirectional, RelationKind.ToMany, RelationConstraint>
}

public enum Unidirectional { }

public enum Bidirectional { }
 
public protocol RelationKindProtocol {
    static var isToMany: Bool { get }
}

extension Relation: Storable {
    public func save(_ repository: inout Repository) {
        entity.forEach { $0.save(&repository) }
    }
}

public enum RelationKind {
    public enum ToMany: RelationKindProtocol {
        public static var isToMany: Bool { true }
    }
    
   public enum ToOne: RelationKindProtocol {
       public static var isToMany: Bool { false }
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

public struct Relation<T: EntityModel, Direction, Kind: RelationKindProtocol, Constraints>: Hashable {
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


public extension Relation {
    static var none: Self {
        Relation(state: .none(explicitNil: false))
    }
}

public extension Relation where Constraints == Constraint.Optional {
    static var null: Self {
        Relation(state: .none(explicitNil: true))
    }
}

public extension Relation where Kind == RelationKind.ToMany, Constraints == Constraint.Optional {
    init(ids: [T.ID], elidable: Bool = true) {
        state = .faulted(ids, replace: elidable)
    }

    init(_ entities: [T], elidable: Bool = true) {
        state = .entity(entities, replace: elidable)
    }
}

public extension Relation where Kind == RelationKind.ToMany, Constraints == Constraint.Required {
    init(ids: [T.ID], elidable: Bool = true) {
        state = .faulted(ids, replace: elidable)
    }

    init(entities: [T], elidable: Bool = true) {
        state = .entity(entities, replace: elidable)
    }
}

public extension Relation where Kind == RelationKind.ToMany, Constraints == Constraint.NotEmpty {
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


public extension Relation where Kind == RelationKind.ToOne {
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
        Kind.isToMany ? .append : .replace
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
