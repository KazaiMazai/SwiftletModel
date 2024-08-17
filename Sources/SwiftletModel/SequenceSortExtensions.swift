//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 17/08/2024.
//

import Foundation

extension Sequence {
   func sorted(using descriptors: [SortDescriptor<Element>],
               order: SortOrder) -> [Element] {
       sorted { lhs, rhs in
           for descriptor in descriptors {
               let result = descriptor.comparator(lhs, rhs)

               switch result {
               case .orderedSame:
                   // Keep iterating if the two elements are equal,
                   // since that'll let the next descriptor determine
                   // the sort order:
                   break
               case .orderedAscending:
                   return order == .ascending
               case .orderedDescending:
                   return order == .descending
               }
           }

           // If no descriptor was able to determine the sort
           // order, we'll default to false (similar to when
           // using the '<' operator with the built-in API):
           return false
       }
   }
}

extension Sequence {
   func sorted(using descriptors: SortDescriptor<Element>...) -> [Element] {
       sorted(using: descriptors, order: .ascending)
   }
}

struct SortDescriptor<Value> {
   var comparator: (Value, Value) -> ComparisonResult
}

extension SortDescriptor {
   static func keyPath<T: Comparable>(_ keyPath: KeyPath<Value, T>) -> Self {
       Self { lhs, rhs in
           let lhsValue = lhs[keyPath: keyPath]
           let rhsValue = rhs[keyPath: keyPath]

           guard lhsValue != rhsValue else {
               return .orderedSame
           }

           return lhsValue < rhsValue ? .orderedAscending : .orderedDescending
       }
   }
}

enum SortOrder {
   case ascending
   case descending
}
