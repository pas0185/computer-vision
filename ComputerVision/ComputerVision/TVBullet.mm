//
//  TVBullet.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/1/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVBullet.h"

using namespace std;
using namespace cv;

@implementation TVBullet

- (id)init {
    self = [super init];
    if (self) {
        self.pixelArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCenterPoint:(Point2f)center {
    
    self = [super init];
    if (self) {
        self.ptCenter = center;
    }
    return self;
}

+ (NSArray *)arrayWithContourVector:(vector<vector<cv::Point> >)contours {
 
    NSMutableArray *arrBullets = [[NSMutableArray alloc] initWithCapacity:contours.size()];
    
    /// Get the moments
    vector<Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ ){
        mu[i] = moments( contours[i], false );
    }
    
    ///  Get the mass centers:
    vector<Point2f> mc( contours.size() );
    for( int i = 0; i < contours.size(); i++ ) {
        
        Point2f center = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 );
        mc[i] = center;
        
        TVBullet *bullet = [[TVBullet alloc] initWithCenterPoint:center];
        bullet.vecPoints = contours[i];
        [arrBullets addObject:bullet];
    }
    
    return arrBullets;
}

//Adding Function
- (void)addToArray:(CGPoint)point{
    [self.pixelArray addObject:[NSValue valueWithCGPoint:point]];
}

//Contains function
- (BOOL)containsPoint:(CGPoint)point{
    
    for (int i = 0; i < self.pixelArray.count; i++) {
        
        CGPoint iPoint = [[self.pixelArray objectAtIndex:i] CGPointValue];
        if (CGPointEqualToPoint(point, iPoint)) {
            return true;
        }
        
//        if (CGPointFromString([self.pixelArray objectAtIndex:i]).x == point.x && CGPointFromString([self.pixelArray objectAtIndex:i]).y == point.y) {
//            return true;
//        }
    }
    return false;
}

@end

