//
//  XYNodeTests.m
//  OCRangeTree
//
//  Created by John Langley on 12/30/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XYNode.h"

@interface XYNodeTests : XCTestCase

@end

@implementation XYNodeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - XYNodeTests
#pragma mark -

// Method Signiature:
// static inline void XYNodeSwapContents(XYNode x, XYNode y)
- (void)testXYNodeSwapContents
{
    NSObject *object1 = [NSObject new];
    NSObject *object2 = [NSObject new];
    
    XYNode node1 = XYNodeMake(1, 2, (__bridge void *)(object1));
    XYNode node2 = XYNodeMake(3, 4, (__bridge void *)(object2));
    
    XYNodeSwapContents(&node1, &node2);
    
    XCTAssert(node1.coords[0] == 3 && node1.coords[1] == 4 && node1.object == (__bridge void *)object2);
    XCTAssert(node2.coords[0] == 1 && node2.coords[1] == 2 && node2.object == (__bridge void *)object1);
}

// Method Signiatures:
// bool XYNodeIsInXRange(XYNode node, XYRange xRange);
// bool XYNodeIsInYRange(XYNode node, XYRange yRange);
// bool XYNodeIsInXYRange(XYNode node, XYRange xRange, XYRange yRange);
- (void)testXYNodeIsInXRange
{
    XYNode node = XYNodeMake(0, 0, NULL);
    
    // In range
    XCTAssertTrue(XYNodeIsInXRange(&node, XYRangeMax));
    
    // Out of range
    XCTAssertFalse(XYNodeIsInXRange(&node, XYRangeMake(1, 100, true)));
}

- (void)testXYNodeIsInYRange
{
    XYNode node = XYNodeMake(0, 0, NULL);
    
    // In range
    XCTAssertTrue(XYNodeIsInYRange(&node, XYRangeMax));
    
    // Out of range
    XCTAssertFalse(XYNodeIsInYRange(&node, XYRangeMake(1, 100, true)));
}

- (void)testXYNodeIsInXYRange
{
    XYNode node = XYNodeMake(0, 0, NULL);
    
    // In range
    XCTAssertTrue(XYNodeIsInXYRange(&node, XYRangeMax, XYRangeMax));

    // X is out of range
    XCTAssertFalse(XYNodeIsInXYRange(&node, XYRangeMake(1, 100, true), XYRangeMax));

    // Y is out of range
    XCTAssertFalse(XYNodeIsInXYRange(&node, XYRangeMax, XYRangeMake(1, 100, true)));

    // X is out of range because range is not inclusive
    XCTAssertFalse(XYNodeIsInXYRange(&node, XYRangeMake(0, 100, false), XYRangeMax));

    // Y is out of range because range is not inclusive
    XCTAssertFalse(XYNodeIsInXYRange(&node, XYRangeMax, XYRangeMake(0, 100, false)));
}



#pragma mark - XYLinkedNode Tests
#pragma mark -

// Method Signiature
//static inline XYLinkedNode XYLinkedNodeMake(XYNode *node, XYLinkedNode *previous, XYLinkedNode *next)
- (void)testXYLinkedNodeMake
{
    XYNode node = XYNodeMake(2, 2, NULL);
    
    XYNode previousNode = XYNodeMake(1, 1, NULL);
    XYLinkedNode *linkedPreviousNode = XYLinkedNodeMake(&previousNode, NULL, NULL);

    XYNode nextNode = XYNodeMake(3, 3, NULL);
    XYLinkedNode *linkedNextNode = XYLinkedNodeMake(&nextNode, NULL, NULL);
    
    // Success Case
    XYLinkedNode *linkedNode = XYLinkedNodeMake(&node, linkedPreviousNode, linkedNextNode);
    XCTAssertTrue(linkedNode->node == &node && linkedPreviousNode->node == &previousNode && linkedNextNode->node == &nextNode);
    XCTAssertTrue(linkedNode->previous->node == &previousNode && linkedPreviousNode->next->node == &node);
    XCTAssertTrue(linkedNode->next == linkedNextNode && linkedNextNode->previous == linkedNode);

    // Failure Case
    XYLinkedNode *linkedNullNode = XYLinkedNodeMake(NULL, linkedPreviousNode, linkedNextNode);
    XCTAssertTrue(linkedNullNode->node == NULL);
    XCTAssertTrue(linkedNullNode->next == linkedNextNode);
    XCTAssertTrue(linkedNullNode->previous == linkedPreviousNode);
}

#pragma mark - XYNodeSetTests
#pragma mark -

