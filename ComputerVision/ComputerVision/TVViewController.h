//
//  TVViewController.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GPUImage.h"

typedef enum { PASSTHROUGH_VIDEO, SIMPLE_THRESHOLDING, POSITION_THRESHOLDING, OBJECT_TRACKING} ColorTrackingDisplayMode;

@interface TVViewController : UIViewController
{
    CALayer *trackingDot;
    
    GPUImageVideoCamera *videoCamera;
    GPUImagePicture *sourcePicture;
    GPUImageFilter *thresholdFilter, *positionFilter;
    GPUImageRawDataOutput *positionRawData, *videoRawData;
    GPUImageAverageColor *positionAverageColor;
    GPUImageView *filteredVideoView;
    
    ColorTrackingDisplayMode displayMode;
    
    BOOL shouldReplaceThresholdColor;
    CGPoint currentTouchPoint;
    GLfloat thresholdSensitivity;
    GPUVector3 thresholdColor;
}

// Image processing
- (CGPoint)centroidFromTexture:(GLubyte *)pixels ofSize:(CGSize)textureSize;


@end
