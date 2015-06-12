//
//  TVPageViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVPageViewController.h"
#import "TVContentViewController.h"
#import "TVBulletSeekerAlgorithm.h"
#import "TVUtility.h"

#define IMAGE_A @"scene00451"
#define IMAGE_B @"scene00931"

@interface TVPageViewController ()

@property BOOL pageAnimationFinished;
@property NSUInteger minimumPage;
@property NSUInteger currentPage;
@property NSUInteger maximumPage;


@end

@implementation TVPageViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.dataSource = self;
    self.delegate = self;
    [self initializeContentViews];
    
    
    for (UIGestureRecognizer * gesRecog in self.gestureRecognizers)
    {
        if ([gesRecog isKindOfClass:[UITapGestureRecognizer class]])
            gesRecog.enabled = NO;
        else if ([gesRecog isKindOfClass:[UIPanGestureRecognizer class]])
            gesRecog.delegate = self;
    }
    
    _pageAnimationFinished = YES;
    
}

- (void)initializeContentViews {
    
    self.contentViewControllers = [NSMutableArray new];
    
    UIImage *image1 = [UIImage imageNamed:IMAGE_A];
    UIImage *image2 = [UIImage imageNamed:IMAGE_B];
    
    self.contentView1 = [[TVContentViewController alloc] initWithImage:image1 Index:0];
    self.contentView2 = [[TVContentViewController alloc] initWithImage:image2 Index:1];
    self.contentView3 = [[TVContentViewController alloc] initWithImage:nil Index:2];
    
    [self.contentViewControllers addObject:self.contentView1];
    [self.contentViewControllers addObject:self.contentView2];
    [self.contentViewControllers addObject:self.contentView3];
    
    
    _minimumPage = 0;
    _currentPage = 0;
    _maximumPage = 2;
    
    [self performBulletCalculationWithFirst:image1 Second:image2 ToContentView:self.contentView3];
    
    
    TVContentViewController *viewControllerObject = [self viewControllerAtIndex:0];
    
    NSArray *viewControllers = [NSArray arrayWithObject:viewControllerObject];
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    if (_currentPage == _minimumPage) {
        return nil;
    }
    
    _currentPage--;
    
    return [self viewControllerAtIndex:_currentPage];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    if (_currentPage == _maximumPage) {
        return nil;
    }
    _currentPage++;

    return [self viewControllerAtIndex:_currentPage];
}

- (TVContentViewController *)viewControllerAtIndex:(NSUInteger)index {

    NSLog(@"Requesting index #%lu", index);
    
    return self.contentViewControllers[index];
    
}


- (void)performBulletCalculationWithFirst:(UIImage *)image1 Second:(UIImage *)image2 ToContentView:(TVContentViewController *)contentView {

    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void){
        
        NSLog(@"About to calculate diff image");
        UIImage *diffImage = [TVUtility differenceImageFrom:image1 Minus:image2];

        NSLog(@"Finished calculating diff image");
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"About to load diff image to content view");
            [contentView loadImage:diffImage];
            NSLog(@"Finished loading diff image to content view");
        });
    });
    
    
}



@end
