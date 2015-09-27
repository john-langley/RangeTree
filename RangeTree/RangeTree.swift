//
//  RangeTree.swift
//  OMRangeTree
//
//  Created by John Langley on 9/26/15.
//  Copyright © 2015 Omada Health. All rights reserved.
//

import Foundation
import XYTree

public protocol TwoDimensional: AnyObject {
    var x: CDouble { get }
    var y: CDouble { get }
}

public class RangeTree<T where T: TwoDimensional, T: Hashable> {
    
    private let tree: UnsafeMutablePointer<XYTree>
    private let objects: Set<T>
    
    public required init(objects: Set<T>) {
        self.objects = objects
        
        let nodePtrs = UnsafeMutablePointer<XYNode>.alloc(objects.count)
        let nodes = UnsafeMutablePointer<UnsafeMutablePointer<XYNode>>(nodePtrs)
        
        for (index, object) in objects.enumerate() {
            let objectPointer = UnsafeMutablePointer<T>.alloc(1)
            objectPointer.initialize(object)
            nodes[index] = XYNodePtrMake(object.x, object.y, objectPointer);
        }
        
        tree = XYTreeMake(nodes, CInt(objects.count))
    }
    
    deinit {
        XYTreeFree(tree)
    }
    
    public func objectsInXInterval(interval: ClosedInterval<CDouble>) -> Set<T> {
        let range = XYRangeMake(interval.start, interval.end, true)
        let linkedNodes = XYTreeNodesInXRange(self.tree, range)
        return self.objectsFromLinkedNodes(linkedNodes)
    }

    public func objectsInYInterval(interval: ClosedInterval<CDouble>) -> Set<T> {
        let range = XYRangeMake(interval.start, interval.end, true)
        let linkedNodes = XYTreeNodesInYRange(self.tree, range)
        return self.objectsFromLinkedNodes(linkedNodes)

    }
    
    public func objectsInXInterval(xInterval: ClosedInterval<CDouble>, yInterval: ClosedInterval<CDouble>) -> Set<T> {
        let xRange = XYRangeMake(xInterval.start, xInterval.end, true)
        let yRange = XYRangeMake(yInterval.start, yInterval.end, true)
        let linkedNodes = XYTreeNodesInXYRange(self.tree, xRange, yRange)
        return self.objectsFromLinkedNodes(linkedNodes)
    }
    
    private func objectsFromLinkedNodes(linkedNodes: UnsafeMutablePointer<XYNodeSet>) -> Set<T> {
        var objects = Set<T>()
        var linkedNode = linkedNodes.memory.first
        while(linkedNode != nil) {
            let objectPointer = UnsafeMutablePointer<T>(linkedNode.memory.node.memory.object)
            objects.insert(objectPointer.memory)
            linkedNode = linkedNode.memory.next
        }
        return objects
    }
}

//@interface OMRangeTree()
//
//@property (nonatomic) XYTree *tree;
//@property (nonatomic, strong) NSArray *objects;
//
//@end
//
//@implementation OMRangeTree
//
//+ (OMRangeTree *)rangeTreeWithObjects:(NSArray *)objects
//{
//    return [[OMRangeTree alloc] initWithObjects:objects];
//    }
//    
//    - (id)initWithObjects:(NSArray *)objects
//{
//    self = [super init];
//    if(self) {
//        XYNode **nodes = malloc(objects.count * sizeof(XYNode *));
//        
//        for(int i = 0; i < objects.count; i++) {
//            NSObject<OMRangeTreeObject> *object = objects[i];
//            XYNode *node = XYNodePtrMake(object.xCoordinate, object.yCoordinate, (__bridge void *)(object));
//            nodes[i] = node;
//        }
//        
//        _tree = XYTreeMake(nodes, (int)objects.count);
//    }
//    
//    return self;
//    }
//    
//    - (NSSet *)objectsInXRange:(XYRange)xRange
//{
//    return [self objectsInXRange:xRange yRange:XYRangeMax];
//    }
//    
//    - (NSSet *)objectsInYRange:(XYRange)yRange
//{
//    return [self objectsInXRange:XYRangeMax yRange:yRange];
//    }
//    
//    - (NSSet *)objectsInXRange:(XYRange)xRange yRange:(XYRange)yRange
//{
//    if(!self.tree) return [NSSet set];
//    
//    XYNodeSet *results = XYTreeNodesInXYRange(self.tree, xRange, yRange);
//    NSSet *objectsInRange = [[self class] objectsInNodeSet:results];
//    XYNodeSetFree(results);
//    
//    return objectsInRange;
//    }
//    
//    - (void)dealloc
//        {
//            XYTreeFree(self.tree);
//}
//
//
//#pragma mark - Helpers
//#pragma mark -
//
//+ (NSSet *)objectsInNodeSet:(XYNodeSet *)nodeSet
//{
//    NSMutableSet *set = [NSMutableSet set];
//    
//    XYLinkedNode *linkedNode = nodeSet->first;
//    while(linkedNode) {
//        [set addObject:(__bridge id)(linkedNode->node->object)];
//        linkedNode = linkedNode->next;
//    }
//    
//    return set;
//}