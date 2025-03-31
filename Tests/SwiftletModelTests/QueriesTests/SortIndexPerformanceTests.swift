//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 30/03/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

final class SortIndexPerformanceTests: XCTestCase {
    var count: Int  { 2000 }
    var context = Context()
    
    lazy var notIndexedModels = {
        (0..<count)
            .map { idx in TestModel(id: "\(idx)", value: idx) }
            .shuffled()
    }()
    
    lazy var indexedModels = {
        (0..<count)
            .map { idx in TestIndexedModel(id: "\(idx)", value: idx) }
            .shuffled()
    }()
    
    lazy var evalPropertyIndexedModels = {
        (0..<count)
            .map { idx in TestEvaluatedPropertyIndexedModel(id: "\(idx)", value: idx) }
            .shuffled()
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

    func test_NoIndex_SortPerformance() throws {
        let queries = TestModel.query(in: context)
        measure {
            let _ = queries
                .sorted(by: \.value)
                .resolve()
        }
    }
    
    func test_Indexed_SortPerformance() throws {
        let queries = TestIndexedModel.query(in: context)
        measure {
            let _ = queries
                .sorted(by: \.value)
                .resolve()
        }
    }
    
    func test_EvalProperyIndexed_SortPerformance() throws {
        let queries = TestEvaluatedPropertyIndexedModel.query(in: context)
        measure {
            let _ = queries
                .sorted(by: \.value.desc)
                .resolve()
        }
    }
    
    func test_NoIndex_SavePerformance() throws {
        let models = notIndexedModels
       
        measure {
            var context = Context()
            try! models.forEach { try $0.save(to: &context) }
        }
    }
    
    func test_Indexed_SavePerformance() throws {
        let models = indexedModels
       
        measure {
            var context = Context()
            try! models.forEach { try $0.save(to: &context) }
        }
    }
    
    func test_EvaluatedPropertyIndexed_SavePerformance() throws {
        let models = evalPropertyIndexedModels
       
        measure {
            var context = Context()
            try! models.forEach { try $0.save(to: &context) }
        }
    }
}

