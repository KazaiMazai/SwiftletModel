//
//  QueryCollectionFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 06/04/2025.
//

extension Collection {
    static func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        Query.filter(predicate, in: context)
    }
     
    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            let filterResult = Set(index.filter(predicate))
            return filter( { filterResult.contains($0.id) })
        }
        
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable & Hashable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        if predicate.method == .equal, let index = SortIndex<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            let filterResult = Set(index.find(predicate.value))
            return filter( { filterResult.contains($0.id) })
        }
        
        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            let filterResult = Set(index.filter(predicate))
            return filter( { filterResult.contains($0.id) })
        }
        
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        if predicate.method == .equal, let index = SortIndex<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            let filterResult = Set(index.find(predicate.value))
            return filter( { filterResult.contains($0.id) })
        }
        
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Equatable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}

public extension Queries {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> Queries<Entity>
    where
    T: Comparable {

        Queries(context: context) {
            Query.filter(predicate, in: context)
        }
    }
     
    func filter<T>(
        _ predicate: Predicate<Entity, T>) -> Queries<Entity>
    where
    T: Comparable {
         whenResolved { 
             $0.filter(predicate)
         }
    }
    
    func filter<T>(
        _ predicate: Predicate<Entity, T>) -> Queries<Entity>
    where
    T: Comparable & Hashable {
        whenResolved { 
             $0.filter(predicate)
        }
    }
    
    func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> Queries<Entity>
    where
    T: Hashable { 
         whenResolved { 
             $0.filter(predicate)
        }
    }
    
    func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> Queries<Entity>
    where
    T: Equatable {
         whenResolved { 
             $0.filter(predicate)
         }
    }
}


extension Collection {
    static func filter<Entity>(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>  {
        Query.filter(predicate, in: context)
    }
}

public extension Queries {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> Queries<Entity>  {
        Queries(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}

extension Collection {
     
    func filter<Entity>(
        _ predicate: StringPredicate<Entity>) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        if predicate.method.isMatching, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve() {

            let filterResult = Set(index.search(predicate.value))
            return filter( { filterResult.contains($0.id) })
        }

         if predicate.method.isIncluding, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve() {

            let filterResult = Set(index.search(predicate.value))
            return self
                .filter( { filterResult.contains($0.id) })
                .resolve()
                .filter(predicate.isIncluded)
                .query(in: context)
        }
         
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}

public extension Queries {
    func filter( _ predicate: StringPredicate<Entity>) -> Queries<Entity> {
        whenResolved {
            $0.filter(predicate)
        }
    }
}
