//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, ToOneRelation>
 
public typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, ToManyRelation>
 
public typealias ManyToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToOneRelation>

public typealias OneToOne<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToOneRelation>

public typealias OneToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToManyRelation>

public typealias ManyToMany<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToManyRelation>

typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Bidirectional, Relation>

typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Unidirectional, Relation>

public enum Unidirectional: DirectionProtocol { }

public enum Bidirectional: DirectionProtocol { }
 
public enum ToOneRelation: RelationProtocol {
    public static var isCollection: Bool { false }
}

public enum ToManyRelation: RelationProtocol {
    public static var isCollection: Bool { true }
}
 
public protocol RelationProtocol {
    static var isCollection: Bool { get }
}

public protocol DirectionProtocol {
    
}


public struct Relationship<T: IdentifiableEntity, Direction: DirectionProtocol, Relation: RelationProtocol>: Hashable {
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

public extension Relationship where Relation == ToManyRelation {
    init(_ ids: [T.ID]) {
        state = .faulted(ids)
    }

    init(_ entity: [T]) {
        state = .entity(entity)
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
