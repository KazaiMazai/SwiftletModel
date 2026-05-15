//
//  Entity+Metadata.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 15/05/2026.
//
import Foundation

extension EntityModelProtocol {
    static func updatedAt(in context: Context) -> Date? {
        guard let index = SortIndex<Self>.ComparableValue<Date>
            .query(Metadata.updatedAt.indexName)
            .resolve(in: context)
        else {
            return nil
        }
        
        return index.lastValue
    }
}
