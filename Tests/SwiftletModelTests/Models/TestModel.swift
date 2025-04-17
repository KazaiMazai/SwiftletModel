//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 30/03/2025.
//

import SwiftletModel
import Foundation

enum TestingModels {
    
}

extension TestingModels {
    @EntityModel
    struct SingleValueIndexed {
        @Index<Self>(\.numOf1) private static var valueIndex
        
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
    struct ExtensivelyIndexed {
        @Index<Self>(\.numOf1) private static var numOf1Index
        @Index<Self>(\.numOf10) private static var numOf10Index
        @Index<Self>(\.numOf100) private static var numOf100Index
        @Index<Self>(\.numOf1000) private static var numOf1000Index
        
        @Index<Self>(\.numOf10, \.numOf1) private static var valueIndex2
        @Index<Self>(\.numOf10.desc, \.numOf1) private static var valueIndexDesc2
        
        @Index<Self>(\.numOf100, \.numOf10, \.numOf1) private static var valueIndex3
        @Index<Self>(\.numOf100, \.numOf10.desc, \.numOf1) private static var valueIndexDesc3
        
        @Index<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1) private static var valueIndex4
        @Index<Self>(\.numOf1000, \.numOf100, \.numOf10.desc, \.numOf1) private static var valueIndexDesc4
       
        
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
    struct EvaluatedPropertyDescIndexed {
        @Index<Self>(\.numOf1.desc) private static var valueIndexDesc
        
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
    struct NotIndexed {
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
    struct UniquelyIndexed {
        @Unique<Self>(\.numOf1, collisions: .throw) private static var valueIndex
        @Unique<Self>(\.numOf10, \.numOf1, collisions: .throw) private static var valueIndex2
        @Unique<Self>(\.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex3
        @Unique<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex4
        
        let id: String
        let numOf1: Int
        let numOf10: Int
        let numOf100: Int
        let numOf1000: Int
    }
    
    @EntityModel
    struct UniquelyIndexedComparable {
        @Unique<Self>(\.numOf1, collisions: .throw) private static var valueIndex
        @Unique<Self>(\.numOf10, \.numOf1, collisions: .throw) private static var valueIndex2
        @Unique<Self>(\.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex3
        @Unique<Self>(\.numOf1000, \.numOf100, \.numOf10, \.numOf1, collisions: .throw) private static var valueIndex4
        
        let id: String
        let numOf1: ComparableBox<Int>
        let numOf10: ComparableBox<Int>
        let numOf100: ComparableBox<Int>
        let numOf1000: ComparableBox<Int>

        init(id: String, numOf1: Int, numOf10: Int, numOf100: Int, numOf1000: Int) {
            self.id = id
            self.numOf1 = ComparableBox(value: numOf1)
            self.numOf10 = ComparableBox(value: numOf10)
            self.numOf100 = ComparableBox(value: numOf100)
            self.numOf1000 = ComparableBox(value: numOf1000)
        }
    }

    @EntityModel
    struct NotIndexedComparable {
        let id: String
        let numOf1: ComparableBox<Int>
        let numOf10: ComparableBox<Int>
        let numOf100: ComparableBox<Int>
        let numOf1000: ComparableBox<Int>
    }

     struct ComparableBox<T: Comparable>: Comparable {
        let value: T

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.value < rhs.value
        } 
    }
    
    @EntityModel
    struct StringFullTextIndexed {
        @FullTextIndex<Self>(\.text) private static var valueIndex
        
        let id: String
        let text: String
        
        init(id: String, text: String) {
            self.id = id
            self.text = text
        }
    }
    
    @EntityModel
    struct StringNotIndexed {
        let id: String
        let text: String
        
        init(id: String, text: String) {
            self.id = id
            self.text = text
        }
    }
}

extension TestingModels.NotIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.NotIndexed] {
        (0..<count)
            .map { idx in TestingModels.NotIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.SingleValueIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.SingleValueIndexed] {
        (0..<count)
            .map { idx in TestingModels.SingleValueIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.EvaluatedPropertyDescIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.EvaluatedPropertyDescIndexed] {
        (0..<count)
            .map { idx in TestingModels.EvaluatedPropertyDescIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}


extension TestingModels.ExtensivelyIndexed {
    static func shuffled(_ count: Int) -> [TestingModels.ExtensivelyIndexed] {
        (0..<count)
            .map { idx in TestingModels.ExtensivelyIndexed(id: "\(idx)", value: idx) }
            .shuffled()
    }
}

extension TestingModels.StringFullTextIndexed {
    static func shuffled() -> [TestingModels.StringFullTextIndexed] {
       Array.fruitTexts
        .enumerated()
        .map { idx, text in TestingModels.StringFullTextIndexed(id: "\(idx)", text: text) }
        .shuffled()
    }
}

extension TestingModels.StringNotIndexed {
    static func shuffled() -> [TestingModels.StringNotIndexed] {
       Array.fruitTexts
        .enumerated()
        .map { idx, text in TestingModels.StringNotIndexed(id: "\(idx)", text: text) }
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



