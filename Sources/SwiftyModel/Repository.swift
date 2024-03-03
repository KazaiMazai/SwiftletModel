//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Repository {
    private var entitiesRepository = EntitiesRepository()
    private var relationsRepository = RelationsRepository()
}

extension Repository {
    func find<T: IdentifiableEntity>(_ id: T.ID) -> Entity<T> {
        find(T.self, id: id)
    }
    
    func find<T: IdentifiableEntity>(_ type: T.Type, id: T.ID) -> Entity<T> {
        Entity(repository: self, id: id)
    }
    
    func find<T: IdentifiableEntity>(_ ids: [T.ID]) -> [Entity<T>] {
        ids.map { find($0) }
    }
    
    func all<T>() -> [T] {
        entitiesRepository.all()
    }
    
    func find<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        entitiesRepository.find(id)
    }
    
    func findAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.findAll(ids)
    }
    
    func findAllExisting<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T] {
        entitiesRepository.findAllExisting(ids)
    }
}

extension Repository {
    func findRelations<T: IdentifiableEntity>(for type: T.Type, relationName: String, id: T.ID) -> Set<String> {
        relationsRepository.findChildren(for: type, relationName: relationName, id: id)
    }
}

extension Repository {
    
    @discardableResult
    mutating func remove<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        entitiesRepository.remove(id)
    }
    
    @discardableResult
    mutating func removeAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.removeAll(ids)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T,
                                              options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(entity, options: options)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T?,
                                              options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(entity, options: options)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entities: [T],
                                              options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(entities, options: options)
    }
}

extension Repository {
    mutating func save<T: IdentifiableEntity, R>(_ relatedEntity: RelatedEntity<T, R>?,
                                                 options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(relatedEntity, options: options)
    }
    
    mutating func save<T: IdentifiableEntity, R>(_ relatedEntity: RelatedEntity<T, R>,
                                                 options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(relatedEntity, options: options)
    }
}
    

extension Repository {
    mutating func save<T: IdentifiableEntity, R>(_ relatedEntities: some Collection<RelatedEntity<T, R>>,
                                                 options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(relatedEntities, options: options)
    }
    
    mutating func save<T: IdentifiableEntity, R>(_ relatedEntities: (any Collection<RelatedEntity<T, R>>)?,
                                                 options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.save(relatedEntities, options: options)
    }
}

extension Repository {
    mutating func save<T: IdentifiableEntity, E: IdentifiableEntity>(
        _ relation: EntitiesLink<T, E>) {
            
        relationsRepository.save(relation)
    }
}

