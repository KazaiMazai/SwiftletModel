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
    mutating func save<T: IdentifiableEntity, E: IdentifiableEntity>(
        _ entityRelation: StoredRelation<T, E>) {
            
            saveRelation(
                T.self,
                id: entityRelation.id,
                relationName: entityRelation.name,
                relations: entityRelation.relation,
                option: entityRelation.option
            )
            
            guard let inverseName = entityRelation.inverseName else {
                return
            }
            
            let reversedRelation = Relation<T>(entityRelation.id)
            
            entityRelation.relation.forEach {
                saveRelation(
                    E.self,
                    id: $0.id,
                    relationName: inverseName,
                    relations: [reversedRelation],
                    option: entityRelation.inverseOption ?? .append
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
    
    private mutating func saveRelation<T: IdentifiableEntity, E: IdentifiableEntity>(
        _ entityType: T.Type,
        id: T.ID,
        relationName: String,
        relations: [Relation<E>],
        option: RelationsRepository.Option) {
            
            let key = String(reflecting: T.self)
            
            var entitiesRelations = self.relations[key] ?? [:]
            var entityRelation = entitiesRelations[id.description] ?? [:]
            var relationsForName = entityRelation[relationName] ?? []
            
            switch option {
            case .append:
                relations.forEach { relationsForName.insert($0.id.description) }
            case .replace:
                relationsForName = Set(relations.map { $0.id.description })
            }
            
            entityRelation[relationName] = relationsForName
            entitiesRelations[id.description] = entityRelation
            self.relations[key] = entitiesRelations
        }
}

