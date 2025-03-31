//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 30/03/2025.
//

@testable import SwiftletModel
import Foundation

@EntityModel
struct TestIndexedModel {
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
struct TestEvaluatedPropertyIndexedModel {
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
struct TestModel {
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
