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

@end
