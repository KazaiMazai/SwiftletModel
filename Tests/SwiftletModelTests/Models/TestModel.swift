//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 30/03/2025.
//

import SwiftletModel
import Foundation

enum TestingModels {
    enum Indexed {}
    enum NotIndexed {}

    struct ComparableBox<T: Comparable>: Comparable, Sendable where T: Sendable {
        let value: T

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.value < rhs.value
        }
    }
}

// MARK: - Indexed Models

extension TestingModels.Indexed {
    @EntityModel
    struct PlainValue {
        @Index<Self>(\.value) private var valueIndex

        let id: String
        let value: Int

        init(id: String, value: Int) {
            self.id = id
            self.value = value
        }
    }

    @EntityModel
    struct SingleValue {
        @Index<Self>(\.numOf1) private var valueIndex

        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int

        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf10 = (value / 10) % 10
            self.numOf100 = (value / 100) % 10
            self.numOf1000 = value / 1000
        }
    }

    @EntityModel
    struct Extensively {
        @Index<Self>(\.numOf1) private var numOf1Index
        @Index<Self>(\.numOf10) private var numOf10Index
        @Index<Self>(\.numOf100) private var numOf100Index
        @Index<Self>(\.numOf1000) private var numOf1000Index

        @Index<Self>(\.numOf10, \.numOf1) private var valueIndex2
        @Index<Self>(\.numOf10.desc, \.numOf1) private var valueIndexDesc2

        @Index<Self>(\.numOf100, \.numOf10, \.numOf1) private var valueIndex3
        @Index<Self>(\.numOf100, \.numOf10.desc, \.numOf1) private var valueIndexDesc3

        @Index<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1) private var valueIndex4
        @Index<Self>(\.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1) private var valueIndexDesc4

        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int

        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf10 = (value / 10) % 10
            self.numOf100 = (value / 100) % 10
            self.numOf1000 = value / 1000
        }
    }

    @EntityModel
    struct EvaluatedPropertyDesc {
        @Index<Self>(\.numOf1.desc) private var valueIndexDesc

        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int

        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf1000 = value / 1000
            self.numOf100 = value / 100
            self.numOf10 = value / 10
        }
    }

    @EntityModel
    struct Uniquely {
        @Unique<Self>(\.numOf1, collisions: .throw) private var valueIndex
        @Unique<Self>(\.numOf10, \.numOf1, collisions: .throw) private var valueIndex2
        @Unique<Self>(\.numOf100, \.numOf10, \.numOf1, collisions: .throw) private var valueIndex3
        @Unique<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1, collisions: .throw) private var valueIndex4

        let id: String
        let numOf1: Int
        let numOf10: Int
        let numOf100: Int
        let numOf1000: Int
    }

    @EntityModel
    struct UniquelyComparable {
        @Unique<Self>(\.numOf1, collisions: .throw) private var valueIndex
        @Unique<Self>(\.numOf10, \.numOf1, collisions: .throw) private var valueIndex2
        @Unique<Self>(\.numOf100, \.numOf10, \.numOf1, collisions: .throw) private var valueIndex3
        @Unique<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1, collisions: .throw) private var valueIndex4

        let id: String
        let numOf1: TestingModels.ComparableBox<Int>
        let numOf10: TestingModels.ComparableBox<Int>
        let numOf100: TestingModels.ComparableBox<Int>
        let numOf1000: TestingModels.ComparableBox<Int>

        init(id: String, numOf1: Int, numOf10: Int, numOf100: Int, numOf1000: Int) {
            self.id = id
            self.numOf1 = TestingModels.ComparableBox(value: numOf1)
            self.numOf10 = TestingModels.ComparableBox(value: numOf10)
            self.numOf100 = TestingModels.ComparableBox(value: numOf100)
            self.numOf1000 = TestingModels.ComparableBox(value: numOf1000)
        }
    }

    @EntityModel
    struct StringFullText {
        @FullTextIndex<Self>(\.text) private var valueIndex

        let id: String
        let text: String
    }

    // MARK: - HashIndex Models

    @EntityModel
    struct Hash: Sendable {
        @HashIndex<Self>(\.category) private var categoryIndex

        let id: String
        let category: String
        let value: Int

        init(id: String, category: String, value: Int) {
            self.id = id
            self.category = category
            self.value = value
        }
    }

    @EntityModel
    struct HashPair: Sendable {
        @HashIndex<Self>(\.category, \.subcategory) private var compoundIndex

        let id: String
        let category: String
        let subcategory: String
        let value: Int

        init(id: String, category: String, subcategory: String, value: Int) {
            self.id = id
            self.category = category
            self.subcategory = subcategory
            self.value = value
        }
    }

    @EntityModel
    struct HashTriplet: Sendable {
        @HashIndex<Self>(\.region, \.category, \.subcategory) private var compoundIndex

        let id: String
        let region: String
        let category: String
        let subcategory: String

        init(id: String, region: String, category: String, subcategory: String) {
            self.id = id
            self.region = region
            self.category = category
            self.subcategory = subcategory
        }
    }

    @EntityModel
    struct HashQuadruple: Sendable {
        @HashIndex<Self>(\.region, \.country, \.category, \.subcategory) private var compoundIndex

        let id: String
        let region: String
        let country: String
        let category: String
        let subcategory: String

        init(id: String, region: String, country: String, category: String, subcategory: String) {
            self.id = id
            self.region = region
            self.country = country
            self.category = category
            self.subcategory = subcategory
        }
    }
}

