//
//  FilterEdgeCaseTest.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 09/01/2026.
//

import SwiftletModel
import Foundation
import XCTest

final class FilterIndexOutOfBoundsTests: XCTestCase {
    var context = Context()
    
    lazy var models = {
        Range(0...10).map {
            TestingModels.Indexed.SingleProperty(id: "\($0)", value: $0)
        }
    }()
    
    override func setUp() async throws {
        context = Context()
        try models
            .reversed()
            .forEach { try $0.save(to: &context) }
    }
    
    func test_WhenFilterOutOfUpperBound_ThenEmptyResult() throws {
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 > max.numOf1 + 1)
            .resolve(in: context)
        
        XCTAssertTrue(filteredResult.isEmpty)
    }
    
    func test_WhenFilterOutOfLowerBound_ThenEmptyResult() throws {
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 < min.numOf1 - 1)
            .resolve(in: context)
        
        XCTAssertTrue(filteredResult.isEmpty)
    }
    
    func test_WhenIncludingFilterOutOfUpperBound_ThenEmptyResult() throws {
        let max = models.max(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 >= max.numOf1 + 1)
            .resolve(in: context)
        
        XCTAssertTrue(filteredResult.isEmpty)
    }
    
    func test_WhenIncludingFilterOutOfLowerBound_ThenEmptyResult() throws {
        let min = models.min(by: { $0.numOf1 < $1.numOf1 })!
        let filteredResult = TestingModels
            .Indexed.SingleProperty
            .filter(\.numOf1 <= min.numOf1 - 1)
            .resolve(in: context)
        
        XCTAssertTrue(filteredResult.isEmpty)
    }
}
