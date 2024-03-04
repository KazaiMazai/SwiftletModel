//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

typealias ToOne<T: IdentifiableEntity> = Relationship<T, Unidirectional, ToOneRelation>

typealias ToOneMutual<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToOneRelation>

typealias ToMany<T: IdentifiableEntity> = Relationship<T, Unidirectional, ToManyRelation>

typealias ToManyMutual<T: IdentifiableEntity> = Relationship<T, Bidirectional, ToManyRelation>

typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Bidirectional, Relation>
typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Unidirectional, Relation>

enum Unidirectional: DirectionProtocol { }

enum Bidirectional: DirectionProtocol { }
 
enum ToOneRelation: RelationProtocol {
    static var isCollection: Bool { false }
}

enum ToManyRelation: RelationProtocol {
    static var isCollection: Bool { true }
}
 
protocol RelationProtocol {
    static var isCollection: Bool { get }
}

protocol DirectionProtocol {
}

indirect enum Relationship<T: IdentifiableEntity, Direction: DirectionProtocol, Relation: RelationProtocol>: Hashable {
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

extension Relationship where Relation == ToOneRelation {
    init(_ id: T.ID) {
        self = .faulted([id])
    }

    init(_ entity: T) {
        self = .entity([entity])
    }
}

extension Relationship where Relation == ToManyRelation {
    init(_ ids: [T.ID]) {
        self = .faulted(ids)
    }

    init(_ entity: [T]) {
        self = .entity(entity)
    }
    
    init(_ entity: T) {
        self = .entity([entity])
    }
}
 

extension Relationship: Codable where T: Codable {
    
}


 
