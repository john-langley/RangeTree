//
//  TestObject.swift
//  OMRangeTree
//
//  Created by John Langley on 9/26/15.
//  Copyright © 2015 Omada Health. All rights reserved.
//

import Foundation
import RangeTree

@objc class TestObject : NSObject, TwoDimensional {
    
    let x: CDouble
    let y: CDouble
    
    static func objectsWithCount(count: Int, xInterval: ClosedInterval<CDouble>, yInterval: ClosedInterval<CDouble>) -> Set<TestObject> {
        var objects = Set<TestObject>()
        for _ in 0 ..< count {
            let x = randomCDoubleInInterval(xInterval)
            let y = randomCDoubleInInterval(yInterval)
            objects.insert(TestObject(x: x, y: y))
        }
        return objects
    }
    
    required init(x: CDouble, y: CDouble) {
        self.x = x
        self.y = y
    }
    
    private static func randomCDoubleInInterval(interval: ClosedInterval<CDouble>) -> CDouble {
        let min = interval.start < interval.end ? interval.start : interval.end
        let max = interval.end > interval.start ? interval.end : interval.start
        let diff = max - min
        let random = CDouble(arc4random()) / 0xFFFFFFFF
        return min + diff * random
    }
}

