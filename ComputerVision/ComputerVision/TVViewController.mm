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
    
    [self performKeystoneCorrectionTest];
}

- (void)performKeystoneCorrectionTest {
    
    UIImage *image = [UIImage imageNamed:IMAGE_SKEWED];
    
//    UIImage *image = [UIImage imageNamed:@"ten-clubs.jpg"];
    [self.imageViewBefore setImage:image];
    
    NSDictionary *options = [self getOptionsDictionaryFromSliders];
    [TVPerspectiveCorrector startWarpCorrection:image
                                    WithOptions:options
     Completion:^(UIImage *modImage) {
         [self.imageViewAfter setImage:modImage];
     }];
    
//    UIImage *testImage = [[TVVideoProcessor sharedInstance] perspectiveCorrectionWithImage:image];
    
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
    [self.imageViewBefore setImage:imgWithShots];
    [self.imageViewAfter setImage:imgWithShots];
    
    TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];
    
    // Set the template image for the VideoProcessor
    UIImage *imgTemplate = [UIImage imageNamed:IMAGE_TEMPLATE];
    [vidProcessor setTemplateImage:imgTemplate];
    
    [vidProcessor findTVBulletsWithImage:imgWithShots Completion:^(TVBulletSpace *bulletSpace) {
        
        UIView *bulletOverlay = [bulletSpace getOverlayView];
        [self.imageViewAfter addSubview:bulletOverlay];
        
        // Scale the bullet overlay to fit the image
        CGSize imageSize = [TVUtility aspectScaledImageSizeForImageView:self.imageViewAfter image:self.imageViewAfter.image];
        
        CGFloat xscale = imageSize.width / bulletOverlay.frame.size.width;
        CGFloat yscale = imageSize.height / bulletOverlay.frame.size.height;
        CGAffineTransform t = CGAffineTransformMakeScale(xscale, yscale);
        bulletOverlay.transform = t;

        bulletOverlay.center = CGPointMake(self.imageViewAfter.frame.size.width  / 2,
                                           self.imageViewAfter.frame.size.height / 2);

    }];
}

#pragma mark - User Controls

- (IBAction)sliderValueChanged:(UISlider *)sender {

    NSUInteger sliderTag = sender.tag;
    NSUInteger labelTag = sliderTag + 5;
    
    UILabel *label = (UILabel *)[self.view viewWithTag:labelTag];
    
    float value = sender.value;
    [label setText:[NSString stringWithFormat:@"%.2f", value]];
    
    [self performKeystoneCorrectionTest];
}

- (IBAction)switchValueChanged:(UISwitch *)sender {

    [self performKeystoneCorrectionTest];

}

- (NSDictionary *)getOptionsDictionaryFromSliders {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

    [dict setObject:[NSNumber numberWithFloat:HOUGH_RHO_CONSTANT] forKey:KEY_HOUGH_RHO];
    [dict setObject:[NSNumber numberWithFloat:HOUGH_THETA_CONSTANT] forKey:KEY_HOUGH_THETA];

    UISwitch *onlyLinesSwitch = (UISwitch *)[self.view viewWithTag:2];
    [dict setObject:[NSNumber numberWithBool:onlyLinesSwitch.on] forKey:KEY_ONLY_SHOW_LINES];
    
    UISlider *cannyLowThresh = (UISlider *)[self.view viewWithTag:3];
    [dict setObject:[NSNumber numberWithFloat:cannyLowThresh.value] forKey:KEY_CANNY_LOW_THRESHOLD];
    
    UISlider *houghIntersectionThreshold = (UISlider *)[self.view viewWithTag:4];
    [dict setObject:[NSNumber numberWithFloat:houghIntersectionThreshold.value] forKey:KEY_HOUGH_INTERSECTION_THRESHOLD];
    
    UISlider *houghMinLineLen = (UISlider *)[self.view viewWithTag:5];
    [dict setObject:[NSNumber numberWithInt:houghMinLineLen.value] forKey:KEY_HOUGH_MIN_LINE_LENGTH];
    
    UISlider *houghMaxLineGap = (UISlider *)[self.view viewWithTag:6];
    [dict setObject:[NSNumber numberWithInt:houghMaxLineGap.value] forKey:KEY_HOUGH_MAX_LINE_GAP];
    

    return dict;
}

@end
