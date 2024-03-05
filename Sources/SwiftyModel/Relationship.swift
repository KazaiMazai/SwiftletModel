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
    init(_ ids: [T.ID]) {
        state = .faulted(ids)
    }

    init(_ entity: [T]) {
        state = .entity(entity)
    }
}

public extension Relationship where Relation == ToManyRelation, Optionality == Required {
    init(_ ids: [T.ID]) {
        state = .faulted(ids)
    }

    init(_ entity: [T]) {
        state = .entity(entity)
    }
}

public extension Relationship where Relation == ToManyRelation, Optionality == RequiredNotEmpty {
    init?(_ ids: [T.ID]) {
        guard !ids.isEmpty else {
            return nil
        }
        state = .faulted(ids)
    }

    init?(_ entity: [T]) {
        guard !entity.isEmpty else {
            return nil
        }
        state = .entity(entity)
    }
}

public extension Relationship where Optionality == NotRequired {
    init() {
        state = .none
    }
}

public extension Relationship where Relation == ToOneRelation {
    init(_ id: T.ID) {
        state = .faulted([id])
    }

    init(_ entity: T) {
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
        case none
        
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
            self = .faulted(ids)
        }
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            lhs.ids == rhs.ids
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(ids)
        }
    }
}
