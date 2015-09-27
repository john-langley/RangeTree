//
//  XYTree.c
//  OCRangeTree
//
//  Created by John Langley on 12/27/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#include "XYTree.h"

#pragma mark - Private Signiatures & Types
#pragma mark -

XYNode * XYTreeRootFromNodes(XYNode **nodes, long count, int dimension);
XYNode ** XYTreeSelectMedianFromNodes(XYNode **list, long count, int dimension);
XYNode ** XYTreePartitionNodesAroundPivot(XYNode **left, XYNode **right, XYNode **pivot, int dimension);
XYNode XYLeafNodeForTreeWithRoot(XYNode *node);

void XYTreeAddNodesInRangeToSet(XYNode *node, XYNodeSet *set, XYRange xRange, XYRange yRange, int dimension);
void XYTreeSwapNodePointers(XYNode **node1, XYNode **node2);


#pragma mark - Public Implementations
#pragma mark -

#pragma mark Tree Methods
// Creates a tree from given array of two-dimensional points
XYTree * XYTreeMake(XYNode **nodes, int count)
{
    XYTree *tree = malloc(sizeof(XYTree));
    tree->root = NULL;
    tree->nodes = NULL;
    tree->nodeCount = 0;
    if(nodes == NULL) return tree;
    
    tree->root = XYTreeRootFromNodes(nodes, count, 0);
    tree->nodes = nodes;
    tree->nodeCount = count;

    return tree;
}

XYNodeSet * XYTreeNodesInXRange(XYTree *tree, XYRange xRange)
{
    return XYTreeNodesInXYRange(tree, xRange, XYRangeMax);
}

XYNodeSet * XYTreeNodesInYRange(XYTree *tree, XYRange yRange)
{
    return XYTreeNodesInXYRange(tree, XYRangeMax, yRange);
}

XYNodeSet * XYTreeNodesInXYRange(XYTree *tree, XYRange xRange, XYRange yRange)
{
    if(!tree) return NULL;
    
    XYNodeSet *set = XYNodeSetMake(NULL, NULL, 0);
    XYTreeAddNodesInRangeToSet(tree->root, set, xRange, yRange, 0);
    return set;
}

void XYTreeAddNodesInRangeToSet(XYNode *node, XYNodeSet *set, XYRange xRange, XYRange yRange, int dimension)
{
    if(!node || !set) return;
    
    if(XYNodeIsInXYRange(node, xRange, yRange)) {
        XYNodeSetAddNode(set, node);
    }
    
    XYRange range = dimension % 2 == 0 ? xRange : yRange;
    double coord = node->coords[dimension];
    if(node->left != NULL) {
        if((range.inclusive && range.min <= coord) || (!range.inclusive && range.min < coord)) {
            XYTreeAddNodesInRangeToSet(node->left, set, xRange, yRange, (dimension + 1) % 2);
        }
    }

    if(node ->right != NULL) {
        if((range.inclusive && range.max >= coord) || (!range.inclusive && range.max > coord)) {
            XYTreeAddNodesInRangeToSet(node->right, set, xRange, yRange, (dimension + 1) % 2);
        }
    }
}

#pragma mark Node Methods

#pragma mark - Private Implementations
#pragma mark -

#pragma mark Tree Methods

XYNode * XYTreeRootFromNodes(XYNode **nodes, long count, int dimension)
{
    if (!count || !nodes) return NULL;
    else if(count == 1) return nodes[0];
    
    XYNode **median = XYTreeSelectMedianFromNodes(nodes, count, dimension);
    if (median) {

        // Left children are anything to the left of or equal to the median
        XYNode **leftChildren = nodes < median ? nodes : NULL;
        long leftChildCount = leftChildren ? median - nodes : 0;

        // Right children are anything to the right of the median
        XYNode **rightChildren = median < nodes + count - 1 ? median + 1 : NULL;
        long rightChildCount = rightChildren ? (nodes + count) - rightChildren : 0;

        dimension = (dimension + 1) % 2;

        XYNode *medianNode = *median;
        medianNode->left = XYTreeRootFromNodes(leftChildren, leftChildCount, dimension);
        if(medianNode->left) medianNode->left->parent = medianNode;

        medianNode->right = XYTreeRootFromNodes(rightChildren, rightChildCount, dimension);
        if(medianNode->right) medianNode->right->parent = medianNode;
    }

    return *median;
}


//XYNode * XYTreeRootFromNodes(XYNode *nodes, long count, int dimension)
//{
//    if (!count || nodes == NULL) return NULL;
//    else if(count == 1) return nodes;
//    
//    XYNode *median = XYTreeSelectMedianFromNodes(nodes, count, dimension);
//    if (median != NULL) {
//        
//        // Move the median to the front of the array for removal
//        XYNodeSwapContents(median, nodes);
//
//        // The former median is the root of this subtree
//        XYNode *root = nodes;
//
//        // Left children are anything to the left of the median
//        XYNode *leftChildren = nodes + 1 <= median ? nodes + 1 : NULL;
//        long leftChildCount = leftChildren != NULL ? median - nodes + 1 : 0;
//        
//        // Right children are anything to the right of the median
//        XYNode *rightChildren = median < nodes + count - 1 ? median++ : NULL;
//        long rightChildCount = rightChildren != NULL ? (nodes + count) - (median + 1) : 0;
//        
//        dimension = (dimension + 1) % 2;
//        
//        root->left = XYTreeRootFromNodes(leftChildren, leftChildCount, dimension);
//        if(root->left != NULL) root->left->parent = root;
//        
//        root->right = XYTreeRootFromNodes(rightChildren, rightChildCount, dimension);
//        if(root->right != NULL) root->right->parent = root;
//    }
//    
//    return median;
//}


XYNode ** XYTreeSelectMedianFromNodes(XYNode **list, long count, int dimension)
{
    if(count == 0 || list == NULL) return NULL;
    else if(count == 1) return list;
    
    XYNode **median = list + (count - 1) / 2;
    XYNode **left = list;
    XYNode **right = list + (count - 1);
    
    while(1) {
        XYNode **pivot = left + (right - left) / 2;
        pivot = XYTreePartitionNodesAroundPivot(left, right, pivot, dimension);

        if(pivot == median) return median;
        else if(median < pivot) right = pivot - 1;
        else left = pivot + 1;
    }
}

XYNode ** XYTreePartitionNodesAroundPivot(XYNode **left, XYNode **right, XYNode **pivot, int dimension)
{
    if(left == NULL || right == NULL || pivot == NULL) return NULL;
    dimension = dimension % 2;
    
    double pivotValue = (*pivot)->coords[dimension];
    XYTreeSwapNodePointers(pivot, right);
    
    XYNode **store = left;
    for(XYNode **i = left; i < right; i++) {
        if((*i)->coords[dimension] < pivotValue) {
            if(i != store) XYTreeSwapNodePointers(i, store);
            ++store;
        }
    }
    
    XYTreeSwapNodePointers(right, store);
    return store;
}

void XYTreeSwapNodePointers(XYNode **node1, XYNode **node2)
{
    XYNode *temp = *node1;
    *node1 = *node2;
    *node2 = temp;
}


void XYTreeFree(XYTree *tree)
{
    for (int i = 0; i < tree->nodeCount; i++) {
        XYNode *node = tree->nodes[i];
        XYNodeFree(node);
    }
    
    tree->root = NULL;
    
    free(tree->nodes);
    free(tree);
}




