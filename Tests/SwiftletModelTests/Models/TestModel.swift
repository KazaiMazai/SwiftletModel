//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 30/03/2025.
//

@testable import SwiftletModel
import Foundation

enum TestingModels {
    
}

extension TestingModels {
    @EntityModel
    struct SingleValueIndexed {
        @Index<Self>(\.numOf1) private static var valueIndex
        
        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf10 = (value / 10) % 10
            self.numOf100 = (value / 100) % 10
            self.numOf1000 = value / 1000
        }
    }
    
    @EntityModel
    struct ExtensivelyIndexed {
        @Index<Self>(\.numOf1) private static var numOf1Index
        @Index<Self>(\.numOf10) private static var numOf10Index
        @Index<Self>(\.numOf100) private static var numOf100Index
        @Index<Self>(\.numOf1000) private static var numOf1000Index
        
        @Index<Self>(\.numOf10, \.numOf1) private static var valueIndex2
        @Index<Self>(\.numOf10.desc, \.numOf1) private static var valueIndexDesc2
        
        @Index<Self>(\.numOf100, \.numOf10, \.numOf1) private static var valueIndex3
        @Index<Self>(\.numOf100, \.numOf10.desc, \.numOf1) private static var valueIndexDesc3
        
        @Index<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1) private static var valueIndex4
        @Index<Self>(\.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1) private static var valueIndexDesc4
       
        
        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf10 = (value / 10) % 10
            self.numOf100 = (value / 100) % 10
            self.numOf1000 = value / 1000
        }
    }
    
    @EntityModel
    struct EvaluatedPropertyDescIndexed {
        @Index<Self>(\.numOf1.desc) private static var valueIndexDesc
        
        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf1000 = value / 1000
            self.numOf100 = value / 100
            self.numOf10 = value / 10
        }
    }
    
    @EntityModel
    struct NotIndexed {
        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf1000 = value / 1000
            self.numOf100 = value / 100
            self.numOf10 = value / 10
        }
    }
    
    @EntityModel
    struct UniquelyIndexed {
        @Unique<Self>(\.numOf1, collisions: .throw) private static var valueIndex
        @Unique<Self>(\.numOf10, \.numOf1, collisions: .throw) private static var valueIndex2
        @Unique<Self>(\.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex3
        @Unique<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex4
        
        let id: String
        let numOf1: Int
        let numOf10: Int
        let numOf100: Int
        let numOf1000: Int
    }
    
    @EntityModel
    struct UniquelyIndexedComparable {
        @Unique<Self>(\.numOf1, collisions: .throw) private static var valueIndex
        @Unique<Self>(\.numOf10, \.numOf1, collisions: .throw) private static var valueIndex2
        @Unique<Self>(\.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex3
        @Unique<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex4
        
        let id: String
        let numOf1: ComparableBox<Int>
        let numOf10: ComparableBox<Int>
        let numOf100: ComparableBox<Int>
        let numOf1000: ComparableBox<Int>

        init(id: String, numOf1: Int, numOf10: Int, numOf100: Int, numOf1000: Int) {
            self.id = id
            self.numOf1 = ComparableBox(value: numOf1)
            self.numOf10 = ComparableBox(value: numOf10)
            self.numOf100 = ComparableBox(value: numOf100)
            self.numOf1000 = ComparableBox(value: numOf1000)
        }
    }

    @EntityModel
    struct NotIndexedComparable {
        let id: String
        let numOf1: ComparableBox<Int>
        let numOf10: ComparableBox<Int>
        let numOf100: ComparableBox<Int>
        let numOf1000: ComparableBox<Int>
    }

     struct ComparableBox<T: Comparable>: Comparable {
        let value: T

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.value < rhs.value
        } 
    }
}

extension TestingModels.NotIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.NotIndexed] {
        (0..<count)
            .map { idx in TestingModels.NotIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.SingleValueIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.SingleValueIndexed] {
        (0..<count)
            .map { idx in TestingModels.SingleValueIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.EvaluatedPropertyDescIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.EvaluatedPropertyDescIndexed] {
        (0..<count)
            .map { idx in TestingModels.EvaluatedPropertyDescIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}


extension TestingModels.ExtensivelyIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.ExtensivelyIndexed] {
        (0..<count)
            .map { idx in TestingModels.ExtensivelyIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}
