//
//  TVBulletSeekerAlgorithm.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVBulletSeekerAlgorithm : NSObject


+ (NSMutableArray *)getTVBulletCandidatesFromDiffMatrix:(cv::Mat)diff;

+ (void)floodFill:(CGPoint)position andBullet:(TVBullet *)newBullet andDiffMat:(cv::Mat)diff andDictVisited:(NSSet *)visited;

+ (NSArray *)filterTVBulletsByDensity:(NSArray *)tvBullets;


@end