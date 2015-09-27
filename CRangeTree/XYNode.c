//
//  xynode.c
//  OCRangeTree
//
//  Created by John Langley on 12/28/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#include <stdio.h>
#include "XYNode.h"

#pragma mark Node Methods

bool XYNodeIsInXRange(XYNode *node, XYRange xRange)
{
    return XYNodeIsInXYRange(node, xRange, XYRangeMax);
}

bool XYNodeIsInYRange(XYNode *node, XYRange yRange)
{
    return XYNodeIsInXYRange(node, XYRangeMax, yRange);
}

bool XYNodeIsInXYRange(XYNode *node, XYRange xRange, XYRange yRange)
{
    if(node == NULL) return false;
    
    bool inXRange = false;
    bool inYRange = false;
    
    if(xRange.inclusive && node->coords[0] >= xRange.min && node->coords[0] <= xRange.max) inXRange = true;
    else if(!xRange.inclusive && node->coords[0] > xRange.min && node->coords[0] < xRange.max) inXRange = true;
    
    if(yRange.inclusive && node->coords[1] >= yRange.min && node->coords[1] <= yRange.max) inYRange = true;
    else if(!yRange.inclusive && node->coords[1] > yRange.min && node->coords[1] < yRange.max) inYRange = true;

    bool inRange = inXRange && inYRange;

    return inRange;
}