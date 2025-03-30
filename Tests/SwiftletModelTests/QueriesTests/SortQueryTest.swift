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
    
    lazy var notIndexedModels = {
        (0..<count)
            .map { idx in TestModel(id: "\(idx)", value: idx) }
    }()

    lazy var indexedModels = {
        (0..<count)
            .map { idx in TestIndexedModel(id: "\(idx)", value: idx) }
    }()
    
    func test_WhenSortNoIndex_ThenEqualPlainSort() throws {
        let models = notIndexedModels
            .sorted { $0.value < $1.value }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        let queriedModels = TestModel
            .query(in: context)
            .sorted(by: \.value)
            .resolve()
        
        XCTAssertEqual(models.map { $0.id }, queriedModels.map { $0.id })
        
    }
    
    func test_WhenSortIndexed_ThenEqualPlainSort() throws {
        let models = indexedModels
            .sorted { $0.value < $1.value }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        let queriedModels = TestIndexedModel
            .query(in: context)
            .sorted(by: \.value)
            .resolve()
        
        XCTAssertEqual(models.map { $0.id }, queriedModels.map { $0.id })
    }
    
    func test_WhenDescSortNoIndex_ThenEqualPlainSort() throws {
        let models = notIndexedModels
            .sorted { $0.value > $1.value }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        let queriedModels = TestModel
            .query(in: context)
            .sorted(by: \.value.desc)
            .resolve()
        
        XCTAssertEqual(models.map { $0.id }, queriedModels.map { $0.id })
        
    }
    
    func test_WhenDescSortIndexed_ThenEqualPlainSort() throws {
        let models = indexedModels
            .sorted { $0.value > $1.value }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        let queriedModels = TestIndexedModel
            .query(in: context)
            .sorted(by: \.value.desc)
            .resolve()
        
        XCTAssertEqual(models.map { $0.id }, queriedModels.map { $0.id })
    }
}

