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
    func testSortNoIndexPerformance() throws {
        let count = 1000
        let models = (0..<count).map { idx in
            TestModel(id: "\(idx)", value: idx)
        }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        measure {
            let _ = TestModel.query(in: context)
                .sorted(by: \.value)
                .resolve()
        }
        
    }
    
    func testSortIndexedPerformance() throws {
        let count = 1000
        let models = (0..<count).map { idx in
            TestIndexedModel(id: "\(idx)", value: idx)
        }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        measure {
            let _ = TestIndexedModel.query(in: context)
                .sorted(by: \.value)
                .resolve()
        }
         
    }
    
    func testSortIndexedDescPerformance() throws {
        let count = 1000
        let models = (0..<count).map { idx in
            TestIndexedModel(id: "\(idx)", value: idx)
        }
       
        var context = Context()
        try models.forEach {  try $0.save(to: &context) }
        
        measure {
            let _ = TestIndexedModel.query(in: context)
                .sorted(by: \.value.desc)
                .resolve()
        }
         
    }
    
    func testNoIndexBuildPerformance() throws {
        let count = 1000
        let models = (0..<count).map { idx in
            TestModel(id: "\(idx)", value: idx)
        }
       
        var context = Context()
        measure {
            try! models.forEach {  try $0.save(to: &context) }
        }
        
    }
    
    func testIndexBuildPerformance() throws {
        let count = 1000
        let models = (0..<count).map { idx in
            TestIndexedModel(id: "\(idx)", value: idx)
        }
       
        var context = Context()
        measure {
            try! models.forEach {  try $0.save(to: &context) }
        }
         
    }
}

