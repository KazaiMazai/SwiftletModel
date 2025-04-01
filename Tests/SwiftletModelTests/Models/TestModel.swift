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
        @Index<Self>(\.value) private static var valueIndex
        
        let id: String
        let value: Int
        let value1: Int
        let value2: Int
        let value3: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.value = value
            self.value1 = value / 1000
            self.value2 = value / 100
            self.value3 = value / 10
        }
    }
    
    @EntityModel
    struct ExtensivelyIndexed {
        @Index<Self>(\.value) private static var valueIndex
        @Index<Self>(\.value, \.value1) private static var valueIndex1
        @Index<Self>(\.value, \.value1, \.value2) private static var valueIndex2
        @Index<Self>(\.value, \.value1, \.value2, \.value3) private static var valueIndex3
        @Index<Self>(\.value, \.value1.desc, \.value2, \.value3.desc) private static var mixedIndex
       
        
        let id: String
        let value: Int
        let value1: Int
        let value2: Int
        let value3: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.value = value
            self.value1 = value / 1000
            self.value2 = value / 100
            self.value3 = value / 10
        }
    }
    
    @EntityModel
    struct EvaluatedPropertyDescIndexed {
        @Index<Self>(\.value.desc) private static var valueIndexDesc
        
        let id: String
        let value: Int
        let value1: Int
        let value2: Int
        let value3: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.value = value
            self.value1 = value / 1000
            self.value2 = value / 100
            self.value3 = value / 10
        }
    }
    
    @EntityModel
    struct NotIndexed {
        let id: String
        let value: Int
        let value1: Int
        let value2: Int
        let value3: Int
        
        init(id: String, value: Int) {
            self.id = id
            self.value = value
            self.value1 = value / 1000
            self.value2 = value / 100
            self.value3 = value / 10
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
