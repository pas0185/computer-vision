
//
//  TVContentViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVContentViewController.h"

@interface TVContentViewController ()

@end

@implementation TVContentViewController

- (id)initWithImage:(UIImage *)image Index:(NSUInteger)index {
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        
        self.contentImageView = [[UIImageView alloc] initWithImage:image];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self setView:self.contentImageView];
        
        
        return self;
    }
    
    return nil;
}

- (void)loadImage:(UIImage *)image {
    
    [self.contentImageView setImage:image];
    
}
- (void)addOverlay:(UIView *)overlay {
    [self.contentImageView addSubview:overlay];
}

- (void)performBulletCalculationWithFirst:(UIImage *)image1 Second:(UIImage *)image2 {
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        NSLog(@"About to calculate diff image");
        self.circles = [NSMutableArray new];

//        cv::Mat diffMatrix = [TVUtility differenceMatrixFrom:image1 Minus:image2];
        cv::Mat diffMatrix = [TVUtility differenceMatrixFrom:image1 Minus:image2];

        
//        CGRect imageSize = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(diffMatrix.cols, diffMatrix.rows), self.contentImageView.frame);
//        NSLog(@"Image size = %@", NSStringFromCGRect(imageSize));

        
        float radius = 5;
        
        for (int i = 0; i < diffMatrix.rows; i++) {
            for (int j = 0; j < diffMatrix.cols; j++) {
                
                uint8_t byte = diffMatrix.at<uint8_t>(i, j);
                
                if (byte > 35) {
                    
                    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(i, j, 2 * radius, 2 * radius)];

                    circle.backgroundColor = [UIColor orangeColor];
                    circle.layer.cornerRadius = radius;
                    circle.layer.masksToBounds = YES;
                    
//                    [self.circles addObject:circle];
                    

                }
                
            }
        }
        
        
        //        NSArray *arrBullets = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diffMatrix];
        
        
        UIImage *diffImage = [TVUtility UIImageFromCVMat:diffMatrix];
        
        
        NSLog(@"Finished calculating diff image");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"About to load diff image to content view");
            [self loadImage:diffImage];
            NSLog(@"Finished loading diff image to content view");
            

//            [contentView addCircles:circles];
        });
    });
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    self.contentImageView = [[UIImageView alloc] initWithImage:nil];
//    self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self setView:self.contentImageView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    if (self.circles != nil) {

        UIView *overlay = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentImageView.frame.size.width, self.contentImageView.frame.size.height)];
        
        CGRect imageSize = AVMakeRectWithAspectRatioInsideRect(CGSizeMake(640, 480), self.view.frame);
        
        NSLog(@"Image size = %@", NSStringFromCGRect(imageSize));

        
        float xOffset = imageSize.origin.x;
        float yOffset = imageSize.origin.y;
        
        float width = imageSize.size.width;
        float height = imageSize.size.height;
        
        for (UIView *circle in self.circles) {

            float i = circle.frame.origin.x;
            float j = circle.frame.origin.y;
            
            float newX = ((i / 640.0) * width) + xOffset;
            float newY = ((j / 480.0) * height) + yOffset;

            CGRect newFrame = CGRectMake(newX, newY, circle.frame.size.width, circle.frame.size.height);
            
            circle.frame = newFrame;

            [overlay addSubview:circle];
            
        }

        [self.contentImageView addSubview:overlay];
        
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
