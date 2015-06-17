//
//  Headers.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/2/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#ifndef ComputerVision_Header_h
#define ComputerVision_Header_h


#import "TVBullet.h"
#import "TVBulletSpace.h"
#import "TVUtility.h"
#import "TVVideoProcessor.h"

#import "GPUImage.h"

#define TVHexColorOrange 0xFF6600
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define TVOrangeColor UIColorFromRGB(TVHexColorOrange)

#endif