//
//  TVUtility.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/9/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVUtility.h"

@implementation TVUtility

+ (UIImage *)differenceImageFrom:(UIImage *)img1 Minus:(UIImage *)img2 {
    
    cv::Mat diff = [TVUtility differenceMatrixFrom:img1 Minus:img2];
    
    // Extract points non-zero
    
    return [TVUtility UIImageFromCVMat:diff];
}


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

+ (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
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

+ (cv::Mat)binaryMatrix:(UIImage *)image {
    
    cv::Mat imageMat = [TVUtility cvMatFromUIImage:image];
    //    cv::Mat imageMat = cv::imread(argv[1], CV_LOAD_IMAGE_COLOR);
    
    if (imageMat.empty())
    {
        NSLog(@"ERROR: Could not read image");
        return imageMat;
    }
    
    //Grayscale matrix
    cv::Mat grayscaleMat (imageMat.size(), CV_8U);
    
    //Convert BGR to Gray
    cv::cvtColor( imageMat, grayscaleMat, CV_BGR2GRAY );
    
    //Binary image
    cv::Mat binaryMat(grayscaleMat.size(), grayscaleMat.type());
    
    //Apply thresholding
    cv::threshold(grayscaleMat, binaryMat, 100, 255, cv::THRESH_BINARY);
    
    
    return binaryMat;
    
}

+ (CGPoint)calibratedPointFrom:(CGPoint)point inRect:(CGSize)oldRect forNewRect:(CGRect)newFrame {
    
    CGFloat xNew = (point.x / oldRect.width) * newFrame.size.width;
    CGFloat yNew = (point.y / oldRect.height) * newFrame.size.height;
    
    return CGPointMake(xNew, yNew);
    
}

+ (CGSize)aspectScaledImageSizeForImageView:(UIImageView *)iv image:(UIImage *)im {
    
    float x,y;
    float a,b;
    x = iv.frame.size.width;
    y = iv.frame.size.height;
    a = im.size.width;
    b = im.size.height;
    
    if ( x == a && y == b ) {           // image fits exactly, no scaling required
        // return iv.frame.size;
    }
    else if ( x > a && y > b ) {         // image fits completely within the imageview frame
        if ( x-a > y-b ) {              // image height is limiting factor, scale by height
            a = y/b * a;
            b = y;
        } else {
            b = x/a * b;                // image width is limiting factor, scale by width
            a = x;
        }
    }
    else if ( x < a && y < b ) {        // image is wider and taller than image view
        if ( a - x > b - y ) {          // height is limiting factor, scale by height
            a = y/b * a;
            b = y;
        } else {                        // width is limiting factor, scale by width
            b = x/a * b;
            a = x;
        }
    }
    else if ( x < a && y > b ) {        // image is wider than view, scale by width
        b = x/a * b;
        a = x;
    }
    else if ( x > a && y < b ) {        // image is taller than view, scale by height
        a = y/b * a;
        b = y;
    }
    else if ( x == a ) {
        a = y/b * a;
        b = y;
    } else if ( y == b ) {
        b = x/a * b;
        a = x;
    }
    return CGSizeMake(a,b);
    
}



@end
