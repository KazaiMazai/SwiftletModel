//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

indirect enum Relation<T: IdentifiableEntity>: Hashable {
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
    
    func normalized() -> Relation<T> {
        var copy = self
        copy.normalize()
        return copy
    }
    
    static func == (lhs: Relation<T>, rhs: Relation<T>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


indirect enum BiRelation<T: IdentifiableEntity>: Hashable {
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
 
    func normalized() -> BiRelation<T> {
        var copy = self
        copy.normalize()
        return copy
    }
    
    mutating func normalize() {
        self = .faulted(id)
    }
    
    func relation() -> Relation<T> {
        Relation.faulted(id)
    }
    
    static func == (lhs: BiRelation<T>, rhs: BiRelation<T>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Relation: Codable where T: Codable {
    
}

extension BiRelation: Codable where T: Codable {
    
}


extension Collection  {
    func getEntities<T>() -> [T] where Element == Relation<T> {
        self.map { $0.entity }
            .compactMap { $0 }
    }
    
    func getIds<T>() -> [T.ID] where Element == Relation<T>  {
        self.map { $0.id }
    }
    
    func `in`<T>(_ repository: Repository) -> [T] where Element == Relation<T> {
        repository.findAllExisting(getIds())
    }
}

extension Array {
    mutating func normalize<T>()where Element == Relation<T> {
        self = map { $0.normalized() }
    }
    
    mutating func normalize<T>()  where Element == BiRelation<T> {
        self = map { $0.normalized() }
    }
}
