//
//  TVContentViewController.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TVContentViewController : UIViewController

@property (assign, nonatomic) NSInteger indexNumber;

@property (strong, nonatomic) UIImageView *contentImageView;

- (id)initWithImage:(UIImage *)image Index:(NSUInteger)index;
- (void)loadImage:(UIImage *)image;

@end
