//
//  Constants.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/18/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#ifndef ComputerVision_Constants_h
#define ComputerVision_Constants_h

#define TVHexColorOrange 0xFF6600
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#define TVOrangeColor UIColorFromRGB(TVHexColorOrange)


#define IGNORE_BULLETS_WITH_SAME_CENTER YES
#define THRESHOLD_FOR_IGNORING_NEARBY_BULLETS 1

#define BULLET_DENSITY_THRESHOLD 0.25

#define DENSITY_MIN 0.7
#define DENSITY_MAX 1.3

#define FRAME_PER_SECOND 1

#endif
