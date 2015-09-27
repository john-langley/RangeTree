//
//  XYRange.h
//  OCRangeTree
//
//  Created by John Langley on 12/28/14.
//  Copyright (c) 2014 Omada Health. All rights reserved.
//

#ifndef OCRangeTree_XYRange_h
#define OCRangeTree_XYRange_h

#include <stdbool.h>
#include "float.h"

typedef struct _XYRange {
    double min;
    double max;
    bool inclusive;
} XYRange;
typedef XYRange *XYRangePointer;

static inline XYRange XYRangeMake(double min, double max, bool inclusive)
{
    XYRange r;
    r.min = min;
    r.max = max;
    r.inclusive = inclusive;
    return r;
}

extern const XYRange XYRangeMax;

#endif
