//
//  TVPageViewController.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TVContentViewController;

@interface TVPageViewController : UIPageViewController<UIPageViewControllerDataSource, UIGestureRecognizerDelegate, UIPageViewControllerDelegate>

@property (strong, nonatomic) TVContentViewController *contentView1;
@property (strong, nonatomic) TVContentViewController *contentView2;
@property (strong, nonatomic) TVContentViewController *contentView3;

@property (strong, nonatomic) NSMutableArray *contentViewControllers;
@end
