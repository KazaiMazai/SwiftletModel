//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

import Collections


public enum FilterGroup {
    case or
    case and
}

public extension Collection {
    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .filter { predicate.isIncluded($0) }
                .query(in: context)
        }
        
        let filterResult = OrderedSet(index.filter(predicate))
        
        return filter { filterResult.contains($0.id) }
    }
    
    func group<Entity>(_ filterGroup: FilterGroup,
                       query: (Self) -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        
        return switch filterGroup {
        case .and:
            query(self)
        case .or:
            or(query: query)
        }
    }
}



public extension Query {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable {
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter { predicate.isIncluded($0) }
                .query(in: context)
        }
        
        return index
            .filter(predicate)
            .map { Query<Entity>(context: context, id: $0) }
    }
    
    static func filter<T>(
        _ keyPath: KeyPath<Entity, T>,
        equals value: T,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable {
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(keyPath), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter { $0[keyPath: keyPath] == value }
                .query(in: context)
        }
        
        return index
            .filter(value)
            .map { Query<Entity>(context: context, id: $0) }
    }

    static func filter<T0, T1>(
            _ kp0: (KeyPath<Entity, T0>, T0),
            _ kp1: (KeyPath<Entity, T1>, T1),
    in context: Context) -> [Query<Entity>] 
    
    where 
    T0: Comparable,
    T1: Comparable {

        guard let index = SortIndex<Entity>.ComparableValue<Pair<T0, T1>>
            .query(.indexName(kp0.0, kp1.0), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter { $0[keyPath: kp0.0] == kp0.1 && $0[keyPath: kp1.0] == kp1.1 }
                .query(in: context)
        }
        
        return index
            .filter(Pair(t0: kp0.1, t1: kp1.1))
            .map { Query<Entity>(context: context, id: $0) }
    }

    static func filter<T0, T1, T2>(
            _ kp0: (KeyPath<Entity, T0>, T0),
            _ kp1: (KeyPath<Entity, T1>, T1),
            _ kp2: (KeyPath<Entity, T2>, T2),
            in context: Context) -> [Query<Entity>] 

    where 
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {

        guard let index = SortIndex<Entity>.ComparableValue<Triplet<T0, T1, T2>>
            .query(.indexName(kp0.0, kp1.0, kp2.0), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter { $0[keyPath: kp0.0] == kp0.1 && $0[keyPath: kp1.0] == kp1.1 && $0[keyPath: kp2.0] == kp2.1 }
                .query(in: context)
        }

        return index
            .filter(Triplet(t0: kp0.1, t1: kp1.1, t2: kp2.1))
            .map { Query<Entity>(context: context, id: $0) }
    }

    static func filter<T0, T1, T2, T3>(
            and kp0: (KeyPath<Entity, T0>, equals: T0),
            and kp1: (KeyPath<Entity, T1>, equals: T1),
            and kp2: (KeyPath<Entity, T2>, equals: T2),
            and kp3: (KeyPath<Entity, T3>, equals: T3),
            in context: Context) -> [Query<Entity>]  
    
    where 
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {

        guard let index = SortIndex<Entity>.ComparableValue<Quadruple<T0, T1, T2, T3>>
            .query(.indexName(kp0.0, kp1.0, kp2.0, kp3.0), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter {
                    $0[keyPath: kp0.0] == kp0.1 &&
                    $0[keyPath: kp1.0] == kp1.1 &&
                    $0[keyPath: kp2.0] == kp2.1 &&
                    $0[keyPath: kp3.0] == kp3.1
                }
                .query(in: context)
        }

        return index
            .filter(Quadruple(t0: kp0.1, t1: kp1.1, t2: kp2.1, t3: kp3.1))
            .map { Query<Entity>(context: context, id: $0) }
    }   
}


//MARK: - Private Filtering

private extension Collection {

    func filtered<Entity, T>(value: T, using index: SortIndex<Entity>.ComparableValue<T>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T: Comparable {
        
        let queries = Dictionary(map { query in (query.id, query) }, uniquingKeysWith: { $1 })
        return index
            .filter(value)
            .compactMap { queries[$0] }
    }
}

extension Collection {
    func or<Entity>(query: (Self) -> [Query<Entity>]
    
    ) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        
        guard let context = first?.context else {
            return query(self)
        }
        
        let current = map { $0.id }
        let result = query(self).map { $0.id }
        return OrderedSet(
            [current, result]
            .flatMap { $0 })
            .map { Query(context: context, id: $0) }
    }
    
     
}
