//
//  XYTree.h
//  OCRangeTree
//
//  Created by John Langley on 12/27/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#ifndef __OCRangeTree__XYTree__
#define __OCRangeTree__XYTree__

#include <stdlib.h>
#include "XYNode.h"
#include "XYRange.h"

typedef struct XYTree {
    XYNode *root;
    XYNode **nodes;
    int nodeCount;
} XYTree;

XYTree * XYTreeMake(XYNode **nodes, int count);

// Returns nodes within provided x and y ranges
XYNodeSet * XYTreeNodesInXRange(XYTree *tree, XYRange xRange);
XYNodeSet * XYTreeNodesInYRange(XYTree *tree, XYRange yRange);
XYNodeSet * XYTreeNodesInXYRange(XYTree *tree, XYRange xRange, XYRange yRange);

void XYTreeFree(XYTree * tree);

#endif /* defined(__OCRangeTree__XYTree__) */
