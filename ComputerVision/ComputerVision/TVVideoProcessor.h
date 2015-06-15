//
//  TVVideoProcessor.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVVideoProcessor : NSObject

+ (id)sharedInstance;

- (void)setTemplateImage:(UIImage *)image;
- (NSArray *)TVBulletsFromImage:(UIImage *)image;

@end