// Method Signiature:
//static inline XYNodeSet XYNodeSetMake(XYLinkedNode *head, XYLinkedNode *tail, int count)
- (void)testXYNodeSetMake
{
    XYNode previousNode = XYNodeMake(1, 1, NULL);
    XYLinkedNode *linkedPreviousNode = XYLinkedNodeMake(&previousNode, NULL, NULL);
    
    XYNode nextNode = XYNodeMake(3, 3, NULL);
    XYLinkedNode *linkedNextNode = XYLinkedNodeMake(&nextNode, NULL, NULL);
 
    XYNode node = XYNodeMake(2, 2, NULL);
    XYLinkedNode *linkedNode = XYLinkedNodeMake(&node, linkedPreviousNode, linkedNextNode);
    
    // Success Cases
    XYNodeSet *fullSet = XYNodeSetMake(linkedPreviousNode, linkedNextNode, 3);
    XCTAssert(fullSet->count == 3 && fullSet->first == linkedPreviousNode && fullSet->last == linkedNextNode);
    XCTAssert(fullSet->first->next == linkedNode && fullSet->first->next->next == linkedNextNode);
    
    XYNodeSet *emptySet = XYNodeSetMake(NULL, NULL, 27);
    XCTAssert(emptySet->count == 0 && emptySet->first == NULL && emptySet->last == NULL);
    
    // Corner Cases
    XYNodeSet *oneSet = XYNodeSetMake(linkedNode, NULL, 5);
    XCTAssert(oneSet->first == linkedNode && oneSet->last == linkedNode && oneSet->count == 1);
    
    oneSet = XYNodeSetMake(NULL, linkedNode, 9);
    XCTAssert(oneSet->first == linkedNode && oneSet->last == linkedNode && oneSet->count == 1);
}


// Method Signiature:
// static inline void XYNodeSetAddNode(XYNodeSet *set, XYNode *node)
- (void)testXYNodeSetAddNode
{
    XYNode previousNode = XYNodeMake(1, 1, NULL);
    XYLinkedNode *linkedPreviousNode = XYLinkedNodeMake(&previousNode, NULL, NULL);
    
    XYNode nextNode = XYNodeMake(3, 3, NULL);
    XYLinkedNode *linkedNextNode = XYLinkedNodeMake(&nextNode, NULL, NULL);
    
    XYNode node = XYNodeMake(2, 2, NULL);
    XYLinkedNodeMake(&node, linkedPreviousNode, linkedNextNode);

    XYNodeSet *set = XYNodeSetMake(linkedPreviousNode, linkedNextNode, 3);
    XCTAssert(set->first == linkedPreviousNode && set->last == linkedNextNode);
    
    // Success Cases
    XYNode newNode = XYNodeMake(4, 4, NULL);
    XYNodeSetAddNode(set, &newNode);
    XCTAssert(set->last->node == &newNode && set->last->previous == linkedNextNode && set->count == 4);


    // Corner Cases
    XYNodeSetAddNode(set, NULL);
    XCTAssert(set->last->node == &newNode && set->last->previous == linkedNextNode && set->count == 4);

    XYNode secondNode = XYNodeMake(5, 5, NULL);
    XYNodeSetAddNode(NULL, &secondNode);
    XCTAssert(set->last->node == &newNode && set->last->previous == linkedNextNode && set->count == 4);
    
    XYNodeSetAddNode(NULL, NULL);
    // Should do nothing ...

}

// Method Signiature:
// static inline void XYNodeSetRemoveNode(XYNodeSet *set, XYNode *node)
- (void)testXYNodeSetRemoveNode
{
    XYNode node1 = XYNodeMake(1, 1, NULL);
    XYNode node2 = XYNodeMake(2, 2, NULL);
    XYNode node3 = XYNodeMake(3, 3, NULL);
    XYNode node4 = XYNodeMake(4, 4, NULL);
    XYNode node5 = XYNodeMake(5, 5, NULL);
    
    XYNodeSet *set = XYNodeSetMake(NULL, NULL, 0);

    XYNodeSetAddNode(set, &node1);
    XYNodeSetAddNode(set, &node2);
    XYNodeSetAddNode(set, &node3);
    XYNodeSetAddNode(set, &node4);
    XYNodeSetAddNode(set, &node5);
    
    XCTAssert(set->first->node == &node1 && set->last->node == &node5 && set->count == 5);
    
    XYNodeSetRemoveNode(set, &node5);
    XCTAssert(set->first->node == &node1 && set->last->node == &node4 && set->count == 4);
    
    XYNodeSetRemoveNode(set, &node1);
    XCTAssert(set->first->node == &node2 && set->last->node == &node4 && set->count == 3);
    
    XYNodeSetRemoveNode(set, &node2);
    XYNodeSetRemoveNode(set, &node3);
    XYNodeSetRemoveNode(set, &node4);
    
    XCTAssert(!set->first && !set->last && set->count == 0);
}

@end
