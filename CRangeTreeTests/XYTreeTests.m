//
//  XYTreeTests.m
//  OCRangeTree
//
//  Created by John Langley on 12/29/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "XYTree.h"

@interface XYTreeTests : XCTestCase

@end

@implementation XYTreeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark - XYTreePartitionNodesAroundPivot(XYNode **left, XYNode **right, XYNode **pivot, int dimension)
#pragma mark -
extern XYNode ** XYTreePartitionNodesAroundPivot(XYNode **left, XYNode **right, XYNode **pivot, int dimension);

- (void)testXYTreePartitionNodesAroundPivot_Corner_Cases
{
    XYNode *node1 = XYNodePtrMake(1, 2, NULL);
    XYNode *node2 = XYNodePtrMake(2, 1, NULL);
    
    XYNode **nodes = malloc(2 * sizeof(XYNode *));
    nodes[0] = node1;
    nodes[1] = node2;
    
    // Invalid input
    
    XYNode ** result = XYTreePartitionNodesAroundPivot(NULL, &node2, &node2, 0);
    XCTAssertTrue(result == NULL);

    result = XYTreePartitionNodesAroundPivot(&node1, NULL, &node2, 0);
    XCTAssertTrue(result == NULL);

    result = XYTreePartitionNodesAroundPivot(&node1, &node2, NULL, 0);
    XCTAssertTrue(result == NULL);
    
    // Weird cases
    // Dimensions that exceed the range of the node are used, expected behavior is to use the result of % 2
    
    // One node
    XYNode **oneNodePtrArray = malloc(sizeof(XYNode *));
    oneNodePtrArray[0] = node1;
    result = XYTreePartitionNodesAroundPivot(oneNodePtrArray, oneNodePtrArray, oneNodePtrArray, 13);
    XCTAssertTrue(result != NULL && (*result)->coords[0] == 1 && result == oneNodePtrArray);
    
    // Two nodes, order should be reversed
    XYNode **twoNodePtrArray = malloc(2 * sizeof(XYNode *));
    twoNodePtrArray[0] = node2;
    twoNodePtrArray[1] = node1;
    result = XYTreePartitionNodesAroundPivot(twoNodePtrArray, twoNodePtrArray + 1, twoNodePtrArray, 12);
    XCTAssertEqual((*result)->coords[0], 2);
    XCTAssert(result == (twoNodePtrArray + 1) && *result == node2);
    XCTAssert((*twoNodePtrArray)->coords[0] == 1 && *twoNodePtrArray == node1);
    
    // Duplicate Values
    XYNode **duplicates = malloc(5 * sizeof(XYNode **));
    duplicates[0] = XYNodePtrMake(5, 5, NULL);
    duplicates[1] = XYNodePtrMake(4, 4, NULL);
    duplicates[2] = XYNodePtrMake(5, 5, NULL);
    duplicates[3] = XYNodePtrMake(5, 5, NULL);
    duplicates[4] = XYNodePtrMake(1, 1, NULL);
    
    result = XYTreePartitionNodesAroundPivot(duplicates, duplicates + 4, duplicates + 1, 0);
    XCTAssert((*duplicates)->coords[0] == 1);
    XCTAssert(result == duplicates + 1 && (*result)->coords[0] == 4);
    XCTAssert(duplicates[2]->coords[0] == 5);
    XCTAssert(duplicates[3]->coords[0] == 5);
    XCTAssert(duplicates[4]->coords[0] == 5);

    XCTAssertTrue([[self class] nodes:duplicates withCount:5 arePartitionedBy:duplicates + 1 dimension:0]);

    free(node1);
    free(node2);
    free(nodes);
}

