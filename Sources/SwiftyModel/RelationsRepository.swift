//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct RelationsRepository: Codable {
    typealias EntityID = String
    typealias EntityName = String
    typealias RelationName = String
    
    fileprivate var relations: [EntityName: [EntityID: [RelationName: Set<EntityID>]]] = [:]
}

enum Option {
    case append
    case replace
    case remove
    case replaceIfNotEmpty
}

struct Link {
    let name: String
    let updateOption: Option
}

struct EntitiesLink<T: IdentifiableEntity, E: IdentifiableEntity> {
    let parent: T.ID
    let children: [E.ID]
    let direct: Link
    let inverse: Link?
}

extension RelationsRepository {
    mutating func save<T: IdentifiableEntity, E: IdentifiableEntity>(
        _ entitiesLink: EntitiesLink<T, E>) {
            
            saveRelation(
                T.self,
                childrenType: E.self,
                id: entitiesLink.parent,
                relationName: entitiesLink.direct.name,
                children: entitiesLink.children,
                option: entitiesLink.direct.updateOption
            )
            
            guard let inverseUpdate = entitiesLink.inverse else {
                return
            }
            
            entitiesLink.children.forEach {
                saveRelation(
                    E.self,
                    childrenType: T.self,
                    id: $0,
                    relationName: inverseUpdate.name,
                    children: [entitiesLink.parent],
                    option: inverseUpdate.updateOption
                )
            }
        }
    
    func findRelations<T: IdentifiableEntity>(
        for: T.Type,
        relationName: String,
        id: T.ID) -> Set<String> {
            
            let key = String(reflecting: T.self)
            
            let entitiesRelations = relations[key] ?? [:]
            let entityRelation = entitiesRelations[id.description] ?? [:]
            let relationsForName = entityRelation[relationName] ?? []
            return relationsForName
        }
}

extension RelationsRepository {
    
    mutating func setRelations<T: IdentifiableEntity>(for: T.Type,
                                                      relationName: String,
                                                      id: T.ID,
                                                      relations: Set<String>) {
        
        let key = String(reflecting: T.self)
        
        var entitiesRelations = self.relations[key] ?? [:]
        var entityRelation = entitiesRelations[id.description] ?? [:]
        
        entityRelation[relationName] = relations
        entitiesRelations[id.description] = entityRelation
        self.relations[key] = entitiesRelations
    }
    
    private mutating func saveRelation<T: IdentifiableEntity, E: IdentifiableEntity>(_ parentType: T.Type,
                                                                                     childrenType: E.Type,
                                                                                     id: T.ID,
                                                                                     relationName: String,
                                                                                     children: [E.ID],
                                                                                     option: Option) {
        
        var existingRelations = findRelations(
            for: T.self,
            relationName: relationName,
            id: id
        )
        
        switch option {
        case .append:
            children.forEach { existingRelations.insert($0.description) }
        case .replace:
            existingRelations = Set(children.map { $0.description })
        case .replaceIfNotEmpty:
            if !children.isEmpty {
                existingRelations = Set(children.map { $0.description })
            }
        case .remove:
            children.forEach { existingRelations.remove($0.description) }
        }
        
        setRelations(
            for: T.self,
            relationName: relationName,
            id: id,
            relations: existingRelations
        )
    }
}

