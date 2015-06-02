//
//  TVBulletSeekerAlgorithm.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVBulletSeekerAlgorithm.h"

@implementation TVBulletSeekerAlgorithm

+ (NSArray *)getTVBulletCandidatesFromDiffMatrix:(cv::Mat)diff {

    /* 
     Given a difference matrix between two frames, this function finds
     all 'blobs' using an adjacency algorithm and converts them to TVBullets
     and returns all of them in an NSArray
     */
    
    return nil;
}

+ (NSArray *)filterTVBulletsByDensity:(NSArray *)tvBullets {
    /*
     Given an array of TVBullets, return only those which exceed the threshold density
     */
    
    // Extrema variables to track min/max of each bullet
    int xMin, xMax, yMin, yMax;
    
    NSMutableArray *arrDenseBullets = [NSMutableArray new];
    
    
    // Find the min/max X and Y value for the each bullet
    // Add the ones that are dense enough to the return array
    for (TVBullet *bullet in tvBullets) {
        
        // Set all extrema variables to opposite extreme
        xMin = INT_MAX, xMax = INT_MIN, yMin = INT_MAX, yMax = INT_MIN;
        
        for (NSValue *pixelValue in bullet.pixelArray) {
            
            CGPoint pt = [pixelValue CGPointValue];
            
            xMin = (pt.x < xMin) ? pt.x : xMin;
            xMax = (pt.x > xMax) ? pt.x : xMax;
            
            yMin = (pt.y < yMin) ? pt.y : yMin;
            yMax = (pt.y > yMax) ? pt.y : yMax;
            
        }
        
        // At this point we have the min/max X/Y of the bullet
        
        // Calculate the encapsulating border area and actual area (in pixels)
        CGFloat borderArea = (xMax - xMin) * (yMax - yMin);
        CGFloat actualArea = bullet.pixelArray.count;
        CGFloat density = actualArea / borderArea;
        
        
        if (density > BULLET_DENSITY_THRESHOLD) {
            
            NSLog(@"Success! Bullet has valid density. (D = %f)", density);
            [arrDenseBullets addObject:bullet];
        }
        else {
            NSLog(@"Failure! Bullet not dense enough. (D = %f)", density);
        }
    }
    
    return arrDenseBullets;
}

@end