- (void)testXYTreePartitionNodesAroundPivot_Fine
{
    XYNode **nodes = malloc(10 * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(10, 6, NULL);
    nodes[1] = XYNodePtrMake(1, 5, NULL);
    nodes[2] = XYNodePtrMake(9, 7, NULL);
    nodes[3] = XYNodePtrMake(2, 4, NULL);
    nodes[4] = XYNodePtrMake(8, 8, NULL);
    nodes[5] = XYNodePtrMake(3, 3, NULL);
    nodes[6] = XYNodePtrMake(7, 9, NULL);
    nodes[7] = XYNodePtrMake(4, 2, NULL);
    nodes[8] = XYNodePtrMake(6, 10, NULL);
    nodes[9] = XYNodePtrMake(5, 1, NULL);
    
    XYNode **xPivot = XYTreePartitionNodesAroundPivot(nodes, nodes + 9, nodes + 9, 0);

    XCTAssertTrue((*xPivot)->coords[0] == 5 && xPivot == nodes + 4);

    
    int yPivotIndex = 0;
    for(int i = 0; i < 10; i++) {
        if((*nodes[i]).coords[1] == 5) yPivotIndex = i;
    }

    XYNode **yPivot = XYTreePartitionNodesAroundPivot(nodes, nodes + 9, nodes + yPivotIndex, 1);
    XCTAssertTrue((*yPivot)->coords[1] == 5 && yPivot == nodes + 4);

    free(nodes);
}

- (void)testXYTreePartitionNodesAroundPivot_Coarse
{
    int nodeCount = 10000;
    double nodeMin = -100;
    double nodeMax = 100;
    
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode **));
    double *doubles = [[self class] randomDoublesWithCount:(nodeCount * 2) min:nodeMin max:nodeMax];
    for(int i = 0; i < nodeCount; i++) {
        nodes[i] = XYNodePtrMake(doubles[i], doubles[nodeCount + i], NULL);
    }
    
    XYNode **pivot = XYTreePartitionNodesAroundPivot(nodes, nodes + nodeCount - 1,nodes, 0);
    XCTAssertTrue([[self class] nodes:nodes withCount:nodeCount arePartitionedBy:pivot dimension:0]);

    free(doubles);
    free(nodes);
}


#pragma mark - XYNode ** XYTreeSelectMedianFromNodes(XYNode **list, long count, int dimension)
#pragma mark -
extern XYNode ** XYTreeSelectMedianFromNodes(XYNode **list, long count, int dimension);
- (void)testXYTreeSelectMedianFromNodes_Corner_Cases
{
    long nodeCount = 6;

    // Duplicates
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(2, 2, NULL);
    nodes[1] = XYNodePtrMake(1, 1, NULL);
    nodes[2] = XYNodePtrMake(1, 1, NULL);
    nodes[3] = XYNodePtrMake(1, 1, NULL);
    nodes[4] = XYNodePtrMake(1, 1, NULL);
    nodes[5] = XYNodePtrMake(1, 1, NULL);
    
    XYNode **median = XYTreeSelectMedianFromNodes(nodes, nodeCount, 0);
    XCTAssert(median == nodes + 2 && (*median)->coords[0] == 1);
    
    for(int i = 0; i < 6; i++) {
        free(nodes[i]);
    }
    free(nodes);
}

- (void)testXYTreeSelectMedianFromNodes_Fine
{
    long nodeCount = 5;
    
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(3, 2, NULL);
    nodes[1] = XYNodePtrMake(1, 4, NULL);
    nodes[2] = XYNodePtrMake(5, 5, NULL);
    nodes[3] = XYNodePtrMake(4, 1, NULL);
    nodes[4] = XYNodePtrMake(2, 3, NULL);
    
    XYNode **xMedian = XYTreeSelectMedianFromNodes(nodes, nodeCount, 0);
    XCTAssertTrue((*xMedian)->coords[0] == 3);

    XYNode **yMedian = XYTreeSelectMedianFromNodes(nodes, nodeCount, 1);
    XCTAssertTrue((*yMedian)->coords[1] == 3);
    
    for(int i = 0; i < nodeCount; i++) {
        free(nodes[i]);
    }
    free(nodes);
}

- (void)testXYTreeSelectMedianFromNodes_Coarse
{
    int nodeCount = 1000;
    double nodeMin = -100;
    double nodeMax = 100;
    
    XYNode **nodes = malloc((nodeCount) * sizeof(XYNode));
    double *doubles = [[self class] randomDoublesWithCount:(nodeCount * 2) min:nodeMin max:nodeMax];
    for(int i = 0; i < nodeCount; i++) {
        nodes[i] = XYNodePtrMake(doubles[i], doubles[nodeCount + i], NULL);
    }
    
    __block XYNode **median;
    [self measureBlock:^{
        median = XYTreeSelectMedianFromNodes(nodes, nodeCount, 0);
    }];
    
    XCTAssertTrue(median == nodes + (nodeCount - 1) / 2);
    
    [[self class] nodes:nodes withCount:nodeCount arePartitionedBy:median dimension:0];
    
    XCTAssertTrue([[self class] nodes:nodes withCount:nodeCount arePartitionedBy:median dimension:0]);
    
    free(doubles);
    free(nodes);
}


