//
//  TVUtility.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/9/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//


#import "Headers.h"

@interface TVUtility : NSObject


+ (UIImage *)differenceImageFrom:(UIImage *)img1 Minus:(UIImage *)img2;

+ (cv::Mat)differenceMatrixFrom:(UIImage *)img1 Minus:(UIImage *)img2;

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image;

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

+ (BOOL)isPointPopulated:(CGPoint)position diffMatrix:(cv::Mat)diff;

+ (BOOL)isPointVisited:(CGPoint)currPos inSet:(NSSet *)visitedPix;

+ (cv::Mat)binaryMatrix:(UIImage*)image;

+ (CGSize)aspectScaledImageSizeForImageView:(UIImageView *)iv image:(UIImage *)im;

+ (CGPoint)calibratedPointFrom:(CGPoint)point inRect:(CGSize)oldRect forNewRect:(CGRect)newFrame;

@end
