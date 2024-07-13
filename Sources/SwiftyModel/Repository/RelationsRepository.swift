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

extension RelationsRepository {
    mutating func saveAttachment<Parent, Child>(
        _ entitiesAttachment: Link<Parent, Child>)
    
    where Parent: EntityModel, Child: EntityModel {
        
        saveChildren(
            Parent.self,
            childrenType: Child.self,
            id: entitiesAttachment.parent,
            relationName: entitiesAttachment.direct.name,
            children: entitiesAttachment.children,
            option: entitiesAttachment.direct.updateOption
        )
        
        guard let inverseUpdate = entitiesAttachment.inverse else {
            return
        }
        
        entitiesAttachment.children.forEach {
            saveChildren(
                Child.self,
                childrenType: Parent.self,
                id: $0,
                relationName: inverseUpdate.name,
                children: [entitiesAttachment.parent],
                option: inverseUpdate.updateOption
            )
        }
    }
    
    func findChildren<Parent: EntityModel>(
        for: Parent.Type,
        relationName: String,
        id: Parent.ID) -> Set<String> {
            
            let key = String(reflecting: Parent.self)
            
            let entitiesRelations = relations[key] ?? [:]
            let entityRelation = entitiesRelations[id.description] ?? [:]
            let relationsForName = entityRelation[relationName] ?? []
            return relationsForName
        }
}

extension RelationsRepository {
    
    mutating func setChildren<Parent: EntityModel>(for: Parent.Type,
                                                   relationName: String,
                                                   id: Parent.ID,
                                                   relations: Set<String>) {
        
        let key = String(reflecting: Parent.self)
        
        var entitiesRelations = self.relations[key] ?? [:]
        var entityRelation = entitiesRelations[id.description] ?? [:]
        
        entityRelation[relationName] = relations
        entitiesRelations[id.description] = entityRelation
        self.relations[key] = entitiesRelations
    }
    
    private mutating func saveChildren<Parent, Child>(_ parentType: Parent.Type,
                                                      childrenType: Child.Type,
                                                      id: Parent.ID,
                                                      relationName: String,
                                                      children: [Child.ID],
                                                      option: Option) where Parent: EntityModel,
                                                                            Child: EntityModel {
                                                                                
    var existingRelations = findChildren(
        for: Parent.self,
        relationName: relationName,
        id: id
    )
    
    switch option {
    case .append:
        children.forEach { existingRelations.insert($0.description) }
    case .replace:
        existingRelations = Set(children.map { $0.description })
    case .remove:
        children.forEach { existingRelations.remove($0.description) }
    }
    
    setChildren(
        for: Parent.self,
        relationName: relationName,
        id: id,
        relations: existingRelations
    )
}
}

