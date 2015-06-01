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

#import "TVBullet.h"

using namespace cv;

@interface ViewController : UIViewController<CvVideoCameraDelegate>
{
    cv::Mat last; // Last matrix image captured
    
}

@property (nonatomic, retain) CvVideoCamera* videoCamera;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPrevious;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCurrent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDifference;

- (IBAction)snapPrevious:(id)sender;
- (IBAction)snapCurrent:(id)sender;

@end

