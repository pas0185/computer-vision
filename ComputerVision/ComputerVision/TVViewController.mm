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
    
    [self performVideoProcessorTest];
    
    // Add tap gesture recognizer
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tgr.delegate = self;
    [self.imageView addGestureRecognizer:tgr];
}

- (void)performVideoProcessorTest {
    
    TVVideoProcessor *vidProcessor = [TVVideoProcessor sharedInstance];
    
    // Set the template image for the VideoProcessor
    UIImage *imgTemplate = [UIImage imageNamed:IMAGE_TARGET_EMPTY];
    [vidProcessor setTemplateImage:imgTemplate];
    
    
    // Process the image with two shots in it
    UIImage *imgWithShots = [UIImage imageNamed:IMAGE_TARGET_TWO_SHOTS];
    [self.imageView setImage:imgWithShots];
    
    [vidProcessor findTVBulletsWithImage:imgWithShots
                              Completion:^(NSArray *arrBullets) {
        
        for (TVBullet *bullet in arrBullets) {
            
            CGFloat fullViewWidth = self.view.frame.size.width;
            CGFloat fullViewHeight = self.view.frame.size.height;
            
            CGFloat xNormFullView = bullet.ptCenter.x * fullViewWidth;
            CGFloat yNormFullView = bullet.ptCenter.y * fullViewHeight + 20.0f;
            
            
            UIView *bulletHighlight = [[UIView alloc] initWithFrame:CGRectMake(xNormFullView - 5, yNormFullView + 5, 10, 10)];
            [bulletHighlight setBackgroundColor:[UIColor blueColor]];
            [self.imageView addSubview:bulletHighlight];
        }
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
