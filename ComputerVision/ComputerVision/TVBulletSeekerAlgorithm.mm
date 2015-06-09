//
//  TVBulletSeekerAlgorithm.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVBulletSeekerAlgorithm.h"

#define FOUND_INDICATOR 1



@implementation TVBulletSeekerAlgorithm

+ (void)otherFF:(cv::Mat &)modifiableMatrix {
 
    // I can change this matrix's values
    
    modifiableMatrix.at<double>(4,4) = FOUND_INDICATOR;
}

+ (void)floodFill:(CGPoint)position andBullet:(TVBullet *)newBullet andDiffMat:(cv::Mat)diff andDictVisited:(NSMutableArray *)visited {
    
    //TODO: Find a fix for the type map visited
//    visited->insert(std::pair<CGPoint, BOOL>(position, true));
    
    
    if(diff.at<float>(position.x, position.y) != 0){
        
        //If newBullet contains point then return
        if ([newBullet containsPoint:position]) {
            return;
        }
        
        //Else add the point to the bullet and call floodFill again on the left, right, top and bottom pixels
        else{
            CGPoint westPoint = CGPointMake(position.x - 1, position.y);
            CGPoint eastPoint = CGPointMake(position.x + 1, position.y);
            CGPoint northPoint = CGPointMake(position.x, position.y + 1);
            CGPoint southPoint = CGPointMake(position.x, position.y - 1);
            
            //Add the position of the pixel of a possible bullet
            [newBullet addToArray:position];
            
            //Recursively call FloodFill on all the surrounding areas of the intial point
            [TVBulletSeekerAlgorithm floodFill:westPoint andBullet:newBullet andDiffMat:diff andDictVisited:visited];
            [TVBulletSeekerAlgorithm floodFill:eastPoint andBullet:newBullet andDiffMat:diff andDictVisited:visited];
            [TVBulletSeekerAlgorithm floodFill:northPoint andBullet:newBullet andDiffMat:diff andDictVisited:visited];
            [TVBulletSeekerAlgorithm floodFill:southPoint andBullet:newBullet andDiffMat:diff andDictVisited:visited];
        }
    }
    
}



+ (NSMutableArray *)getTVBulletCandidatesFromDiffMatrix:(cv::Mat)diff {

    /* 
     Given a difference matrix between two frames, this function finds
     all 'blobs' using an adjacency algorithm and converts them to TVBullets
     and returns all of them in an NSArray
     */
    
    
    cv::Mat copyMatrix = diff.clone();
    
    
    
    NSMutableArray *arrBullets;
    NSMutableArray *visitedPix;
    
    for (int i = 0; i < diff.rows; i++) {
        for (int j = 0; j < diff.cols; j++) {
            
            CGPoint currPos = CGPointMake(i, j);
            [visitedPix addObject:[NSValue valueWithCGPoint:currPos]];

            
            //TODO:Fix the way the mapVisitedPoints adds the position
            
            for (int i = 0; i < visitedPix.count; i++) {
                if([visitedPix objectAtIndex:i] != [NSValue valueWithCGPoint:currPos] && diff.at<float>(currPos.x, currPos.y) != 0){
                    TVBullet *newBullet;
                    [TVBulletSeekerAlgorithm floodFill:currPos andBullet:newBullet andDiffMat:diff andDictVisited:visitedPix];
                    [arrBullets addObject:newBullet];
                    
                }
            }
        }
    }
    
    return arrBullets;
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
