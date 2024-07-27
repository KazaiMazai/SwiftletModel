//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation
import Collections

public struct Context {
    private var entitiesRepository = EntitiesRepository()
    private var relationsRepository = RelationsRepository()
    
    public init() { }
}

public extension Context {
    func ids<T: EntityModel>(_ entityType: T.Type) -> [T.ID] {
        entitiesRepository.ids(T.self)
    }
    
    func all<T: EntityModel>() -> [T] {
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

public extension Context {
    
    mutating func remove<T: EntityModel>(_ entityType: T.Type, id: T.ID) {
        entitiesRepository.remove(T.self, id: id)
    }
    
    mutating func removeAll<T: EntityModel>(_ entityType: T.Type, ids: [T.ID]) {
        entitiesRepository.removeAll(T.self, ids: ids)
    }
    
    mutating func insert<T: EntityModel>(_ entity: T,
                                         options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.insert(entity, options: options)
    }
    
    mutating func insert<T: EntityModel>(_ entity: T?,
                                         options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.insert(entity, options: options)
    }
    
    mutating func insert<T: EntityModel>(_ entities: [T],
                                         options: MergeStrategy<T> = .replace) {
        
        entitiesRepository.insert(entities, options: options)
    }
}

extension Context {
    mutating func updateLinks<Parent: EntityModel, Child: EntityModel>(_ links: Links<Parent, Child>) {
        relationsRepository.updateLinks(links)
    }
}

extension Context {
    func getChildren<T: EntityModel>(for type: T.Type, relationName: String, id: T.ID) -> OrderedSet<String> {
        relationsRepository.getChildren(for: type, relationName: relationName, id: id)
    }
}