// Method Signiature:
#pragma mark - XYTree XYTreeMake(XYNode *nodes, int count);
#pragma mark -

- (void)testXYTreeMake_Corner_Cases
{
    
}

- (void)testXYTreeMake_Success_Fine
{
    int nodeCount = 5;
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(1, 1, NULL);
    nodes[1] = XYNodePtrMake(1, 1, NULL);
    nodes[2] = XYNodePtrMake(1, 1, NULL);
    nodes[3] = XYNodePtrMake(1, 1, NULL);
    nodes[4] = XYNodePtrMake(2, 2, NULL);

    XYTree *tree = XYTreeMake(nodes, nodeCount);
    
    XCTAssertTrue([[self class] treeIsValid2DTree:tree]);
    free(nodes);
    
    nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(-5, -5, NULL);
    nodes[1] = XYNodePtrMake(-4, -3, NULL);
    nodes[2] = XYNodePtrMake(0, 0, NULL);
    nodes[3] = XYNodePtrMake(3, 4, NULL);
    nodes[4] = XYNodePtrMake(5, 5, NULL);
    
    XYTree *tree2 = XYTreeMake(nodes, 5);

    XCTAssertTrue([[self class] treeIsValid2DTree:tree2]);
    
    free(nodes);
}


- (void)testXYTreeMake_Success_Coarse
{
    int nodeCount = 100000;
    double nodeMin = -100;
    double nodeMax = 100;
    
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    double *doubles = [[self class] randomDoublesWithCount:nodeCount * 2 min:nodeMin max:nodeMax];
    for(int i = 0; i < nodeCount; i++) {
        nodes[i] = XYNodePtrMake(doubles[i], doubles[nodeCount + i], NULL);
    }

    XYTree __block *tree;
    [self measureBlock:^{
        tree = XYTreeMake(nodes, nodeCount);
    }];

    XCTAssertTrue([[self class] treeIsValid2DTree:tree]);
    
    free(doubles);
    for(int i = 0; i < nodeCount; i++) {
        free(nodes[i]);
    }
    free(nodes);
}

#pragma mark - XYNodeSet XYTreeNodesInXRange(XYTree tree, XYRange xRange);
#pragma mark -

- (void)testXYTreeNodesInXRange_Corner_Cases
{
    // No Tree
    XYNodeSet *nodeSet = XYTreeNodesInXRange(nil, XYRangeMax);
    XCTAssert(!nodeSet);
    
    // Empty Tree
    XYNode **nodes;
    XYTree *tree = XYTreeMake(nodes, 0);
    
    nodeSet = XYTreeNodesInXRange(tree, XYRangeMax);
    XCTAssertEqual(nodeSet->count, 0);
    free(nodeSet);
    
    // No matching nodes
    int nodeCount = 5;
    nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(-50, 50, nil);
    nodes[1] = XYNodePtrMake(-25, 25, nil);
    nodes[2] = XYNodePtrMake(0, 0, nil);
    nodes[3] = XYNodePtrMake(25, -25, nil);
    nodes[4] = XYNodePtrMake(50, -50, nil);
    
    tree = XYTreeMake(nodes, nodeCount);
    nodeSet = XYTreeNodesInXRange(tree, XYRangeMake(100, 200, YES));
    XCTAssertEqual(nodeSet->count, 0);
    free(nodeSet);
    
    // All Matching objects
    nodeSet = XYTreeNodesInXRange(tree, XYRangeMax);
    XCTAssertEqual(nodeSet->count, 5);
    free(nodeSet);
}

- (void)testXYTreeNodesInXRange_Fine
{
    XYNode node1 = XYNodeMake(-5, -5, NULL);
    XYNode node2 = XYNodeMake(-4, -3, NULL);
    XYNode node3 = XYNodeMake(0, 0, NULL);
    XYNode node4 = XYNodeMake(3, 4, NULL);
    XYNode node5 = XYNodeMake(5, 5, NULL);
    
    XYNode *nodes[5] = { &node1, &node2, &node3, &node4, &node5 };
    
    XYTree *tree = XYTreeMake(nodes, 5);
    
    XYRange xRange = XYRangeMake(-4, 4, YES);
    XYNodeSet *nodeSet = XYTreeNodesInXRange(tree, xRange);
    
    XCTAssertEqual(nodeSet->count, 3);
    XCTAssert([[self class] nodeSet:nodeSet containsSubsetOfNodes:nodes withCount:5 inXRange:xRange andYRange:XYRangeMax]);
}

