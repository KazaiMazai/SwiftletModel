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
        private var indexedValuesTokensFrequency: [Entity.ID: [Value: Int]] = [:]
        private var lengths: [Entity.ID: Int] = [:]
        private var avgDocLength: Double = 0.0

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
            let N = Double(indexedValuesTokens.count) // total number of documents
            let n = Double(matchingDocs.count) // number of documents containing the term
            let idf = log((N - n + 0.5) / (n + 0.5) + 1.0)
            
            for entityId in matchingDocs {
                // Calculate term frequency
                let docTokens = indexedValuesTokens[entityId] ?? []
                let tf = Double(docTokens.filter { $0 == token }.count)
                let docLength = Double(docTokens.count)
                
                // BM25 score calculation
                let numerator = tf * (k1 + 1.0)
                let denominator = tf + k1 * (1.0 - b + b * docLength / avgDocLength)
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
        
         if let existingValue, let existingValueTokens = indexedValuesTokens[entity.id] {
            existingValueTokens.forEach { token in
                var ids = index[token] ?? []
                ids.remove(entity.id)
                index[token] = ids.isEmpty ? nil : ids
            }
            indexedValues[entity.id] = nil
            indexedValuesTokens[entity.id] = nil
            indexedValuesTokensFrequency[entity.id] = nil
            lengths[entity.id] = nil
        }

        let tokens = makeTokens(for: value)
        tokens.forEach { token in
            var ids = index[token] ?? []
            ids.insert(entity.id)
            index[token] = ids
        }
     
        indexedValues[entity.id] = value
        indexedValuesTokens[entity.id] = Set(tokens)
        indexedValuesTokensFrequency[entity.id] = tokens.reduce(into: [:]) { $0[$1, default: 0] += 1 }
        lengths[entity.id] = tokens.count
        
        // Update avgDocLength after modifying lengths
        let totalTokens = lengths.values.reduce(0, +)
        avgDocLength = Double(totalTokens) / Double(max(1, lengths.count))
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
        indexedValuesTokensFrequency[entity.id] = nil
        lengths[entity.id] = nil
        
        // Update avgDocLength after modifying lengths
        let totalTokens = lengths.values.reduce(0, +)
        avgDocLength = Double(totalTokens) / Double(max(1, lengths.count))
    }
}
 
extension SearchIndex.HashableValue where Value == String {
    func makeTokens(for value: String) -> [String] {
        value.searchTokens(with: 3)
    }
}


extension SearchIndex.HashableValue where Value: Hashable {
    func makeTokens(for value: Value) -> [Value] {
        [value]
    }
}
