//
//  TVViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVViewController.h"
#import "cap_ios.h"

//#define IMAGE_TEMPLATE @"target-0-shots"
//#define IMAGE_WITH_SHOT @"target-2-shots"

#define IMAGE_TEMPLATE @"scene00451"
#define IMAGE_WITH_SHOT @"scene00931"

//#define IMAGE_TEMPLATE @"scene00001"
//#define IMAGE_WITH_SHOT @"scene01201"

#define TEST_MOVIE @"grass-target-white"


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
    
//    // Add tap gesture recognizer
//    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
//    tgr.delegate = self;
//    [self.imageView addGestureRecognizer:tgr];
//    
//    
//    // Process the image with two shots in it
//    UIImage *imgWithShots = [UIImage imageNamed:IMAGE_WITH_SHOT];
//    [self.imageView setImage:imgWithShots];

}

- (void)viewDidAppear:(BOOL)animated {
    
//    [self performImageProcessorTest];
    
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *moviePath = [bundle pathForResource:TEST_MOVIE ofType:@"mp4"];
    NSURL *movieURL = [NSURL fileURLWithPath:moviePath];
    
    [self processVideo:movieURL];
    
}

- (void)processVideo:(NSURL *)movieURL {

    @synchronized(self){
        
        MPMoviePlayerViewController *movie = [[MPMoviePlayerViewController alloc] initWithContentURL:movieURL];
        TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];

        [movie.moviePlayer setControlStyle:MPMovieControlStyleDefault];
        [movie.moviePlayer prepareToPlay];
        
        [self presentMoviePlayerViewControllerAnimated:movie];
        
        AVURLAsset *asset1 = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
        AVAssetImageGenerator *generate1 = [[AVAssetImageGenerator alloc] initWithAsset:asset1];
        generate1.appliesPreferredTrackTransform = YES;
        NSError *err = NULL;
        CMTime time = CMTimeMake(1, 1);
        CGImageRef oneRef = [generate1 copyCGImageAtTime:time actualTime:NULL error:&err];
        UIImage *imgTemplate = [[UIImage alloc] initWithCGImage:oneRef];
        
        [vidProcessor setTemplateImage:imgTemplate];
        
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:movieURL options:nil];
        AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        generator.appliesPreferredTrackTransform = YES;
            for (Float64 i = 0; i < CMTimeGetSeconds(asset.duration) *  FRAME_PER_SECOND ; i++){
                @autoreleasepool {
                    CMTime myTime = CMTimeMake(i, FRAME_PER_SECOND);
                    CGImageRef image = [generator copyCGImageAtTime:myTime actualTime:NULL error:&err];
                    UIImage *generatedImage = [[UIImage alloc] initWithCGImage:image];
                    CGImageRelease(image);
                    [vidProcessor findTVBulletsWithImage:generatedImage Completion:^(TVBulletSpace *bulletSpace) {
                        [movie.moviePlayer play];
                        UIView *bulletOverlay = [bulletSpace getOverlayView];
                        [self.view addSubview:bulletOverlay];
                        
                        // Scale the bullet overlay to fit the image
                        CGSize imageSize = [TVUtility aspectScaledImageSizeForImageView:self.imageView image:self.imageView.image];
                        
                        CGFloat xscale = imageSize.width / bulletOverlay.frame.size.width;
                        CGFloat yscale = imageSize.height / bulletOverlay.frame.size.height;
                        CGAffineTransform t = CGAffineTransformMakeScale(xscale, yscale);
                        bulletOverlay.transform = t;
                        
                        bulletOverlay.center = CGPointMake(self.imageView.frame.size.width  / 2,
                                                           self.imageView.frame.size.height / 2);
                        
                    }];
                }
            }
    }
}

- (void)performImageProcessorTest {
    
    TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];
    
    // Set the template image for the VideoProcessor
    UIImage *imgTemplate = [UIImage imageNamed:IMAGE_TEMPLATE];
    [vidProcessor setTemplateImage:imgTemplate];
    
    
    // Process the image with two shots in it
    UIImage *imgWithShots = [UIImage imageNamed:IMAGE_WITH_SHOT];
    
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

    }];
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
}

#pragma mark - User Controls

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {

    
    CGPoint ptInView = [tapGestureRecognizer locationInView:self.view];
    CGPoint ptInImgView = [tapGestureRecognizer locationInView:self.imageView];
    
    NSLog(@"You tapped in main view: (%.02f, %.02f)", ptInView.x, ptInView.y);
    NSLog(@" ... ... ... image view: (%.02f, %.02f)\n", ptInImgView.x, ptInImgView.y);
    
}

@end
