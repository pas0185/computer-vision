//
//  TVBullet.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/1/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVBullet : NSObject

@property (nonatomic) int tagNumber;
@property (nonatomic) cv::Point2f center;
@property (nonatomic) NSDate *timestamp;

@property (nonatomic) std::vector<cv::Point> vecPoints;

// TODO: remove pixel array
@property (strong, nonatomic) NSMutableArray *pixelArray;


- (id)initWithCenterPoint:(cv::Point2f)center;

- (BOOL)containsPoint:(CGPoint)point;
- (void)addToArray:(CGPoint)point;

+ (NSArray *)arrayWithContourVector:(std::vector<std::vector<cv::Point> >)contours;

- (NSString *)toString;

- (CGPoint)getCGCenterPoint;

@end
