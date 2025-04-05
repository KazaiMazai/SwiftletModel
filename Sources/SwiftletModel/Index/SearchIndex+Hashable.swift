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
        typealias Token = Value
        
        var id: String { name }
        
        let name: String
        
        private var index: [Token: Set<Entity.ID>] = [:]
        
        private var indexedValues: [Entity.ID: Value] = [:]
        private var tokensForEntities: [Entity.ID: Set<Token>] = [:]
        private var tokenFrequenciesForEntities: [Entity.ID: [Token: Int]] = [:]
        private var valueLenghtsForEntities: [Entity.ID: Int] = [:]
       
        private var averageValueLength: Double = 0.0
        private var totalLengthSum: Int = 0
        private var entitiesCount: Int = 0

        private let k1: Double = 1.2  // term frequency saturation parameter
        private let b: Double = 0.75  // length normalization parameter
    
        init(name: String) {
            self.name = name
        }
    }
}

extension SearchIndex.HashableValue {
    // Constants for BM25 ranking
   
    func search(for value: Value) -> [Entity.ID] {
        let tokens = makeTokens(for: value)
        var scores: [Entity.ID: Double] = [:]
        
        for token in tokens {
            guard let matchingDocs = index[token] else { continue }
            
            // Calculate IDF
            let N = Double(tokensForEntities.count) // total number of documents
            let n = Double(matchingDocs.count) // number of documents containing the term
            let idf = log((N - n + 0.5) / (n + 0.5) + 1.0)
            
            for entityId in matchingDocs {
                // Use tokenFrequenciesForEntities for term frequency
                let tf = Double(tokenFrequenciesForEntities[entityId]?[token] ?? 0)
                // Use valueLenghtsForEntities for document length
                let docLength = Double(valueLenghtsForEntities[entityId] ?? 0)
                
                // BM25 score calculation
                let numerator = tf * (k1 + 1.0)
                let denominator = tf + k1 * (1.0 - b + b * docLength / averageValueLength)
                let score = idf * numerator / denominator
                
                scores[entityId, default: 0] += score
            }
        }
        
        return scores.sorted { $0.value > $1.value }.map { $0.key }
    }
}

extension SearchIndex.HashableValue {
    static func updateIndex(indexName: String,
                            _ entity: Entity,
                            value: Value,
                            in context: inout Context) throws {
        
        var index = Query(context: context, id: indexName).resolve() ?? Self(name: indexName)
        index.update(entity, value: value)
        try index.save(to: &context)
    }
    
    static func removeFromIndex(indexName: String,
                                _ entity: Entity,
                                in context: inout Context) throws {
        
        var index = Query<Self>(context: context, id: indexName).resolve()
        index?.remove(entity)
        try index?.save(to: &context)
    }
}

private  extension SearchIndex.HashableValue {
    mutating func update(_ entity: Entity, 
                        value: Value) {

        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if existingValue != nil {
            remove(entity)
        }

        let tokens = makeTokens(for: value)
        tokens.forEach { token in
            var ids = index[token] ?? []
            ids.insert(entity.id)
            index[token] = ids
        }
     
        totalLengthSum += tokens.count
        entitiesCount += 1
        indexedValues[entity.id] = value
        tokensForEntities[entity.id] = Set(tokens)
        tokenFrequenciesForEntities[entity.id] = tokens.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        valueLenghtsForEntities[entity.id] = tokens.count
        
        averageValueLength = Double(totalLengthSum) / Double(max(1, entitiesCount))
    }
    
    mutating func remove(_ entity: Entity) {
        guard let tokens = tokensForEntities[entity.id]
         else {
            return
        }
        tokens.forEach { token in
            var ids = index[token] ?? []
            ids.remove(entity.id)
            index[token] = ids.isEmpty ? nil : ids
        }
        totalLengthSum -= valueLenghtsForEntities[entity.id] ?? 0
        entitiesCount -= 1
        averageValueLength = Double(totalLengthSum) / Double(max(1, entitiesCount))
        
        indexedValues[entity.id] = nil
        tokensForEntities[entity.id] = nil
        tokenFrequenciesForEntities[entity.id] = nil
        valueLenghtsForEntities[entity.id] = nil
        
        
    }
}
 
extension SearchIndex.HashableValue where Value == String {
    func makeTokens(for value: String) -> [String] {
        value.nGrams(of: 3)
    }
}


extension SearchIndex.HashableValue where Value: Hashable {
    func makeTokens(for value: Value) -> [Value] {
        [value]
    }
}
