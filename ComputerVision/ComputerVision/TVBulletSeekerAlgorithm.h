//
//  TVBulletSeekerAlgorithm.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

// Value between [0-1], used in density filter
#define BULLET_DENSITY_THRESHOLD 0.75

@interface TVBulletSeekerAlgorithm : NSObject

// NOTE: '+' means static/class method (can be called without creating an instance of the class
// *delete this after you read it*

+ (NSArray *)getTVBulletCandidatesFromDiffMatrix:(cv::Mat)diff;

+ (NSArray *)filterTVBulletsByDensity:(NSArray *)tvBullets;


@end
