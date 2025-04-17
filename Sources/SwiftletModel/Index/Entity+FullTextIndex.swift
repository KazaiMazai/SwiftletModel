//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16/08/2024.
//

import Foundation

public extension EntityModelProtocol {
    func updateFullTextIndex<T>(
        _ keyPaths: KeyPath<Self, T>...,
        in context: inout Context) throws
    where
    T: Hashable {
        
        try FullTextIndex.HashableValue.updateIndex(
            indexName: .indexName(keyPaths),
            self,
            value: keyPaths.map { self[keyPath: $0] },
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromFullTextIndex<T>(
        _ keyPaths: KeyPath<Self, T>...,
        in context: inout Context) throws
    where
    T: Hashable {
        
        try FullTextIndex.HashableValue<[T]>.removeFromIndex(indexName: .indexName(keyPaths), self, in: &context)
    }
}
