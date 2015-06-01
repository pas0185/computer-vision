//
//  ViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 5/28/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageViewCurrent];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    self.videoCamera.defaultFPS = 10;
    self.videoCamera.grayscaleMode = NO;
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:nil];
    self.videoCamera.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.videoCamera start];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)assignCvMat:(cv::Mat)mat toImageView:(UIImageView *)imgView {
    
    Mat foo = mat.clone();
    // Update 'Previous' view
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        
        Point2f src_center(foo.cols/2.0F, foo.rows/2.0F);
        Mat rot_mat = getRotationMatrix2D(src_center, 90, 1.0);
        Mat dst;
        warpAffine(foo, dst, rot_mat, foo.size());
        
        UIImage *img = [self UIImageFromCVMat:dst];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [imgView setImage:img];
        });
        
    });
}

- (void)registerImageChangeFrom:(Mat)previous toCurrent:(Mat)current {
    
    // Calculate differential matrix
    Mat difference;
    
    subtract(current, last, difference);
    [self assignCvMat:difference toImageView:self.imageViewDifference];
    
    // Calculate the non-zero pixels in the matrix
    
 
    
    
}

#pragma mark - CvVideoCameraDelegate Protocol

- (void)processImage:(cv::Mat &)image {

    [self assignCvMat:image toImageView:self.imageViewCurrent];
    
    if (last.size == image.size) {
        
        [self assignCvMat:last toImageView:self.imageViewPrevious];
        
        
        // Update Difference view
        [self registerImageChangeFrom:last toCurrent:image];
        
    }
    
    // Update last image
    last = image.clone();
}

#pragma mark - OpenCV Tutorial code

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
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

@end
