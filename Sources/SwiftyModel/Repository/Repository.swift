//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public struct Repository {
    private var entitiesRepository = EntitiesRepository()
    private var relationsRepository = RelationsRepository()
    
    public init() {
        
    }
}

extension Repository {

    func all<T>() -> [T] {
        entitiesRepository.all()
    }
    
    func find<T: EntityModel>(_ id: T.ID) -> T? {
        entitiesRepository.find(id)
    }
    
    func findAll<T: EntityModel>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.findAll(ids)
    }
    
    func findAllExisting<T: EntityModel>(_ ids: [T.ID]) -> [T] {
        entitiesRepository.findAllExisting(ids)
    }
}

extension Repository {
    func findRelations<T: EntityModel>(for type: T.Type, relationName: String, id: T.ID) -> Set<String> {
        relationsRepository.findChildren(for: type, relationName: relationName, id: id)
    }
}

extension Repository {
    
    @discardableResult
    mutating func remove<T: EntityModel>(_ id: T.ID) -> T? {
        entitiesRepository.remove(id)
    }
    
    @discardableResult
    mutating func removeAll<T: EntityModel>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.removeAll(ids)
    }
    
    mutating func save<T: EntityModel>(_ entity: T,
                                              options: MergeStrategy<T> = T.mergeStraregy()) {
        
        entitiesRepository.save(entity, options: options)
    }
    
    mutating func save<T: EntityModel>(_ entity: T?,
                                              options: MergeStrategy<T> = T.mergeStraregy()) {
        
        entitiesRepository.save(entity, options: options)
    }
    
    mutating func save<T: EntityModel>(_ entities: [T],
                                              options: MergeStrategy<T> = T.mergeStraregy()) {
        
        entitiesRepository.save(entities, options: options)
    }
}

extension Repository {
    mutating func save<T: EntityModel, R, K, Optionality>(_ relatedEntity: Relationship<T, R, K, Optionality>,
                                                                 options: MergeStrategy<T> = T.mergeStraregy()) {
        
        entitiesRepository.save(relatedEntity, options: options)
    }
}


extension Repository {
    mutating func save<T: EntityModel, E: EntityModel>(_ relation: EntitiesAttachment<T, E>) {
        
        relationsRepository.save(relation)
    }
}



