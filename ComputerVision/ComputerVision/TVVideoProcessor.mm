//
//  TVVideoProcessor.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVVideoProcessor.h"

using namespace cv;

@interface TVVideoProcessor()
{
    GPUImagePicture *myImageTemplate;
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
    
    myImageTemplate = [[GPUImagePicture alloc] initWithImage:image];
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

#pragma mark - GPUImage Processing

- (UIImage *)performGPUImageProcessing:(UIImage *)image {
    
    GPUImagePicture *templateImage = [self averageTemplate];
    
    if (templateImage == nil) {
        NSLog(@"ERROR: Could not get the average template GPUImagePicture");
        
        return image;
    }
    
    // Apply Difference Blend Filter to cancel out template image
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageDifferenceBlendFilter *diffFilter = [[GPUImageDifferenceBlendFilter alloc] init];
    
    // Add both pictures to the Difference Blend Filter
    [templateImage addTarget:diffFilter];
    [gpuImage addTarget:diffFilter];
    
    
    
    GPUImageGaussianBlurFilter *gaussFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [diffFilter addTarget:gaussFilter];

    [gaussFilter useNextFrameForImageCapture];
    [templateImage processImage];
    [gpuImage processImage];
    
    
    
    
    
    // Capture the next frame
//    [diffFilter useNextFrameForImageCapture];
    
    // Process the images
    [templateImage processImage];
    [gpuImage processImage];
    
    
//    return [diffFilter imageFromCurrentFramebuffer];
    return [gaussFilter imageFromCurrentFramebuffer];
}

#pragma mark - OpenCV Image Processing

- (cv::Mat)getCannyMatrix:(UIImage *)image {
    
    cv::Mat srcGray;
    int thresh = 20;
    RNG rng(12345);
    cv::Mat src = [TVUtility cvMatFromUIImage:image];
    
    /// Convert image to gray and blur it
    cvtColor(src, srcGray, CV_BGR2GRAY );
    blur(srcGray, srcGray, cv::Size(3, 3));
    
    /// Detect edges using canny
    Mat cannyOutput;
    cv::Canny(srcGray, cannyOutput, thresh, thresh * 2, 3);
    
    return cannyOutput;
}

#pragma mark -
#pragma mark - Lazy Loaded Properties

- (GPUImagePicture *)averageTemplate {
    
    if (myImageTemplate == nil) {
        
        // Initialize it
        UIImage *templateImage = [UIImage imageNamed:@"target-0-shots"];
        myImageTemplate = [[GPUImagePicture alloc] initWithImage:templateImage];
    }
    
    return myImageTemplate;
}

@end
