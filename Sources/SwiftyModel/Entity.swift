//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Entity<T: IdentifiableEntity> {
    private let repository: Repository
    let id: T.ID
    
    init(repository: Repository, id: T.ID) {
        self.repository = repository
        self.id = id
    }
    
    func resolve() -> T? {
        repository.find(id)
    }
    
    func related<E: IdentifiableEntity>(_ relationKeyPath: KeyPath<T, Relation<E>?>) -> Entity<E>? {
        repository
            .relations(for: T.self, relationName: relationKeyPath.relationName, id: id)
            .first
            .flatMap { E.ID($0) }
            .map { Entity<E>(repository: repository, id:  $0) }
    }
    
    func related<E: IdentifiableEntity>(_ relationKeyPath: KeyPath<T, [Relation<E>]?>) -> [Entity<E>] {
        repository
            .relations(for: T.self, relationName: relationKeyPath.relationName, id: id)
            .compactMap { E.ID($0) }
            .map { Entity<E>(repository: repository, id:  $0) }
    }
    
    func related<E: IdentifiableEntity>(_ relationKeyPath: KeyPath<T, BiRelation<E>?>) -> Entity<E>? {
        repository
            .relations(for: T.self, relationName: relationKeyPath.relationName, id: id)
            .first
            .flatMap { E.ID($0) }
            .map { Entity<E>(repository: repository, id:  $0) }
    }
    
    func related<E: IdentifiableEntity>(_ relationKeyPath: KeyPath<T, [BiRelation<E>]?>) -> [Entity<E>] {
        repository
            .relations(for: T.self, relationName: relationKeyPath.relationName, id: id)
            .compactMap { E.ID($0) }
            .map { Entity<E>(repository: repository, id:  $0) }
        
    }
}
 
extension Collection {
    func resolve<T>() -> [T?] where Element == Entity<T> {
        map { $0.resolve() }
    }
    
    func related<T, E>(_ relationKeyPath: KeyPath<T, Relation<E>?>) -> [Entity<E>] where Element == Entity<T> {
        compactMap { $0.related(relationKeyPath) }
    }
    
    func related<T, E>(_ relationKeyPath: KeyPath<T, [Relation<E>]?>) -> [[Entity<E>]] where Element == Entity<T> {
        compactMap { $0.related(relationKeyPath) }
    }
    
    func related<T, E>(_ relationKeyPath: KeyPath<T, BiRelation<E>?>) -> [Entity<E>] where Element == Entity<T> {
        compactMap { $0.related(relationKeyPath) }
    }
    
    func related<T, E>(_ relationKeyPath: KeyPath<T, [BiRelation<E>]?>) -> [[Entity<E>]] where Element == Entity<T> {
        compactMap { $0.related(relationKeyPath) }
    }
}
