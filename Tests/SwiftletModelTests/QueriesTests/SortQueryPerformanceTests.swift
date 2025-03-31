//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 30/03/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest


class SortQueryPerformanceTests: XCTestCase {
    var count: Int  { 1000 }
    
    lazy var notIndexedModels = {
        (0..<count).map { idx in TestModel(id: "\(idx)", value: idx) }
    }()
    
    lazy var indexedModels = {
        (0..<count).map { idx in TestIndexedModel(id: "\(idx)", value: idx) }
    }()

    func test_NoIndexPerformance() throws {
        let models = notIndexedModels.shuffled()
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        let queries = TestModel.query(in: context)
        measure {
            let _ = queries
                .sorted(by: \.value)
                .resolve()
        }
    }
    
    func test_IndexPerformance() throws {
        let models = indexedModels.shuffled()
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        let queries = TestIndexedModel.query(in: context)
        measure {
            let _ = queries
                .sorted(by: \.value)
                .resolve()
        }
    }
    
    func test_IndexDescPerformance() throws {
        let models = indexedModels.shuffled()
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        measure {
            let _ = TestIndexedModel
                .query(in: context)
                .sorted(by: \.value.desc)
                .resolve()
        }
    }
    
    func test_NoIndexSavePerformance() throws {
        let models = notIndexedModels.shuffled()
       
        var context = Context()
        measure {
            try! models.forEach { try $0.save(to: &context) }
        }
    }
    
    func test_IndexBuildSavePerformance() throws {
        let models = indexedModels.shuffled()
       
        var context = Context()
        measure {
            try! models.forEach { try $0.save(to: &context) }
        }
    }
}