- (void)testXYTreeNodesInXRange_Coarse
{
    int nodeCount = 100000;
    double nodeMin = -100;
    double nodeMax = 100;
    
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    double *doubles = [[self class] randomDoublesWithCount:nodeCount * 2 min:nodeMin max:nodeMax];
    for(int i = 0; i < nodeCount; i++) {
        nodes[i] = XYNodePtrMake(doubles[i], doubles[nodeCount + i], NULL);
    }
    
    XYTree *tree = XYTreeMake(nodes, nodeCount);
    
    XYRange xRange = XYRangeMake(-50, 50, YES);
    
    __block XYNodeSet *nodeSet;
    [self measureBlock:^{
        nodeSet = XYTreeNodesInXRange(tree, xRange);
    }];
    
    XCTAssert([[self class] nodeSet:nodeSet containsSubsetOfNodes:nodes withCount:nodeCount inXRange:xRange andYRange:XYRangeMax]);
    
    free(doubles);
    for(int i = 0; i < nodeCount; i++) {
        free(nodes[i]);
    }
    free(nodes);
}


#pragma mark - XYNodeSet XYTreeNodesInYRange(XYTree tree, XYRange xRange);
#pragma mark -

- (void)testXYTreeNodesInYRange_Corner_Cases
{
    // No Tree
    XYNodeSet *nodeSet = XYTreeNodesInYRange(nil, XYRangeMax);
    XCTAssert(!nodeSet);
    
    // Empty Tree
    XYNode **nodes;
    XYTree *tree = XYTreeMake(nodes, 0);
    
    nodeSet = XYTreeNodesInYRange(tree, XYRangeMax);
    XCTAssertEqual(nodeSet->count, 0);
    free(nodeSet);
    
    // No matching nodes
    int nodeCount = 5;
    nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(-50, 50, nil);
    nodes[1] = XYNodePtrMake(-25, 25, nil);
    nodes[2] = XYNodePtrMake(0, 0, nil);
    nodes[3] = XYNodePtrMake(25, -25, nil);
    nodes[4] = XYNodePtrMake(50, -50, nil);
    
    tree = XYTreeMake(nodes, nodeCount);
    nodeSet = XYTreeNodesInYRange(tree, XYRangeMake(100, 200, YES));
    XCTAssertEqual(nodeSet->count, 0);
    free(nodeSet);
    
    // All Matching objects
    nodeSet = XYTreeNodesInYRange(tree, XYRangeMax);
    XCTAssertEqual(nodeSet->count, 5);
    free(nodeSet);
}

- (void)testXYTreeNodesInYRange_Fine
{
    XYNode node1 = XYNodeMake(-5, -5, NULL);
    XYNode node2 = XYNodeMake(-4, -3, NULL);
    XYNode node3 = XYNodeMake(0, 0, NULL);
    XYNode node4 = XYNodeMake(3, 4, NULL);
    XYNode node5 = XYNodeMake(5, 5, NULL);
    
    XYNode *nodes[5] = { &node1, &node2, &node3, &node4, &node5 };
    
    XYTree *tree = XYTreeMake(nodes, 5);
    
    XYRange yRange = XYRangeMake(-4, 4, NO);
    XYNodeSet *nodeSet = XYTreeNodesInYRange(tree, yRange);
    
    XCTAssertEqual(nodeSet->count, 2);
    XCTAssert([[self class] nodeSet:nodeSet containsSubsetOfNodes:nodes withCount:5 inXRange:XYRangeMax andYRange:yRange]);
}


- (void)testXYTreeNodesInYRange_Coarse
{
    int nodeCount = 100000;
    double nodeMin = -100;
    double nodeMax = 100;
    
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    double *doubles = [[self class] randomDoublesWithCount:nodeCount * 2 min:nodeMin max:nodeMax];
    for(int i = 0; i < nodeCount; i++) {
        nodes[i] = XYNodePtrMake(doubles[i], doubles[nodeCount + i], NULL);
    }
    
    XYTree *tree = XYTreeMake(nodes, nodeCount);
    
    XYRange yRange = XYRangeMake(0, 50, YES);
    __block XYNodeSet *nodeSet;
    [self measureBlock:^{
        nodeSet = XYTreeNodesInYRange(tree, yRange);
    }];
    
    XCTAssert([[self class] nodeSet:nodeSet containsSubsetOfNodes:nodes withCount:nodeCount inXRange:XYRangeMax andYRange:yRange]);
    
    free(doubles);
    for(int i = 0; i < nodeCount; i++) {
        free(nodes[i]);
    }
    free(nodes);
}

