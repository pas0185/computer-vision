//
//  TVVideoProcessor.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVVideoProcessor.h"

/** Timing operations **/
// start = [NSDate date]
// interval = [[NSDate date] timeIntervalSinceDate:start]

using namespace cv;

@interface TVVideoProcessor()
{
    GPUImagePicture *imageTemplate;
}
@end

@implementation TVVideoProcessor

#pragma mark - 
#pragma mark - Singleton Configuration

+ (id)sharedInstance {
    static TVVideoProcessor *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init {
    if (self = [super init]) {

        // Initialize default properties here
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods

- (void)setTemplateImage:(UIImage *)image {
    
    imageTemplate = [[GPUImagePicture alloc] initWithImage:image];
}

- (void)findTVBulletsWithImage:(UIImage *)image
                    Completion:(void (^)(TVBulletSpace *))callback {
    
    // Get image subtraction
    UIImage *subtractedImage = [self performGPUImageProcessing:image];
    
    // Perform Canny edge detection
    Mat canny = [self getCannyMatrix:subtractedImage];
    
    UIImage *cannyImage = [TVUtility UIImageFromCVMat:canny];
    
    // Get a Bullet Space to represent the bullet candidates
    TVBulletSpace *bulletSpace = [[TVBulletSpace alloc] initWithCannyOutput:canny];
    
    callback(bulletSpace);
    
}

- (UIImage *)perspectiveCorrectionWithImage:(UIImage *)image {

    cv::Point2f center(0,0);

    cv::Mat src = [TVUtility cvMatFromUIImage:image];

    cv::Mat bw;
    cvtColor(src, bw, CV_BGR2GRAY);
    cv::blur(bw, bw, cv::Size(3, 3));
    cv::Canny(bw, bw, 100, 100, 3);
    
    std::vector<cv::Vec4i> lines;
    cv::HoughLinesP(bw, lines, 1, CV_PI/180, 70, 30, 10);
    
    
    UIImage *imageHoughLinesP = [TVUtility UIImageFromCVMat:bw];
    
    // Expand the lines
//    for (int i = 0; i < lines.size(); i++)
//    {
//        cv::Vec4i v = lines[i];
//        lines[i][0] = 0;
//        lines[i][1] = ((float)v[1] - v[3]) / (v[0] - v[2]) * -v[0] + v[1];
//        lines[i][2] = src.cols;
//        lines[i][3] = ((float)v[1] - v[3]) / (v[0] - v[2]) * (src.cols - v[2]) + v[3];
//    }
    
    std::vector<cv::Point2f> corners;
    for (int i = 0; i < lines.size(); i++)
    {
        for (int j = i+1; j < lines.size(); j++)
        {
//            cv::Point2f pt = computeIntersect(lines[i], lines[j]);
//            if (pt.x >= 0 && pt.y >= 0)
//                corners.push_back(pt);
        }
    }
    
    std::vector<cv::Point2f> approx;
    cv::approxPolyDP(cv::Mat(corners), approx, cv::arcLength(cv::Mat(corners), true) * 0.02, true);
    
    if (approx.size() != 4)
    {
        NSLog(@"The object is not quadrilateral!");
    }
    
    // Get mass center
    for (int i = 0; i < corners.size(); i++)
        center += corners[i];
    center *= (1. / corners.size());
    
//    sortCorners(corners, center);
    if (corners.size() == 0){
        NSLog(@"The corners were not sorted correctly!");
        return nil;
    }
    
    cv::Mat dst = src.clone();
    
    // Draw lines
    for (int i = 0; i < lines.size(); i++)
    {
        cv::Vec4i v = lines[i];
        cv::line(dst, cv::Point(v[0], v[1]), cv::Point(v[2], v[3]), CV_RGB(0,255,0));
    }
    
    
    // Draw corner points
    cv::circle(dst, corners[0], 3, CV_RGB(255,0,0), 2);
    cv::circle(dst, corners[1], 3, CV_RGB(0,255,0), 2);
    cv::circle(dst, corners[2], 3, CV_RGB(0,0,255), 2);
    cv::circle(dst, corners[3], 3, CV_RGB(255,255,255), 2);
    
    // Draw mass center
    cv::circle(dst, center, 3, CV_RGB(255,255,0), 2);
    
    UIImage *imageLines = [TVUtility UIImageFromCVMat:dst];

    
    cv::Mat quad = cv::Mat::zeros(dst.rows, dst.cols, CV_8UC3);
    
    std::vector<cv::Point2f> quad_pts;
    quad_pts.push_back(cv::Point2f(0, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
    quad_pts.push_back(cv::Point2f(0, quad.rows));
    
    cv::Mat transmtx = cv::getPerspectiveTransform(corners, quad_pts);
    cv::warpPerspective(src, quad, transmtx, quad.size());

    UIImage *imageQuad = [TVUtility UIImageFromCVMat:quad];

    return imageQuad;
}

#pragma mark - GPUImage Processing

- (UIImage *)performGPUImageProcessing:(UIImage *)image {
    
    if (imageTemplate == nil) {
        
        NSLog(@"ERROR: TVVideoProcessor could not get the template image");
        return image;
    }
    
    // Apply Difference Blend Filter to cancel out template image
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageDifferenceBlendFilter *diffFilter = [[GPUImageDifferenceBlendFilter alloc] init];
    
    // Add both pictures to the Difference Blend Filter
    [imageTemplate addTarget:diffFilter];
    [gpuImage addTarget:diffFilter];
    
    GPUImageGaussianBlurFilter *gaussFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [diffFilter addTarget:gaussFilter];

    [gaussFilter useNextFrameForImageCapture];
    [imageTemplate processImage];
    [gpuImage processImage];

    // Process the images
    [imageTemplate processImage];
    [gpuImage processImage];
    
    // TODO: remove the need for GPUImage Library
    
    return [gaussFilter imageFromCurrentFramebuffer];
}

#pragma mark - OpenCV Image Processing

- (cv::Mat)getCannyMatrix:(UIImage *)image {
    
    int thresh = 20;
    RNG rng(12345);
    cv::Mat src = [TVUtility cvMatFromUIImage:image];
    
    /// Convert image to grayscale
    cvtColor(src, src, CV_BGR2GRAY );
    
    /// Detect edges using canny
    cv::Canny(src, src, thresh, thresh * 2, 3);
    
    return src;
}

#pragma mark - Private Helpers

@end
