//
//  TVBullet.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/1/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVBullet.h"

@implementation TVBullet


- (id)init
{
    self = [super init];
    if (self) {
        self.pixelArray = [[NSMutableArray alloc] init];
    }
    return self;
}

//Adding Function
- (void)addToArray:(CGPoint)point{
    [self.pixelArray addObject:NSStringFromCGPoint(point)];
}

//Contains function
- (BOOL)containsPoint:(CGPoint)point{
    for (int i = 0; i < self.pixelArray.count; i++) {
        if (CGPointFromString([self.pixelArray objectAtIndex:i]).x == point.x && CGPointFromString([self.pixelArray objectAtIndex:i]).y == point.y) {
            return true;
        }
    }
    return false;
}

@end

