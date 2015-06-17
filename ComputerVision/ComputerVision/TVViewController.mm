//
//  TVViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVViewController.h"
#import "cap_ios.h"

#define IMAGE_TARGET_EMPTY @"target-0-shots"
#define IMAGE_TARGET_ONE_SHOT @"target-1-shot"
#define IMAGE_TARGET_TWO_SHOTS @"target-2-shots"

@interface TVViewController ()

@end

@implementation TVViewController


#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization code
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Add tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [self.imageView addGestureRecognizer:tgr];
    
    
    // Process the image with two shots in it
    UIImage *imgWithShots = [UIImage imageNamed:IMAGE_TARGET_ONE_SHOT];
    [self.imageView setImage:imgWithShots];

}

- (void)viewDidAppear:(BOOL)animated {
    
    [self performVideoProcessorTest];
    
}
- (void)performVideoProcessorTest {
    
    TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];
    
    // Set the template image for the VideoProcessor
    UIImage *imgTemplate = [UIImage imageNamed:IMAGE_TARGET_EMPTY];
    [vidProcessor setTemplateImage:imgTemplate];
    
    
    // Process the image with two shots in it
    UIImage *imgWithShots = [UIImage imageNamed:IMAGE_TARGET_ONE_SHOT];

    
    [vidProcessor findTVBulletsWithImage:imgWithShots Completion:^(TVBulletSpace *bulletSpace) {
        
        UIView *bulletOverlay = [bulletSpace getOverlayView];
        [self.imageView addSubview:bulletOverlay];
        
        // Scale the bullet overlay to fit the image
        CGSize imageSize = [TVUtility aspectScaledImageSizeForImageView:self.imageView image:self.imageView.image];
        
        CGFloat xscale = imageSize.width / bulletOverlay.frame.size.width;
        CGFloat yscale = imageSize.height / bulletOverlay.frame.size.height;
        CGAffineTransform t = CGAffineTransformMakeScale(xscale, yscale);
        bulletOverlay.transform = t;

        bulletOverlay.center = CGPointMake(self.imageView.frame.size.width  / 2,
                                           self.imageView.frame.size.height / 2);

        
        [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
            
            // Flash between hidden and visible
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                bulletOverlay.alpha = 0;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                bulletOverlay.alpha = 1;
            }];
            
        } completion:nil];
        
    }];
}

#pragma mark - User Controls

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {

    
    CGPoint ptInView = [tapGestureRecognizer locationInView:self.view];
    CGPoint ptInImgView = [tapGestureRecognizer locationInView:self.imageView];
    
    NSLog(@"You tapped in main view: (%.02f, %.02f)", ptInView.x, ptInView.y);
    NSLog(@" ... ... ... image view: (%.02f, %.02f)\n", ptInImgView.x, ptInImgView.y);
    
}

@end
