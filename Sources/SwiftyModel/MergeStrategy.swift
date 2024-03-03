//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

 
struct MergeStrategy<T> {
    let merge: (T, T) -> T
}
 
extension MergeStrategy {
    static var replace: MergeStrategy<T> {
        MergeStrategy(merge: { _, new in new })
    }
}

extension MergeStrategy {
    static func keepingOldIfNil<T>() -> MergeStrategy<Optional<T>>   {
        MergeStrategy<Optional<T>> { old, new in
            new ?? old
        }
    }
    
    static func appending<T>() -> MergeStrategy<[T]>   {
        MergeStrategy<[T]> { old, new in
            [old, new].flatMap { $0 }
        }
    }
    
    static func appending<T>() -> MergeStrategy<Optional<[T]>>   {
        MergeStrategy<Optional<[T]>> { old, new in
            let result = MergeStrategy<[T]>
                .appending()
                .merge(old ?? [], new ?? [])
            
            return result.isEmpty ? nil : result
        }
    }
}

