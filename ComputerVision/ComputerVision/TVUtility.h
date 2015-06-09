//
//  TVUtility.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/9/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//


#import "Headers.h"

@interface TVUtility : NSObject

+ (cv::Mat)differenceMatrixFrom:(UIImage *)img1 Minus:(UIImage *)img2;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

@end
