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
    @Index<TestIndexedModel>(\.value) private static var valueIndex
    @Index<TestIndexedModel>(\.value.desc) private static var valueIndexDesc
    
    
    let id: String
    let value: Int
    let value1: Int
    let value2: Int
    let value3: Int

    init(id: String, value: Int) {
        self.id = id
        self.value = value * 1000
        self.value1 = value * 100
        self.value2 = value * 10
        self.value3 = value 
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
        self.value = value * 1000
        self.value1 = value * 100
        self.value2 = value * 10
        self.value3 = value 
    }
}
