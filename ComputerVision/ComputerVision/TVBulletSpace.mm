//
//  TVBulletSpace.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/16/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVBulletSpace.h"

#define IGNORE_BULLETS_WITH_SAME_CENTER YES
#define THRESHOLD_FOR_IGNORING_NEARBY_BULLETS 0.01

using namespace cv;
using namespace std;

typedef std::vector<cv::Point> Contour;

@interface TVBulletSpace ()
{
    CGSize matSize;
    Mat cannyMatrix;
    NSMutableArray *arrBullets;
}
@end

@implementation TVBulletSpace

- (id)initWithCannyOutput:(Mat)mCanny {
    
    self = [super init];
    if (self) {
        
        cannyMatrix = mCanny.clone();
        matSize = CGSizeMake(cannyMatrix.cols, cannyMatrix.rows);
        return self;
    }
    
    return nil;
}
- (UIView *)getOverlayView {
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, matSize.width, matSize.height)];
    
    UIColor *overlayColor = [UIColor colorWithRed:.2 green:.2 blue:.2 alpha:.5];
    
    [view setBackgroundColor:overlayColor];
    
    NSArray *bullets = [self getBullets];
    
    for (TVBullet *bullet in bullets) {
        
        UIView *bulletHighlight = [[UIView alloc] initWithFrame:CGRectMake(bullet.center.x - 20, bullet.center.y - 20, 40, 40)];
        [bulletHighlight setBackgroundColor:TVOrangeColor];
        [view addSubview:bulletHighlight];
    }
    
    
    return view;
}

- (CGSize)size {
    return matSize;
}

- (NSArray *)getBullets {
    
    if (arrBullets == nil) {
    
        [self findBulletsFromCannyMatrix:cannyMatrix];
    }
    
    return arrBullets;
}


- (void)findBulletsFromCannyMatrix:(Mat)canny {
    
    // TODO: check Canny matrix coordinate orientation
    
    if (canny.empty()) {
        return;
    }
    
    arrBullets = [NSMutableArray new];
    
    std::vector<Contour> contours;
    std::vector<Vec4i> hierarchy;
    
    /// Find contours
    findContours( cannyMatrix, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    int cRows = canny.rows;
    int cCols = canny.cols;
    NSLog(@"Canny matrix - [%d rows x %d cols]", cRows, cCols);
    
    /// Get the moments
    vector<Moments> mu(contours.size() );
    for( int i = 0; i < contours.size(); i++ ){
        mu[i] = moments( contours[i], false );
    }
    
    ///  Get the mass centers:
    for( int i = 0; i < contours.size(); i++ ) {
        
        Point2f center = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 );
        
        TVBullet *bullet = [[TVBullet alloc] initWithCenterPoint:center];
        [self addBulletAndValidate:bullet];
    }
}

- (void)addBulletAndValidate:(TVBullet *)bullet {
    
    // Check that we don't already have the same (or super close) bullet
    
    if ([self containsBullet:bullet]) {
        NSLog(@"Ignoring bullet: %@\n", [bullet toString]);
    }
    
    else {
        NSLog(@"Adding bullet: %@\n", [bullet toString]);
        [arrBullets addObject:bullet];
    }
}

- (BOOL)containsBullet:(TVBullet *)newBullet {

    if ([arrBullets containsObject:newBullet]) {
        // If the array has the same object
        return true;
    }
    
    if (IGNORE_BULLETS_WITH_SAME_CENTER) {
        
        for (TVBullet *existingBullet in arrBullets) {
            
            double xDiff = abs(existingBullet.center.x - newBullet.center.x);
            double yDiff = abs(existingBullet.center.y - newBullet.center.y);
            
            if (xDiff < THRESHOLD_FOR_IGNORING_NEARBY_BULLETS
                && yDiff < THRESHOLD_FOR_IGNORING_NEARBY_BULLETS) {
                
                return true;
            }
        }
    }
    
    return false;
}

- (NSString *)toString {
    
    return [NSString stringWithFormat:@"Canny Matrix - [%d rows x %d cols]\n\t\t x in [0..%d]\n\t\t y in [0..%d]", cannyMatrix.rows, cannyMatrix.cols, cannyMatrix.cols, cannyMatrix.rows];
}

@end
