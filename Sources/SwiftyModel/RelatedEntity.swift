//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

typealias Relation<T: IdentifiableEntity> = RelatedEntity<T, Unidirectional>

typealias MutualRelation<T: IdentifiableEntity> = RelatedEntity<T, Bidirectional>

enum Unidirectional { }

enum Bidirectional { }

 
indirect enum RelatedEntity<T: IdentifiableEntity, KindOfRelation> {
    case faulted(T.ID)
    case entity(T)
    
    var id: T.ID {
        switch self {
        case .faulted(let id):
            return id
        case .entity(let entity):
            return entity.id
        }
    }
    
    var entity: T? {
        switch self {
        case .faulted:
            return nil
        case .entity(let entity):
            return entity        }
    }
    
    init(_ id: T.ID) {
        self = .faulted(id)
    }
    
    init(_ entity: T) {
        self = .entity(entity)
    }
 
    mutating func normalize() {
        self = .faulted(id)
    }
    
    func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension RelatedEntity: Codable where T: Codable {
    
}
extension Array {
    mutating func normalize<T, Direction>() where Element == RelatedEntity<T, Direction> {
        self = map { $0.normalized() }
    }
}


enum ToOne: RelationshipKindProtocol {
    static var isCollection: Bool { false }
}

enum ToMany: RelationshipKindProtocol {
    static var isCollection: Bool { true }
}
 
protocol RelationshipKindProtocol {
    static var isCollection: Bool { get }
}

indirect enum Relationship<T: IdentifiableEntity, Direction, Kind: RelationshipKindProtocol> {
    case faulted([T.ID])
    case entity([T])
    
    var ids: [T.ID] {
        switch self {
        case .faulted(let ids):
            return ids
        case .entity(let entity):
            return entity.map { $0.id }
        }
    }
    
    var entity: [T] {
        switch self {
        case .faulted:
            return []
        case .entity(let entity):
            return entity        }
    }
    
 
    mutating func normalize() {
        self = .faulted(ids)
    }
    
    func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.ids == rhs.ids
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ids)
    }
}

extension Relationship where Kind == ToOne {
    init(_ id: T.ID) {
        self = .faulted([id])
    }

    init(_ entity: T) {
        self = .entity([entity])
    }
    
    static var isToMany: Bool {
        false
    }
}

extension Relationship where Kind == ToMany {
    init(_ ids: [T.ID]) {
        self = .faulted(ids)
    }

    init(_ entity: [T]) {
        self = .entity(entity)
    }
    
    static var isToMany: Bool {
        true
    }
}


