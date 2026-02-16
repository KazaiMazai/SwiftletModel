//
//  FilterEdgeCaseTest.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 09/01/2026.
//

import SwiftletModel
import Foundation
import Testing

@Suite(.tags(.query, .filter))
struct FilterIndexOutOfBoundsTests {

    var models: [TestingModels.PlainValueIndexed] {
        Range(0...10).map {
            TestingModels.PlainValueIndexed(id: "\($0)", value: $0)
        }
    }

    private func makeContext() throws -> (context: Context, models: [TestingModels.PlainValueIndexed]) {
        var context = Context()
        let models = self.models
        try models
            .reversed()
            .forEach { try $0.save(to: &context) }
        return (context, models)
    }

    @Test("Filter above upper bound returns empty result")
    func whenFilterOutOfUpperBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.value < $1.value })!
        let filteredResult = TestingModels
            .PlainValueIndexed
            .filter(\.value > max.value + 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Filter below lower bound returns empty result")
    func whenFilterOutOfLowerBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.value < $1.value })!
        let filteredResult = TestingModels
            .PlainValueIndexed
            .filter(\.value < min.value - 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Inclusive filter above upper bound returns empty result")
    func whenIncludingFilterOutOfUpperBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let max = models.max(by: { $0.value < $1.value })!
        let filteredResult = TestingModels
            .PlainValueIndexed
            .filter(\.value >= max.value + 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }

    @Test("Inclusive filter below lower bound returns empty result")
    func whenIncludingFilterOutOfLowerBound_ThenEmptyResult() throws {
        let (context, models) = try makeContext()
        let min = models.min(by: { $0.value < $1.value })!
        let filteredResult = TestingModels
            .PlainValueIndexed
            .filter(\.value <= min.value - 1)
            .resolve(in: context)

        #expect(filteredResult.isEmpty)
    }
}
