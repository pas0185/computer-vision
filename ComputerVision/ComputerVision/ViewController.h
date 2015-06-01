//
//  ViewController.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 5/28/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

#import <opencv2/videoio/cap_ios.h>
#define kImageCapturedSuccessfully @"imageCapturedSuccessfully"

#import "TVBullet.h"

using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
    cv::Mat last; // Last matrix image captured
    cv::Mat m1; // m1 matrix image captured
    cv::Mat m2; // m2 matrix image captured
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;
@property (retain) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, retain) UIImage *stillImage;


@property (weak, nonatomic) IBOutlet UIImageView *imageViewPrevious;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCurrent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDifference;

@property (nonatomic) BOOL m1Running;
@property (nonatomic) BOOL m2Running;


- (void)addStillImageOutput;
- (void)captureStillImage;

- (IBAction)snapPrevious:(id)sender;
- (IBAction)snapCurrent:(id)sender;
- (IBAction)calculateDiff:(id)sender;
- (IBAction)reset:(id)sender;

@end

