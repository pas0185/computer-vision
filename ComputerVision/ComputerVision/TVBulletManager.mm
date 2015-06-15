//
//  TVBulletManager.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVBulletManager.h"


#define IMAGE_A @"target-0-shots"
#define IMAGE_B @"target-2-shots"

@implementation TVBulletManager {

    NSString *someProperty;
    
    

}

// (1) Create template frame
- (void)addNewFrame:(GPUImagePicture *)frame {
    
}

// (2) Average template subtraction
- (GPUImagePicture *)subtractTemplateFromFrame:(GPUImagePicture *)frame {
    
    UIImage *image_a = [UIImage imageNamed:IMAGE_A];
    UIImage *image_b = [UIImage imageNamed:IMAGE_B];
    
    GPUImageSubtractBlendFilter *stillImageFilter = [[GPUImageSubtractBlendFilter alloc] init];
    
    
    [frame addTarget:stillImageFilter];
    [frame useNextFrameForImageCapture];
    [frame processImage];
    
    
    UIImage *currentFilteredVideoFrame = [frame imageFromCurrentFramebuffer];
    
    
    
    
    
    return nil;
    
}


// (3) Gaussian filtering
- (GPUImagePicture *)applyGaussianFilter:(GPUImagePicture *)frame {

    return nil;
}

// (4) Histogram Thresholding
- (GPUImagePicture *)applyHistogramThresholding:(GPUImagePicture *)frame {
    
    return nil;
}


+ (id)sharedManager {
    static TVBulletManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        someProperty = @"Default Property Value";
    }
    return self;
}


@end
