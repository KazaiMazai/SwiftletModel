//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, ToOneRelation, NotRequired>
 
public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, ToManyRelation, NotRequired>
 
public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToOneRelation, NotRequired>

public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToOneRelation, NotRequired>

public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToManyRelation, NotRequired>

public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToManyRelation, NotRequired>

typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Bidirectional, Relation, NotRequired>

typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Unidirectional, Relation, NotRequired>

public enum Unidirectional { }

public enum Bidirectional { }
 
public enum ToOneRelation: RelationProtocol {
    public static var isCollection: Bool { false }
}

public enum ToManyRelation: RelationProtocol {
    public static var isCollection: Bool { true }
}
 
public protocol RelationProtocol {
    static var isCollection: Bool { get }
}


public enum Required {
    
}

public enum NotRequired {
    
}

public enum RequiredNotEmpty {
    
}

public struct Relationship<T: IdentifiableEntity, Direction, Relation: RelationProtocol, Optionality>: Hashable {
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

public extension Relationship where Relation == ToManyRelation, Optionality == NotRequired {
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

public extension Relationship where Relation == ToManyRelation, Optionality == Required {
    init(ids: [T.ID]) {
        state = .faulted(ids)
    }

    init(_ entities: [T]) {
        state = .entity(entities)
    }
}

public extension Relationship where Relation == ToManyRelation, Optionality == RequiredNotEmpty {
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

public extension Relationship where Optionality == NotRequired {
    init() {
        state = .none(explicitNil: false)
    }
}

public extension Relationship where Relation == ToOneRelation, Optionality == Required {
    init(id: T.ID) {
        state = .faulted([id])
    }

    init(_ entity: T) {
        state = .entity([entity])
    }
}

public extension Relationship where Relation == ToOneRelation, Optionality == NotRequired {
   
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