#pragma mark - XYNodeSet XYTreeNodesInXYRange(XYTree tree, XYRange xRange, XYRange yRange);
#pragma mark -

- (void)testXYTreeNodesInXYRange_Corner_Cases
{
    // No Tree
    XYNodeSet *nodeSet = XYTreeNodesInXYRange(nil, XYRangeMax, XYRangeMax);
    XCTAssert(!nodeSet);
    
    // Empty Tree
    XYNode **nodes;
    XYTree *tree = XYTreeMake(nodes, 0);
    
    nodeSet = XYTreeNodesInXYRange(tree, XYRangeMax, XYRangeMax);
    XCTAssertEqual(nodeSet->count, 0);
    free(nodeSet);
    
    // No matching nodes
    int nodeCount = 5;
    nodes = malloc(nodeCount * sizeof(XYNode *));
    nodes[0] = XYNodePtrMake(-50, 50, nil);
    nodes[1] = XYNodePtrMake(-25, 25, nil);
    nodes[2] = XYNodePtrMake(0, 0, nil);
    nodes[3] = XYNodePtrMake(25, -25, nil);
    nodes[4] = XYNodePtrMake(50, -50, nil);
    
    tree = XYTreeMake(nodes, nodeCount);
    nodeSet = XYTreeNodesInXYRange(tree, XYRangeMake(100, 200, YES), XYRangeMake(100, 200, YES));
    XCTAssertEqual(nodeSet->count, 0);
    free(nodeSet);
    
    // All Matching objects
    nodeSet = XYTreeNodesInXYRange(tree, XYRangeMax, XYRangeMax);
    XCTAssertEqual(nodeSet->count, 5);
    free(nodeSet);
}

- (void)testXYTreeNodesInXYRange_Fine
{
    XYNode node1 = XYNodeMake(-5, -5, NULL);
    XYNode node2 = XYNodeMake(-4, -3, NULL);
    XYNode node3 = XYNodeMake(0, 0, NULL);
    XYNode node4 = XYNodeMake(3, 4, NULL);
    XYNode node5 = XYNodeMake(5, 5, NULL);
    
    XYNode *nodes[5] = { &node1, &node2, &node3, &node4, &node5 };
    
    XYTree *tree = XYTreeMake(nodes, 5);

    XYRange xRange = XYRangeMake(-4, 4, YES);
    XYRange yRange = XYRangeMake(-4, 4, NO);
    XYNodeSet *nodeSet = XYTreeNodesInXYRange(tree, xRange, yRange);

    // Expected result is [(-4, -3), (0, 0)]
    XCTAssert([[self class] nodeSet:nodeSet containsSubsetOfNodes:nodes withCount:5 inXRange:xRange andYRange:yRange]);
}


- (void)testXYTreeNodesInXYRange_Coarse
{
    int nodeCount = 100000;
    double nodeMin = -100;
    double nodeMax = 100;
    
    XYNode **nodes = malloc(nodeCount * sizeof(XYNode *));
    double *doubles = [[self class] randomDoublesWithCount:nodeCount * 2 min:nodeMin max:nodeMax];
    for(int i = 0; i < nodeCount; i++) {
        nodes[i] = XYNodePtrMake(doubles[i], doubles[nodeCount + i], NULL);
    }
    
    XYTree *tree = XYTreeMake(nodes, nodeCount);
 
    XYRange xRange = XYRangeMake(-50, 50, YES);
    XYRange yRange = XYRangeMake(0, 50, YES);

    __block XYNodeSet *nodeSet;
    [self measureBlock:^{
        nodeSet = XYTreeNodesInXYRange(tree, xRange, yRange);
    }];

    XCTAssert([[self class] nodeSet:nodeSet containsSubsetOfNodes:nodes withCount:nodeCount inXRange:xRange andYRange:yRange]);
    
    free(doubles);
    for(int i = 0; i < nodeCount; i++) {
        free(nodes[i]);
    }
    free(nodes);
}

#pragma mark - Helpers
#pragma mark -

#define ARC4RANDOM_MAX      0x100000000

