//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

import Collections
import Foundation

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Comparable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }

    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Comparable & Hashable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Hashable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Equatable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> QueryList<Entity> {
        
        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}



//MARK: - Metadata Query Predicate Filter

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
//    func filter(snapshot: ClosedRange<Date>) -> Query<Entity> {
//        self.filter(\Metadata<Entity>.savedAt >= snapshot.lowerBound)
//            .filter(\Metadata<Entity>.savedAt <= snapshot.upperBound)
//    }
    
//    func filter(_ snapshot: SnapshotPredicate) -> Query<Entity> {
//        self.filter(snapshot)
//    }
}

//public extension ContextQuery where Result == [Query<Entity>], Key == Void {
//    func filter(snapshot: ClosedRange<Date>) -> QueryList<Entity> {
//        self.filter(\Metadata<Entity>.updatedAt >= snapshot.lowerBound)
//            .filter(\Metadata<Entity>.updatedAt <= snapshot.upperBound)
//    }
    
//    func filter(_ predicate: SnapshotPredicate) -> QueryList<Entity>
//    where
//    Result == [Query<Entity>],
//    Key == Void {
////        switch predicate {
////        case .updatedAt(let range):
////            self.filter(\Metadata<Entity>.updatedAt >= range.lowerBound)
////                .filter(\Metadata<Entity>.updatedAt <= range.upperBound)
////        }
//       
//    }
//}

public extension ContextQuery {
   
    
//    func filter(
//        _ predicate: SnapshotPredicate) -> QueryList<Entity>
//    where
//    Result == [Query<Entity>],
//    Key == Void {
//        
//        whenResolved { entity in
////            guard let metadata = Metadata<Entity>.query(entity.id, in: context).resolve() else {
////                return nil
////            }
////            
////            return predicate.isIncluded(metadata) ? entity : nil
//        }
//    }
    
    
    func filter(
        _ predicate: SnapshotPredicate) -> Query<Entity>
    where
    Result == Optional<Entity>,
    Key == Entity.ID {
        
        whenResolved { entity in
            guard let metadata = Metadata<Entity>.query(entity.id, in: context).resolve() else {
                return nil
            }
            
            return predicate.isIncluded(metadata) ? entity : nil
        }
    }

    func filter<T: EntityModelProtocol>(
        _ predicate: SnapshotPredicate) -> Query<Metadata<T>>
    where
    Entity == Metadata<T>,
    Result == Optional<Metadata<T>>,
    Key == Metadata<T>.ID {
        
        whenResolved { metadata in
            predicate.isIncluded(metadata) ? metadata : nil
        }
    }
}


//MARK: - Private Query Predicate Filter

private extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable {

        if let index = Index<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
            .filter(predicate)
            .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }

    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable & Hashable {

        if predicate.method == .equal, let index = Index<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
                .find(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
        }

        if let index = Index<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
                .filter(predicate)
                .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Hashable {

        if predicate.method == .equal, let index = Index<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
                .find(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Equatable {

        Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}

//MARK: - Private Query StringPredicate Filter

private extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> [Query<Entity>] {
        
        if predicate.method.isMatching, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve() {
            
            return index
                .search(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
        }

         if predicate.method.isIncluding, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve() {
            
            return index
                .search(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
                .resolve()
                .filter(predicate.isIncluded)
                .query(in: context)
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}
 

