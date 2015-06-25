//
//  TVViewController.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageViewBefore;

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAfter;


- (IBAction)sliderValueChanged:(UISlider *)sender;

- (IBAction)switchValueChanged:(UISwitch *)sender;

@end
