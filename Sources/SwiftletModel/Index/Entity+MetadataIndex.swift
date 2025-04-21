//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 21/04/2025.
//

import Foundation


public enum MetadataIndex: String {
    case updatedAt
    
    var indexName: String {
        "MetadataIndex.\(rawValue)"
    }
}

public extension EntityModelProtocol {
    func updateMetadata<Value>(
        _ indexName: String,
        value: Value,
        in context: inout Context) throws
    where
    Value: Comparable {
        
        try Index.ComparableValue.updateIndex(
            indexName: indexName,
            self,
            value: value,
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromMetadata<Value>(
        _ indexName: String,
        value: Value,
        in context: inout Context) throws
    where
    Value: Comparable {
        
        try Index.ComparableValue<Value>.removeFromIndex(
            indexName: indexName,
            self, in: &context)
    }
}


public extension EntityModelProtocol {
    func updateMetadata<Value>(
        _ indexName: String,
        value: Value,
        in context: inout Context) throws
    where
    Value: Hashable {
        
        try Index.HashableValue.updateIndex(
            indexName: indexName,
            self,
            value: value,
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromMetadata<Value>(
        _ indexName: String,
        value: Value,
        in context: inout Context) throws
    where
    Value: Hashable {
        
        try Index.HashableValue<Value>.removeFromIndex(
            indexName: indexName,
            self, in: &context)
    }
}
