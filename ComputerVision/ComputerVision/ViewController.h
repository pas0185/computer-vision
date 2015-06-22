//
//  ViewController.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 5/28/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface ViewController : UIViewController<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *fullImageView;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewPrevious;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewCurrent;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewDifference;

@property (nonatomic) BOOL m1Running;
@property (nonatomic) BOOL m2Running;

- (IBAction)snapPrevious:(id)sender;
- (IBAction)snapCurrent:(id)sender;
- (IBAction)calculateDiff:(id)sender;
- (IBAction)reset:(id)sender;

@end

