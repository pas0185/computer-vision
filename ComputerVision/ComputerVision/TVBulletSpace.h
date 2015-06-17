//
//  TVBulletSpace.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/16/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVBulletSpace : NSObject

- (id)initWithCannyOutput:(cv::Mat) mCanny;

- (NSArray *)getBullets;

- (CGSize)size;

- (UIView *)getOverlayView;

@end
