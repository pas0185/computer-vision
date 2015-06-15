//
//  TVVideoProcessor.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVVideoProcessor.h"

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
//        someProperty = @"Default Property Value";
        
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods

- (void)setTemplateImage:(UIImage *)image {
    
}


- (NSArray *)TVBulletsFromImage:(UIImage *)image {
    
    /** GPUImage processing **/
    
    // (1) Subtract the template image
    UIImage *subtractedImage = [self performGPUImageProcessing:image];
    
    /*************************/

    
    
    /** ¿ Which Library ? **/
    
    // (2) Apply Gaussian Filter
    
    // (3) Convert to grayscale
    
    /***********************/

    
    
    
    /** OpenCV Processing **/
    
    // (4) Canny contour detection
    
    /***********************/
    
    
    
    /** TVBullet Processing **/
    
    // (5) Convert contours to bullet array
    
    /*************************/
    
    return nil;
}

#pragma mark -
#pragma mark - Private Helpers

- (GPUImagePicture *)averageTemplate {
    
    if (myImageTemplate == nil) {
        
        // Initialize it
        UIImage *templateImage = [UIImage imageNamed:@"target-0-shots"];
        myImageTemplate = [[GPUImagePicture alloc] initWithImage:templateImage];
    }
    
    return myImageTemplate;
}

- (UIImage *)performGPUImageProcessing:(UIImage *)image {
    
    if ([self averageTemplate] == nil) {
        NSLog(@"ERROR: Could not get the average template GPUImagePicture");

        return image;
    }
        
        
    /**************************************/
    /************* SUBTRACTOR *************/
    /**************************************/
    GPUImagePicture *templateImage = [self averageTemplate];
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    
    GPUImageDifferenceBlendFilter *diffFilter = [[GPUImageDifferenceBlendFilter alloc] init];
    
    // Add both pictures to the Difference Blend Filter
    
    [templateImage addTarget:diffFilter];
    [gpuImage addTarget:diffFilter];
    /**************************************/
    /**************************************/
    
    
    
    /**************************************/
    /********** GAUSSIAN FILTER ***********/
    /**************************************/
    GPUImageGaussianBlurFilter *gaussFilter = [[GPUImageGaussianBlurFilter alloc] init];
    
    [diffFilter addTarget:gaussFilter];
    
    [gaussFilter useNextFrameForImageCapture];
    /**************************************/
    /**************************************/
    
    
    
    /**************************************/
    /******* HISTOGRAM THRESHOLDING *******/
    /**************************************/
    
    
    
    /**************************************/
    /**************************************/
    
    [templateImage processImage];
    [gpuImage processImage];
    
    
    return [gaussFilter imageFromCurrentFramebuffer];
    
    
}

@end
