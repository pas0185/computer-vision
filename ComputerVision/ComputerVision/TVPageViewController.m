//
//  TVPageViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVPageViewController.h"
#import "TVContentViewController.h"

@interface TVPageViewController ()

@end

@implementation TVPageViewController


- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    NSUInteger index = [(TVContentViewController *)viewController indexNumber];
    
    
    
    if (index == 0) {
        
        return nil;
        
    }
    
    index--;
    
    
    
    return [self viewControllerAtIndex:index];
    
    
    
}



- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    
    
    NSUInteger index = [(TVContentViewController *)viewController indexNumber];
    
    index++;
    
    
    
    if (index == 3) {
        
        return nil;
        
    }
    
    return [self viewControllerAtIndex:index];
    
    
    
}

- (TVContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    
    NSString *imageName = @"target-0-shots";
    if (index == 1) {
        imageName = @"target-1-shot";
    }
    if (index == 2) {
        imageName = @"target-2-shots";
    }
    
    TVContentViewController *childViewController = [[TVContentViewController alloc] init];
    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imgView1.contentMode = UIViewContentModeScaleAspectFit;
    [childViewController setView:imgView1];

    childViewController.indexNumber = index;
    
    return childViewController;
    
}





- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.dataSource = self;
    TVContentViewController *viewControllerObject = [self viewControllerAtIndex:0];
    
    
    
    NSArray *viewControllers = [NSArray arrayWithObject:viewControllerObject];
    
    
    
    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    
//    [self.pageController didMoveToParentViewController:self];
    
    
    
    
    
    
    
//    UIViewController *viewController1 = [[UIViewController alloc] init];
//    UIImageView *imgView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target-0-shots"]];
//    imgView1.contentMode = UIViewContentModeScaleAspectFit;
//    [viewController1 setView:imgView1];
//    
//    
//    UIViewController *viewController2 = [[UIViewController alloc] init];
//    UIImageView *imgView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target-1-shot"]];
//    imgView2.contentMode = UIViewContentModeScaleAspectFit;
//    [viewController2 setView:imgView2];
//    
//    
//    
//    
//    
//    
//    NSArray *viewControllers = @[viewController1, viewController2];
//    
//    [self setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
