//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

extension Collection {
   func resolve<T>() -> [T?] where Element == Entity<T> {
       map { $0.resolve() }
   }
   
   func related<T, E, R>(_ keyPath: KeyPath<T, RelatedEntity<E, R>?>) -> [Entity<E>] where Element == Entity<T> {
       compactMap { $0.related(keyPath) }
   }
   
   func related<T, E, R>(_ keyPath: KeyPath<T, [RelatedEntity<E, R>]?>) -> [[Entity<E>]] where Element == Entity<T> {
       compactMap { $0.related(keyPath) }
   }
}
