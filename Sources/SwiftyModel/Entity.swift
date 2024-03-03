//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Entity<T: IdentifiableEntity> {
    var repository: Repository
    let id: T.ID
    
    init(repository: Repository, id: T.ID) {
        self.repository = repository
        self.id = id
    }
    
    func resolve() -> T? {
        repository.find(id)
    }
}

extension Entity {
    func related<E: IdentifiableEntity, R>(_ keyPath: KeyPath<T, RelatedEntity<E, R>?>) -> Entity<E>? {
        repository
            .findRelations(for: T.self, relationName: keyPath.relationName, id: id)
            .first
            .flatMap { E.ID($0) }
            .map { Entity<E>(repository: repository, id:  $0) }
    }
    
    func related<E: IdentifiableEntity, R>(_ keyPath: KeyPath<T, [RelatedEntity<E, R>]?>) -> [Entity<E>] {
        repository
            .findRelations(for: T.self, relationName: keyPath.relationName, id: id)
            .compactMap { E.ID($0) }
            .map { Entity<E>(repository: repository, id:  $0) }
    }
}
 
