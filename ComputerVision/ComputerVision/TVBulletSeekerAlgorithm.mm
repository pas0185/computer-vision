//
//  TVBulletSeekerAlgorithm.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"
#import "TVUtility.h"
#import "TVBulletSeekerAlgorithm.h"

#define FOUND_INDICATOR 1



@implementation TVBulletSeekerAlgorithm

+ (void)otherFF:(cv::Mat &)modifiableMatrix {
 
    // I can change this matrix's values
    
    modifiableMatrix.at<double>(4,4) = FOUND_INDICATOR;
}

+ (void)floodFill:(CGPoint)position andBullet:(TVBullet *)newBullet andDiffMat:(cv::Mat)diff andDictVisited:(NSSet *)visited {
    
    /* Tried to do cgpoint as a string and throws memory failure unlike nsvalue TOMORROW: Fix the ability. The program finds the pixels that are full so youre good there. Need to figure out the storage details.*/
    

    if ([visited containsObject:[NSValue valueWithCGPoint:position]]) {
        return;
    }
    else{
        visited = [visited setByAddingObject:[NSValue valueWithCGPoint:position]];
    }
    
    //TODO: Check the out of bounds range of the MAT
    
    if([TVUtility isPointPopulated:position diffMatrix:diff]){
        
        //If newBullet contains point then return
        if ([newBullet containsPoint:position]) {
            return;
        }
        
        //Else add the point to the bullet and call floodFill again on the left, right, top and bottom pixels
        else{
            //Add the position of the pixel of a possible bullet
            [newBullet addToArray:position];
            
            //Building adjacent points
            CGPoint westPoint = CGPointMake(position.x - 1, position.y);
            CGPoint eastPoint = CGPointMake(position.x + 1, position.y);
            CGPoint northPoint = CGPointMake(position.x, position.y + 1);
            CGPoint southPoint = CGPointMake(position.x, position.y - 1);
            
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
    NSMutableArray *arrBullets = [[NSMutableArray alloc] init];
    NSSet *visitedPix = [[NSSet alloc] init];
    
    cv::Mat copyMatrix = diff.clone();
    
    for (int i = 0; i < diff.rows; i++) {
        for (int j = 0; j < diff.cols; j++) {
            
            CGPoint currPos = CGPointMake(i, j);
            
            
            
            visitedPix = [visitedPix setByAddingObject:[NSValue valueWithCGPoint:currPos]];
            
            
            //TODO: Create a helper function that iterates through the set and returns a bool
            if(![visitedPix containsObject:[NSValue valueWithCGPoint:currPos]]
               && [TVUtility isPointPopulated:currPos diffMatrix:diff]){
                //At an unvisited populated point
                TVBullet *newBullet = [TVBullet new];
                [TVBulletSeekerAlgorithm floodFill:currPos andBullet:newBullet andDiffMat:diff andDictVisited:visitedPix];
                [arrBullets addObject:newBullet];
                
                NSLog(@"Inside the if statement in the function.");
                break;
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
        CGFloat borderArea = (1 + xMax - xMin) * (1 + yMax - yMin);
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