+ (double)randomDoubleBetweenMin:(double)min max:(double)max
{
    if(min > max) {
        double temp = min;
        min = max;
        max = temp;
    }
    
    double diff = max - min;
    
    double random = ((double) arc4random()) / (double) ARC4RANDOM_MAX;
    double randomInRange = min + (random * diff);
    
    return randomInRange;
}

+ (double *)randomDoublesWithCount:(NSUInteger)count min:(double)min max:(double)max
{
    if(min > max) {
        double temp = min;
        min = max;
        max = temp;
    }
    
    double diff = max - min;
    
    double *doubles = malloc(count * sizeof(double));
    for(int i = 0; i < count; i++) {
        double random = ((double) arc4random()) / (double) ARC4RANDOM_MAX;
        double randomInRange = min + (random * diff);
        doubles[i] = randomInRange;
    }
    
    return doubles;
}

+ (BOOL)treeIsValid2DTree:(XYTree *)tree
{
    XYRange maxRange = XYRangeMax;
    return [self treeWithRootIsValid:tree->root dimension:0 xMin:maxRange.min xMax:maxRange.max yMin:maxRange.min yMax:maxRange.max];
}

+ (BOOL)nodes:(XYNode **)nodes withCount:(int)nodeCount arePartitionedBy:(XYNode **)partition dimension:(NSUInteger)dimension
{
    BOOL didPartition = YES;
    
    for(XYNode **node = nodes; node < partition; node++) {
        if((*node)->coords[dimension] > (*partition)->coords[dimension]) {
            didPartition = NO;
            break;
        }
    }

    for(XYNode **node = partition; node < nodes + nodeCount; node++) {
        if((*node)->coords[dimension] < (*partition)->coords[dimension]) {
            didPartition = NO;
            break;
        }
    }

    return didPartition;
}

+ (BOOL)treeWithRootIsValid:(XYNode *)node dimension:(int)dimension xMin:(double)xMin xMax:(double)xMax yMin:(double)yMin yMax:(double)yMax
{
    if(node == NULL) return YES;

    // Check this node
    if(!XYNodeIsInXYRange(node, XYRangeMake(xMin, xMax, YES), XYRangeMake(yMin, yMax, YES))) {
        return NO;
    }
    
    int nextDim = (dimension + 1) % 2;
    if(node->left) {
        double leftXMax = dimension % 2 == 0 ? node->coords[0] : xMax;
        double leftYMax = dimension % 2 == 0 ? yMax : node->coords[1];
        BOOL leftIsValid = [self treeWithRootIsValid:node->left
                                           dimension:nextDim
                                                xMin:xMin
                                                xMax:leftXMax
                                                yMin:yMin
                                                yMax:leftYMax];
        
        if(!leftIsValid) return NO;
    }
    
    if(node->right) {
        double rightXMin = dimension % 2 == 0 ? node->coords[0] : xMin;
        double rightYMin = dimension % 2 == 0 ? yMin : node->coords[1];
        
        BOOL rightIsValid = [self treeWithRootIsValid:node->right
                                            dimension:nextDim
                                                 xMin:rightXMin
                                                 xMax:xMax
                                                 yMin:rightYMin
                                                 yMax:yMax];
        if(!rightIsValid) return NO;
    }
    
    return YES;
}

+ (BOOL)nodeSet:(XYNodeSet *)nodeSet containsSubsetOfNodes:(XYNode **)nodes withCount:(int)nodeCount inXRange:(XYRange)xRange andYRange:(XYRange)yRange
{
    if(nodeSet == NULL || nodes == NULL || nodeCount == 0) return NO;
    
    XYNodeSet *holderSet = XYNodeSetMake(NULL, NULL, 0);
    
    for(int i = 0; i < nodeCount; i++) {
        XYNode *node = nodes[i];
        if(XYNodeIsInXYRange(node, xRange, yRange)) {
            if(XYNodeSetContainsNode(nodeSet, node)) {
                XYNodeSetRemoveNode(nodeSet, node);
                XYNodeSetAddNode(holderSet, node);
            } else {
                return NO;
            }
        }
    }
    
    int extraResultsCount = nodeSet->count;
    
    for(int i = 0; i < holderSet->count; i++) {
        XYNodeSetAddNode(nodeSet, holderSet->first->node);
        XYNodeSetRemoveNode(holderSet, holderSet->first->node);
    }

    BOOL result = extraResultsCount == 0 ? YES : NO;
    return result;
}

@end
