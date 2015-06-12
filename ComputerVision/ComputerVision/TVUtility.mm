//
//  TVUtility.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/9/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVUtility.h"

@implementation TVUtility

/* Computes the difference matrix that represents the marginal from img1 to img2
    i.e. result = img1 - img2
 */
+ (cv::Mat)differenceMatrixFrom:(UIImage *)img1 Minus:(UIImage *)img2 {
    
    cv::Mat diff;
    cv::Mat mat1 = [TVUtility cvMatFromUIImage:img1];
    cv::Mat mat2 = [TVUtility cvMatFromUIImage:img2];
    
    subtract(mat1, mat2, diff);
    
    return diff;
    
}

+ (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

+ (BOOL)isPointPopulated:(CGPoint)position diffMatrix:(cv::Mat)diff
{
    if (diff.rows <= position.x
        || diff.rows < 0
        || diff.cols <= position.y
        || diff.cols < 0)
    {
        return false;
    }
    
    else if(diff.at<float>(position.x, position.y) != 0){ // TODO: something besides 0
        // Index in range, check if populated
        return true;
    }
    
    return false;
    
}

+ (BOOL)isPointVisited:(CGPoint)currPos inSet:(NSSet *)visitedPix {

    for (NSValue *val in visitedPix) {
        if ([val respondsToSelector:@selector(CGPointValue)]) {
            CGPoint point = [val CGPointValue];
            if (CGPointEqualToPoint(currPos, point)) {
                return true;
            }
        }
    }
    
    return false;
}


@end
