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

@interface TVPageViewController ()

@property BOOL pageAnimationFinished;
@property NSUInteger minimumPage;
@property NSUInteger currentPage;
@property NSUInteger maximumPage;


@end

@implementation TVPageViewController


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TVContentViewController *)viewController indexNumber];
    _currentPage--;
    
    if (index == 0) {
        return nil;
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TVContentViewController *)viewController indexNumber];
    _currentPage++;
    index++;
    
    if (index == 3) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

- (TVContentViewController *)viewControllerAtIndex:(NSUInteger)index {

//    _currentPage = index;
    NSLog(@"Requesting index #%lu", index);
    NSLog(@"Current page is %lu", _currentPage);
    
    
    return self.contentViewControllers[_currentPage];
    
}


- (void)initializeContentViews {
    
    self.contentViewControllers = [NSMutableArray new];
    
    UIImage *image1 = [UIImage imageNamed:@"target-0-shots"];
    UIImage *image2 = [UIImage imageNamed:@"target-1-shot"];
    UIImage *image3 = [UIImage imageNamed:@"target-2-shots"];

    self.contentView1 = [[TVContentViewController alloc] initWithImage:image1 Index:0];
    self.contentView2 = [[TVContentViewController alloc] initWithImage:image2 Index:1];
    self.contentView3 = [[TVContentViewController alloc] initWithImage:image3 Index:2];
    
    [self.contentViewControllers addObject:self.contentView1];
    [self.contentViewControllers addObject:self.contentView2];
    [self.contentViewControllers addObject:self.contentView3];
    
    
    _minimumPage = 0;
    _currentPage = 0;
    _maximumPage = 2;
    
//    [self performBulletCalculationWithFirst:image1 Second:image2 ToContentView:self.contentView3];
    
    
    
    
    TVContentViewController *viewControllerObject = [self viewControllerAtIndex:0];

    NSArray *viewControllers = [NSArray arrayWithObject:viewControllerObject];

    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];

    
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

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    NSLog(@"Should gesture recognizer begin...?");
    if (_pageAnimationFinished) {
        
        NSLog(@"...Yup! Page animation is finished");

        _pageAnimationFinished = NO;
        return YES;
    }
    
    NSLog(@"...Nope! Page animation not finished");

    return NO;
    
    
//    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
//        && ([gestureRecognizer.view isEqual:self.view]
//            || [gestureRecognizer.view isEqual:self.view]))
//    {
//        UIPanGestureRecognizer * panGes = (UIPanGestureRecognizer *)gestureRecognizer;
//        if (!_pageAnimationFinished) {
//            return NO;
//        }
////        if(!_pageAnimationFinished || (_currentPage < _minimumPage && [panGes velocityInView:self.view].x < 0) || (_currentPage > _maximumPage && [panGes velocityInView:self.view].x > 0))
////            return NO;
//        _pageAnimationFinished = NO;
//    }
//    return YES;
}

- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
    
    NSLog(@"Page animation started");
    _pageAnimationFinished = NO;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed
{
    NSLog(@"Page animation finished");
    _pageAnimationFinished = YES;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
