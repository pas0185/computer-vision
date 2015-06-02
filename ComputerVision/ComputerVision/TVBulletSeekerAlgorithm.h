//
//  TVBulletSeekerAlgorithm.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVBulletSeekerAlgorithm : NSObject

// NOTE: '+' means static/class method (can be called without creating an instance of the class
// *delete this after you read it*

+ (NSArray *)getTVBulletCandidatesFromDiffMatrix:(cv::Mat)diff;


@end
