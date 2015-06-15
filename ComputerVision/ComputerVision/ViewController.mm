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
#define IMAGE_B @"target-1-shot.png"


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
    
    UIImage *image = [UIImage imageNamed:IMAGE_B];
    
    [self.fullImageView setImage:image];
    
    TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];
    [vidProcessor findTVBulletsWithImage:image Completion:^(NSArray *arrBullets) {
        
        for (TVBullet *bullet in arrBullets) {
            
            CGFloat imgViewWidth = self.fullImageView.frame.size.width;
            CGFloat imgViewHeight = self.fullImageView.frame.size.height;
            
            CGFloat xNormImgView = bullet.ptCenter.x * imgViewWidth;
            CGFloat yNormImgView = bullet.ptCenter.y * imgViewHeight;
            
            
//            UIView *bulletHighlight = [[UIView alloc] initWithFrame:CGRectMake(xNormFullView, yNormFullView, 15, 15)];
//            [bulletHighlight setBackgroundColor:[UIColor greenColor]];
//            [self.view addSubview:bulletHighlight];
            
            
            
            CGFloat fullViewWidth = self.view.frame.size.width;
            CGFloat fullViewHeight = self.view.frame.size.height;
            
            CGFloat xNormFullView = bullet.ptCenter.x * fullViewWidth;
            CGFloat yNormFullView = bullet.ptCenter.y * fullViewHeight + 20.0f;

            UIView *bulletHighlight2 = [[UIView alloc] initWithFrame:CGRectMake(xNormFullView - 5, yNormFullView + 5, 10, 10)];
            [bulletHighlight2 setBackgroundColor:[UIColor blueColor]];
            [self.fullImageView addSubview:bulletHighlight2];
            
            
            
            
//            UIView *bulletHighlight3 = [[UIView alloc] initWithFrame:CGRectMake(xNormImgView, yNormImgView, 15, 15)];
//            [bulletHighlight3 setBackgroundColor:[UIColor orangeColor]];
//            [self.view addSubview:bulletHighlight3];
//            
//            
//            UIView *bulletHighlight4 = [[UIView alloc] initWithFrame:CGRectMake(xNormImgView, yNormImgView, 15, 15)];
//            [bulletHighlight4 setBackgroundColor:[UIColor purpleColor]];
//            [self.fullImageView addSubview:bulletHighlight4];
            
            
//            CGPoint cgCenter = CGPointMake(bullet.ptCenter.x, bullet.ptCenter.y);
//            
//            CGPoint cgRelCenter = [self.fullImageView convertPoint:cgCenter toView:self.view];
//            
//            CGFloat x = (cgCenter.x / 600.0f) * self.fullImageView.frame.size.width;
//            CGFloat y = (cgCenter.y / 436.0f) * self.fullImageView.frame.size.height;
//            
//            
//            CGPoint cgNormalized = CGPointMake(x, y);
//            
//            NSLog(@"Original: (%.02f, %.02f)", cgCenter.x, cgCenter.y);
//            NSLog(@"Relative: (%.02f, %.02f)", cgRelCenter.x, cgRelCenter.y);
//            NSLog(@"Normalized: (%.02f, %.02f)\n\n", x, y);
//            
//            
//            UIView *bulletHighlight = [[UIView alloc] initWithFrame:CGRectMake(cgCenter.x, cgCenter.y, 15, 15)];
//            [bulletHighlight setBackgroundColor:[UIColor greenColor]];
//            [self.fullImageView addSubview:bulletHighlight];
        }
        
    }];
    
    
    
    
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [self.fullImageView addGestureRecognizer:tgr];
    
    
    
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
    
    CGSize imgViewSize = self.fullImageView.frame.size;

}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
    
}

#pragma mark - User Controls

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    
    CGPoint ptInView = [tapGestureRecognizer locationInView:self.view];
    CGPoint ptInImgView = [tapGestureRecognizer locationInView:self.fullImageView];
    
    NSLog(@"You tapped in main view: (%.02f, %.02f)", ptInView.x, ptInView.y);
    NSLog(@" ... ... ... image view: (%.02f, %.02f)\n", ptInImgView.x, ptInImgView.y);

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
