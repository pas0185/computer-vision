//
//  TVViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVViewController.h"
#import "cap_ios.h"

//#define IMAGE_TEMPLATE @"perfect-target-0-shots"
//#define IMAGE_WITH_SHOT @"perfect-target-2-shots"

#define IMAGE_TEMPLATE @"still-white-2-shots"
#define IMAGE_WITH_SHOT @"still-white-6-shots"

//#define IMAGE_TEMPLATE @"still-white-0-shots"
//#define IMAGE_WITH_SHOT @"still-white-7-shots"

#define TEST_MOVIE @"grass-target-white"

#define IMAGE_SKEWED @"perfect-target-3-shots-skewed"

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
}

- (void)viewDidAppear:(BOOL)animated {
    
//    [self performKeystoneCorrectionTest];
}

- (void)performKeystoneCorrectionTest {
    
    UIImage *image = [UIImage imageNamed:IMAGE_SKEWED];
    //    UIImage *image = [UIImage imageNamed:@"ten-clubs.jpg"];
    UIImage *testImage = [[TVVideoProcessor sharedInstance] perspectiveCorrectionWithImage:image];
    
    [self.imageView setImage:testImage];
}

- (void)processVideo:(NSURL *)movieURL {

    MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];

    [movie.moviePlayer setControlStyle:MPMovieControlStyleDefault];
    [movie.moviePlayer prepareToPlay];
    [movie.moviePlayer play];
    [self presentMoviePlayerViewControllerAnimated:movie];
}

- (void)performImageProcessorTest {
    
    // Process the image with two shots in it
    UIImage *imgWithShots = [UIImage imageNamed:IMAGE_WITH_SHOT];
    [self.imageView setImage:imgWithShots];
    
    TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];
    
    // Set the template image for the VideoProcessor
    UIImage *imgTemplate = [UIImage imageNamed:IMAGE_TEMPLATE];
    [vidProcessor setTemplateImage:imgTemplate];
    
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

        
//        [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionRepeat animations:^{
//            
//            // Flash between hidden and visible
//            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
//                bulletOverlay.alpha = 0;
//            }];
//            [UIView addKeyframeWithRelativeStartTime:0.75 relativeDuration:0.25 animations:^{
//                bulletOverlay.alpha = 1;
//            }];
//            
//        } completion:nil];
        
    }];
}

#pragma mark - User Controls

- (IBAction)sliderValueChanged:(UISlider *)sender {

    NSUInteger sliderTag = sender.tag;
    NSUInteger labelTag = sliderTag + 5;
    
    UILabel *label = (UILabel *)[self.view viewWithTag:labelTag];
    
    float value = sender.value;
    [label setText:[NSString stringWithFormat:@"%.2f", value]];
    
}

@end
