//
//  XYNode.h
//  OCRangeTree
//
//  Created by John Langley on 12/28/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#ifndef __OCRangeTree__XYNode__
#define __OCRangeTree__XYNode__

#include <stdlib.h>
#include "XYRange.h"

#pragma mark - XYNode
#pragma mark -

typedef struct XYNode {
    double coords[2];
    void const *object;
    struct XYNode *parent;
    struct XYNode *left;
    struct XYNode *right;
} XYNode;
typedef XYNode *XYNodePointer;

static inline XYNode XYNodeMake(double x, double y, void const *object)
{
    XYNode node;
    node.coords[0] = x;
    node.coords[1] = y;
    node.object = object;
    node.parent = NULL;
    node.left = NULL;
    node.right = NULL;
    return node;
}

static inline XYNode * XYNodePtrMake(double x, double y, void const *object)
{
    XYNode *node = malloc(sizeof(XYNode));
    node->coords[0] = x;
    node->coords[1] = y;
    node->object = object;
    node->parent = NULL;
    node->left = NULL;
    node->right = NULL;
    return node;
}

static inline void XYNodeSwapContents(XYNode *x, XYNode *y)
{
    if(x == y || x == NULL || y == NULL) return;
    
    XYNode temp = XYNodeMake(x->coords[0], x->coords[1], x->object);
    
    x->coords[0] = y->coords[0];
    x->coords[1] = y->coords[1];
    x->object = y->object;
    
    y->coords[0] = temp.coords[0];
    y->coords[1] = temp.coords[1];
    y->object = temp.object;
}

static inline void XYNodeFree(XYNode *node)
{
    node->parent = NULL;
    node->left = NULL;
    node->right = NULL;
    node->object = NULL;
    free(node);
}

bool XYNodeIsInXRange(XYNode *node, XYRange xRange);
bool XYNodeIsInYRange(XYNode *node, XYRange yRange);
bool XYNodeIsInXYRange(XYNode *node, XYRange xRange, XYRange yRange);

#pragma mark - XYLinkedNode
#pragma mark -

typedef struct XYLinkedNode {
    XYNode *node;
    struct XYLinkedNode *previous;
    struct XYLinkedNode *next;
} XYLinkedNode;
typedef XYLinkedNode *XYLinkedNodePointer;

static inline XYLinkedNode * XYLinkedNodeMake(XYNode *node, XYLinkedNode *previous, XYLinkedNode *next)
{
    XYLinkedNode *linkedNode = malloc(sizeof(XYLinkedNode));
    linkedNode->node = NULL;
    linkedNode->previous = NULL;
    linkedNode->next = NULL;
    
    linkedNode->node = node;
    
    if(previous) {
        linkedNode->previous = previous;
        previous->next = linkedNode;
    }
    
    if(next) {
        linkedNode->next = next;
        next->previous = linkedNode;
    }
    
    return linkedNode;
}

static inline void XYLinkedNodeFree(XYLinkedNode *linkedNode)
{
    linkedNode->next = NULL;
    linkedNode->previous = NULL;
    free(linkedNode);
}

#pragma mark - XYNodeSet
#pragma mark -

typedef struct XYNodeSet {
    XYLinkedNode *first;
    XYLinkedNode *last;
    int count;
} XYNodeSet;

static inline XYNodeSet * XYNodeSetMake(XYLinkedNode *first, XYLinkedNode *last, int count)
{
    XYNodeSet *set = malloc(sizeof(XYNodeSet));
   
    if(!last && !first) {
        count = 0;
    } else if(first == last || (!first || !last)) {
        first = first ? first : last;
        last = first;
        count = 1;
    }
    
    set->count = count;
    set->first = first;
    set->last = last;
    
    return set;
}

static inline void XYNodeSetAddNode(XYNodeSet *set, XYNode *node)
{
    if(!node || !set) return;
    
    if(!set->first) {
        XYLinkedNode *linkedNode = XYLinkedNodeMake(node, NULL, NULL);
        set->first = linkedNode;
        set->last = linkedNode;
    } else if(set->first == set->last) {
        XYLinkedNode *linkedNode = XYLinkedNodeMake(node, set->first, NULL);
        set->last = linkedNode;
    } else {
        XYLinkedNode *linkedNode = XYLinkedNodeMake(node, set->last, NULL);
        set->last = linkedNode;
    }
    
    set->count++;
}

static inline bool XYNodeSetContainsNode(XYNodeSet *set, XYNode *node)
{
    if(!set || !node) return false;
    
    XYLinkedNode *linkedNode = set->first;
    while (linkedNode) {
        if(linkedNode->node == node) {
            break;
        }
        
        linkedNode = linkedNode->next;
    }
    
    if(!linkedNode) return false;
    else return true;
}

// This method is not fast, runs in linear time.
static inline void XYNodeSetRemoveNode(XYNodeSet *set, XYNode *node)
{
    if(!node || !set || !set->first) return;

    XYLinkedNode *nodeToRemove = set->first;
    while (nodeToRemove && nodeToRemove->node != node) {
        nodeToRemove = nodeToRemove->next;
    }
    
    if(!nodeToRemove) return;
    
    if(nodeToRemove->next) nodeToRemove->next->previous = nodeToRemove->previous;
    if(nodeToRemove->previous) nodeToRemove->previous->next = nodeToRemove->next;

    if(nodeToRemove == set->first) set->first = nodeToRemove->next;
    if(nodeToRemove == set->last) set->last = nodeToRemove->previous;

    if(nodeToRemove) set->count--;
    free(nodeToRemove);
}

static inline void XYNodeSetFree(XYNodeSet *set)
{
    XYLinkedNode *linkedNode = set->first;
    while (linkedNode) {
        XYLinkedNode *nodeToFree = linkedNode;
        linkedNode = linkedNode->next;
        XYLinkedNodeFree(nodeToFree);
    }
    
    set->first = NULL;
    set->last = NULL;
    free(set);
}


#endif /* defined(__OCRangeTree__XYNode__) */