// MARK: - NotIndexed Models

extension TestingModels.NotIndexed {
    @EntityModel
    struct Plain {
        let id: String
        let numOf1: Int
        let numOf1000: Int
        let numOf100: Int
        let numOf10: Int

        init(id: String, value: Int) {
            self.id = id
            self.numOf1 = value % 10
            self.numOf1000 = value / 1000
            self.numOf100 = value / 100
            self.numOf10 = value / 10
        }
    }

    @EntityModel
    struct Comparable {
        let id: String
        let numOf1: TestingModels.ComparableBox<Int>
        let numOf10: TestingModels.ComparableBox<Int>
        let numOf100: TestingModels.ComparableBox<Int>
        let numOf1000: TestingModels.ComparableBox<Int>
    }

    @EntityModel
    struct StringPlain {
        let id: String
        let text: String
    }
}

// MARK: - Factory Methods

extension TestingModels.NotIndexed.Plain {
    static func shuffled(_ count: Int) -> [TestingModels.NotIndexed.Plain] {
        (0..<count)
            .map { idx in TestingModels.NotIndexed.Plain(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.Indexed.SingleValue {
    static func shuffled(_ count: Int) -> [TestingModels.Indexed.SingleValue] {
        (0..<count)
            .map { idx in TestingModels.Indexed.SingleValue(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.Indexed.EvaluatedPropertyDesc {
    static func shuffled(_ count: Int) -> [TestingModels.Indexed.EvaluatedPropertyDesc] {
        (0..<count)
            .map { idx in TestingModels.Indexed.EvaluatedPropertyDesc(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.Indexed.Extensively {
    static func shuffled(_ count: Int) -> [TestingModels.Indexed.Extensively] {
        (0..<count)
            .map { idx in TestingModels.Indexed.Extensively(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.Indexed.StringFullText {
    static func shuffled() -> [TestingModels.Indexed.StringFullText] {
       Array.fruitTexts
        .enumerated()
        .map { idx, text in TestingModels.Indexed.StringFullText(id: "\(idx)", text: text) }
        .shuffled()
    }
}

extension TestingModels.NotIndexed.StringPlain {
    static func shuffled() -> [TestingModels.NotIndexed.StringPlain] {
       Array.fruitTexts
        .enumerated()
        .map { idx, text in TestingModels.NotIndexed.StringPlain(id: "\(idx)", text: text) }
        .shuffled()
    }
}

extension TestingModels.Indexed.Hash {
    static func shuffled(_ count: Int) -> [TestingModels.Indexed.Hash] {
        let categories = ["A", "B", "C", "D", "E"]
        return (0..<count)
            .map { idx in TestingModels.Indexed.Hash(id: "\(idx)", category: categories[idx % 5], value: idx) }
            .shuffled()
    }
}

fileprivate extension Array where Element == String {
    static var fruitTexts: [String] {
        let baseTexts = [
            "Fresh bananas from Ecuador",
            "Sweet ananas juice for breakfast",
            "Banana split with ice cream",
            "Tropical ananases in my garden",
            "Bananas and ananases smoothie",
            "Multiple bananas in the basket",
            "Fresh cut ananas pieces",
            "Green bananas need time to ripen",
            "Sweet and sour ananas cake",
            "Banana bread recipe",
            "Candied citron peel",
            "Fresh yuzu kosho paste",
            "Sweet canistel pudding",
            "Tart cornelian cherries",
            "Fresh damson plum jam",
            "Wild huckleberry muffins",
            "Sweet imbe fruit pulp",
            "Fresh jamun berry juice",
            "Ripe kei apple preserve",
            "Juicy langsat clusters",
            "Sweet lucuma ice cream",
            "Fresh marang pieces",
            "Wild mora berry sauce",
            "Sweet nance fruit syrup",
            "Fresh otaheite apple",
            "Ripe phalsa berries",
            "Sweet pulasan fruit",
            "Fresh rollinia cream",
            "Wild santol preserve",
            "Sweet tacoma cherries",
            "Fresh uvaia compote",
            "Ripe voavanga fruit",
            "Sweet wampee juice",
            "Fresh ximenia berries",
            "Wild yangmei harvest",
            "Sweet zalacca pieces",
            "Dried barberry garnish",
            "Fresh bael fruit tea",
            "Sweet carissa jam",
            "Fresh duku langsat",
            "Ripe egg fruit smoothie",
            "Sweet finger lime caviar",
            "Fresh gac fruit juice",
            "Wild horned melon",
            "Sweet ice cream bean",
            "Fresh jabotikaba tart",
            "Ripe kakadu plum",
            "Sweet kutjera berry",
            "Fresh lillypilly jam",
            "Wild mombin juice",
            "Sweet noni extract",
            "Fresh olive fruit oil",
            "Ripe peanut butter fruit",
            "Sweet quandong sauce",
            "Fresh rose apple tea",
            "Wild safou fruit",
            "Sweet tamarillo jam",
            "Fresh uva ursi berries",
            "Ripe velvet apple",
            "Sweet wax jambu",
            "Dried acai berry powder",
            "Fresh ackee and saltfish",
            "Sweet ambarella chutney",
            "Tart arbutus berries",
            "Fresh averrhoa juice",
            "Wild bignay wine",
            "Sweet bush butter fruit",
            "Fresh calabash syrup",
            "Wild chayote pickle",
            "Sweet cocoplum jam",
            "Fresh davidsonia plum",
            "Ripe desert fig",
            "Sweet elephant apple",
            "Fresh false mastic",
            "Wild gingerbread plum",
            "Sweet grewia berries",
            "Fresh hackberry preserve",
            "Wild ilama cream",
            "Sweet jaboticaba liqueur",
            "Fresh kahikatea berry",
            "Wild korlan fruit",
            "Sweet lardizabala jam",
            "Fresh madrone berry",
            "Wild natal plum",
            "Sweet oregon grape",
            "Fresh patawa fruit",
            "Wild quararibea pulp",
            "Sweet riberry sauce",
            "Fresh soncoya juice",
            "Wild tallow plum"
        ]

        let locations = ["garden", "market", "farm", "orchard", "grove", "plantation", "forest", "valley", "hills", "coast"]
        let preparations = ["juice", "smoothie", "jam", "preserve", "sauce", "syrup", "dessert", "salad", "pie", "compote"]
        let descriptors = ["organic", "wild", "fresh", "sweet", "ripe", "local", "exotic", "tropical", "seasonal", "handpicked"]

        var expandedTexts = baseTexts

        for text in baseTexts {
            if let fruit = text.split(separator: " ").last {
                for location in locations {
                    expandedTexts.append("Premium \(fruit) from the \(location)")
                }
                for prep in preparations {
                    expandedTexts.append("Homemade \(fruit) \(prep)")
                }
                for descriptor in descriptors {
                    expandedTexts.append("\(descriptor.capitalized) \(fruit) selection")
                }
            }
        }

        return expandedTexts.shuffled()
    }
}
