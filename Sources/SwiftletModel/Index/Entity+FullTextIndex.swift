//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16/08/2024.
//

import Foundation

extension EntityModelProtocol {
    func updateFullTextIndex<T>(
        _ keyPaths: KeyPath<Self, T>...,
        in context: inout Context) throws
    where
    T: Hashable {
        
        guard !keyPaths.isComposition(),
              let keyPath = keyPaths.first
        else {
            try FullTextIndex.HashableValue.updateIndex(
                indexName: .indexName(keyPaths),
                self,
                value: keyPaths.map { self[keyPath: $0] },
                in: &context
            )
            return
        }
        
        try FullTextIndex.HashableValue.updateIndex(
            indexName: .indexName(keyPaths),
            self,
            value: self[keyPath: keyPath],
            in: &context
        )
    }
}

extension EntityModelProtocol {
    func removeFromFullTextIndex<T>(
        _ keyPaths: KeyPath<Self, T>...,
        in context: inout Context) throws
    where
    T: Hashable {
        
        guard !keyPaths.isComposition(), let keyPath = keyPaths.first else {
            try FullTextIndex.HashableValue<[T]>.removeFromIndex(indexName: .indexName(keyPaths), self, in: &context)
            return
        }
        
        try FullTextIndex.HashableValue<T>.removeFromIndex(indexName: .indexName(keyPaths), self, in: &context)

        
    }
}
