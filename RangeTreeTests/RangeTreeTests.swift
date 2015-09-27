//
//  RangeTreeTests.swift
//  RangeTreeTests
//
//  Created by John Langley on 9/26/15.
//  Copyright © 2015 Omada Health. All rights reserved.
//

import XCTest
@testable import RangeTree

class RangeTreeTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTreeConstructionSpeed() {
        let objectRange: ClosedInterval<CDouble> = -100...100
        let objects = TestObject.objectsWithCount(100000, xInterval: objectRange, yInterval: objectRange)

        var rangeTree: RangeTree<TestObject>!
        self.measureBlock {
            rangeTree = RangeTree(objects: objects)
        }
        
        let queryInterval: ClosedInterval<CDouble> = -50...50
        let queryResult = rangeTree.objectsInXInterval(queryInterval, yInterval: queryInterval)
        
        XCTAssert(self.subset(queryResult, containsAllObjectsOf: objects, inXInterval: queryInterval, YInterval: queryInterval))
    }

    func testQuerySpeed() {
        let objectRange: ClosedInterval<CDouble> = -100...100
        let objects = TestObject.objectsWithCount(10, xInterval: objectRange, yInterval: objectRange)
        let rangeTree = RangeTree(objects: objects)
        
        let queryInterval: ClosedInterval<CDouble> = -50...50
        var queryResult: Set<TestObject>!
        self.measureBlock {
            queryResult = rangeTree.objectsInXInterval(queryInterval, yInterval: queryInterval)
        }
        
        XCTAssert(self.subset(queryResult, containsAllObjectsOf: objects, inXInterval: queryInterval, YInterval: queryInterval))
    }
    
    private func subset(subset: Set<TestObject>, containsAllObjectsOf set: Set<TestObject>, inXInterval xInterval: ClosedInterval<CDouble>, YInterval yInterval: ClosedInterval<CDouble>) -> Bool {

        for object in subset {
            if !set.contains(object) || !xInterval.contains(object.x) || !yInterval.contains(object.y) {
                return false
            }
        }

        let setDifference = set.subtract(subset)
        for object in setDifference {
            if xInterval.contains(object.x) && yInterval.contains(object.y) {
                return false
            }
        }
        
        return true
    }
}


