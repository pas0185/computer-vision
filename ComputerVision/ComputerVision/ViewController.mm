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
    
    //Set up the Previous Camera settings
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageViewPrevious];
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    self.videoCamera.defaultFPS = 10;
    self.videoCamera.grayscaleMode = NO;
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:nil];
    self.videoCamera.delegate = self;
    
    self.m1Running = TRUE;
    self.m2Running = TRUE;
}

- (void)viewDidAppear:(BOOL)animated {
//    [self.videoCamera start];
    
    [self testTargetDifference];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testTargetDifference {
    
    UIImage *img1 = [UIImage imageNamed:@"target-empty"];
    UIImage *img2 = [UIImage imageNamed:@"target-shot"];
    
    cv::Mat mat1 = [self cvMatFromUIImage:img1];
    cv::Mat mat2 = [self cvMatFromUIImage:img2];
    
    [self assignCvMat:mat1 toImageView:self.imageViewPrevious];
    [self assignCvMat:mat2 toImageView:self.imageViewCurrent];
    
    [self registerImageChangeFrom:mat1 toCurrent:mat2];
    
    
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
    

    subtract(previous, current, difference);
    [self assignCvMat:difference toImageView:self.imageViewDifference];
    
    // Calculate the non-zero pixels in the matrix
    
    TVBullet *bullet = [TVBullet new];

    for (int i = 0; i < difference.rows; i++) {
        
        for (int j = 0; j < difference.cols; j++) {
            
            if (difference.at<double>(i, j) != 0.0) {
                
                // Point class we want, but not an instancetype
                CGPoint point = CGPointMake(i, j);
                
                // Convert it to NSValue to it is an instancetype
                NSValue *pointValue = [NSValue valueWithCGPoint:point];
                
                // Add it to the bullet's pixel array
                [bullet.pixelArray addObject:pointValue];
                
            }
        }
    }
}

#pragma mark - CvVideoCameraDelegate Protocol

- (void)processImage:(cv::Mat &)image {

//    [self assignCvMat:image toImageView:self.imageViewCurrent];
    
    if(self.m1Running)
    {
        m1 = image.clone();
        [self assignCvMat:m1 toImageView:self.imageViewPrevious];
    }
    if(self.m2Running)
    {
        m2 = image.clone();
        [self assignCvMat:m2 toImageView:self.imageViewCurrent];
    }
    
//    if (last.size == image.size) {
//        
//        [self assignCvMat:last toImageView:self.imageViewPrevious];
//        
//        
//        // Update Difference view
//        [self registerImageChangeFrom:last toCurrent:image];
//        
//    }
//    
//    // Update last image
//    last = image.clone();
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

- (cv::Mat)cvMatFromUIImage:(UIImage *)image
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

- (IBAction)snapPrevious:(id)sender {
    NSLog(@"Stop the previous picture");
    self.m1Running = FALSE;
}

- (IBAction)snapCurrent:(id)sender {
    NSLog(@"Stop the current picture");
    self.m2Running = FALSE;
}

- (IBAction)calculateDiff:(id)sender {

    if (m1.size == m2.size) {
        
        // Update Difference view
        [self registerImageChangeFrom:m1 toCurrent:m2];
    }
}

- (IBAction)reset:(id)sender {
    self.m1Running = TRUE;
    self.m2Running = TRUE;
    [self.imageViewDifference setImage:nil];
}

@end
