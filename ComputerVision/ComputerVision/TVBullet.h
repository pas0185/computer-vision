//
//  TVBullet.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/1/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Headers.h"

@interface TVBullet : NSObject

@property (strong, nonatomic) NSMutableArray *pixelArray;

<<<<<<< Updated upstream
// Validity score...

=======
- (BOOL)containsPoint:(CGPoint)point;
- (void)addToArray:(CGPoint)point;
>>>>>>> Stashed changes

@end
