//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 04/04/2025.
//

import Foundation

enum SearchIndex<Entity: EntityModelProtocol> {
    
}

extension SearchIndex {
    @EntityModel
    struct HashableValue<Value: Hashable> {
        var id: String { name }
        
        let name: String
        
        private var index: [Value: Set<Entity.ID>] = [:]
        private var indexedValues: [Entity.ID: Value] = [:]
        private var indexedValuesTokens: [Entity.ID: Set<Value>] = [:]
        
        init(name: String) {
            self.name = name
        }
    }
}
 
extension SearchIndex.HashableValue {
    static func updateIndex(indexName: String,
                            _ entity: Entity,
                            value: Value,
                            searchTokens: SearchTokens<Value>,
                            in context: inout Context) throws {
        
        var index = Query(context: context, id: indexName).resolve() ?? Self(name: indexName)
        index.update(entity, value: value, searchTokens: searchTokens)
        try index.save(to: &context)
    }
    
    static func removeFromIndex(indexName: String,
                                _ entity: Entity,
                                searchTokens: SearchTokens<Value>,
                                in context: inout Context) throws {
        
        var index = Query<Self>(context: context, id: indexName).resolve()
        index?.remove(entity)
        try index?.save(to: &context)
    }
}

private  extension SearchIndex.HashableValue {
    mutating func update(_ entity: Entity, 
                        value: Value, 
                        searchTokens: SearchTokens<Value>) {

        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
         if let existingValue, let existingValueTokens = indexedValuesTokens[entity.id] {
            existingValueTokens.forEach { token in
                var ids = index[token] ?? []
                ids.remove(entity.id)
                index[token] = ids.isEmpty ? nil : ids
            }
            indexedValues[entity.id] = nil
            indexedValuesTokens[entity.id] = nil
        }

        let tokens = searchTokens.makeTokens(for: value)
        tokens.forEach { token in
            var ids = index[token] ?? []
            ids.insert(entity.id)
            index[token] = ids
        }
     
        indexedValues[entity.id] = value
        indexedValuesTokens[entity.id] = Set(tokens)
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
                let tokens = indexedValuesTokens[entity.id] 
         else {
            return
        }
        tokens.forEach { token in
            var ids = index[token] ?? []
            ids.remove(entity.id)
            index[token] = ids.isEmpty ? nil : ids
        }

        indexedValues[entity.id] = nil
        indexedValuesTokens[entity.id] = nil
    }
}
 
