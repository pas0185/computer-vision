//
//  ViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 5/28/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "ViewController.h"
#import "cap_ios.h"

#define IMAGE_A @"target-0-shots.png"
#define IMAGE_B @"target-2-shots.png"


using namespace cv;

@interface ViewController ()
{
    Mat m1, m2;
    CvVideoCamera *videoCamera;
}

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[TVVideoProcessor sharedInstance] TVBulletsFromImage:[UIImage imageNamed:IMAGE_B]];
    

//    cv::Mat src_gray;
//    int thresh = 20;
//    int max_thresh = 255;
//    RNG rng(12345);
//    cv::Mat src = [self cvMatFromUIImage:gaussianImage];
//    
//    /// Convert image to gray and blur it
//    cvtColor( src, src_gray, CV_BGR2GRAY );
//    blur( src_gray, src_gray, cv::Size(3,3) );
//    
//    
//    Mat canny_output;
//    std::vector<std::vector<cv::Point> > contours;
//    std::vector<Vec4i> hierarchy;
//    
//    /// Detect edges using canny
//    cv::Canny( src_gray, canny_output, thresh, thresh*2, 3 );
//    /// Find contours
//    findContours( canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
//    
//    /// Draw contours
//    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
//    for( int i = 0; i< contours.size(); i++ )
//    {
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
//    }
//    
//    
//    UIImage *contourImages = [self UIImageFromCVMat:drawing];

    
    
    
    
    //Set up the Previous Camera settings
//    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.imageViewPrevious];
//    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
//    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset352x288;
//    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
//    
//    self.videoCamera.defaultFPS = 10;
//    self.videoCamera.grayscaleMode = NO;
//    
//    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:nil];
//    self.videoCamera.delegate = self;
//    
//    self.m1Running = TRUE;
//    self.m2Running = TRUE;
}

- (void)viewDidAppear:(BOOL)animated {
//    [self.videoCamera start];
    
//    [self testTargetDifference];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - User Controls

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

#pragma mark - Custom Helper Methods

- (void)testTargetDifference {
    
    UIImage *img1 = [UIImage imageNamed:@"target-0-shots"];
    UIImage *img2 = [UIImage imageNamed:@"target-1-shot"];
    
    cv::Mat mat1 = [TVUtility cvMatFromUIImage:img1];
    cv::Mat mat2 = [TVUtility cvMatFromUIImage:img2];
    
    [self assignCvMat:mat1 toImageView:self.imageViewPrevious];
    [self assignCvMat:mat2 toImageView:self.imageViewCurrent];
    
    [self registerImageChangeFrom:mat1 toCurrent:mat2];
}

- (void)registerImageChangeFrom:(Mat)previous toCurrent:(Mat)current {
    
    // TODO: return array of (potential) bullets
    
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

- (void)assignCvMat:(cv::Mat)mat toImageView:(UIImageView *)imgView {
    
    Mat foo = mat.clone();
    // Update 'Previous' view
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), ^{
        
        Point2f src_center(foo.cols/2.0F, foo.rows/2.0F);
        Mat rot_mat = getRotationMatrix2D(src_center, 90, 1.0);
        Mat dst;
        warpAffine(foo, dst, rot_mat, foo.size());
        
        UIImage *img = [TVUtility UIImageFromCVMat:dst];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [imgView setImage:img];
        });
        
    });
}

#pragma mark - CvVideoCameraDelegate Protocol

- (void)processImage:(cv::Mat &)image {
    
    if (self.m1Running) {
        m1 = image.clone();
        [self assignCvMat:m1 toImageView:self.imageViewPrevious];
    }
    if (self.m2Running) {
        m2 = image.clone();
        [self assignCvMat:m2 toImageView:self.imageViewCurrent];
    }
}

@end
