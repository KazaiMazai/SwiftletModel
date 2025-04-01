//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 30/03/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

class SortByOnePathQueryTests: XCTestCase {
    let count = 10
    var context = Context()
    
    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.SingleValueIndexed.shuffled(count)
    }()
    
    lazy var evalPropertyIndexedModels = {
        TestingModels.EvaluatedPropertyDescIndexed.shuffled(count)
    }()
    
    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }
        
        try indexedModels
            .forEach { try $0.save(to: &context) }
        
        try evalPropertyIndexedModels
            .forEach { try $0.save(to: &context) }
    }
    
    func test_WhenSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { $0.value < $1.value }
       
        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.value)
            .resolve()
        
        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
    
    func test_WhenSortIndexed_ThenEqualPlainSort() throws {
        let expected = indexedModels
            .sorted { $0.value < $1.value }
       
        let sortResult = TestingModels.SingleValueIndexed
            .query(in: context)
            .sorted(by: \.value)
            .resolve()
        
        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
    
    func test_WhenDescSortNoIndex_ThenEqualPlainSort() throws {
        let expected = notIndexedModels
            .sorted { $0.value > $1.value }
       
        let sortResult = TestingModels.NotIndexed
            .query(in: context)
            .sorted(by: \.value.desc)
            .resolve()
        
        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
    
    func test_WhenDescSortIndexed_ThenEqualPlainSort() throws {
        let expected = evalPropertyIndexedModels
            .sorted { $0.value > $1.value }
       
        let sortResult = TestingModels.EvaluatedPropertyDescIndexed
            .query(in: context)
            .sorted(by: \.value.desc)
            .resolve()
        
        XCTAssertEqual(sortResult.map { $0.id }, expected.map { $0.id })
    }
}

