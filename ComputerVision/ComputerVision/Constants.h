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

#define KEY_CANNY_LOW_THRESHOLD @"CANNY_LOW_THRESHOLD"
#define KEY_HOUGH_RHO @"HOUGH_RHO"
#define KEY_HOUGH_THETA @"HOUGH_THETA"
#define KEY_HOUGH_INTERSECTION_THRESHOLD @"HOUGH_INTERSECTION_THRESHOLD"
#define KEY_HOUGH_MIN_LINE_LENGTH @"HOUGH_MIN_LINE_LENGTH"
#define KEY_HOUGH_MAX_LINE_GAP @"HOUGH_MAX_LINE_GAP"
#define KEY_ONLY_SHOW_LINES @"ONLY_LINES"

#define HOUGH_RHO_CONSTANT 1
#define HOUGH_THETA_CONSTANT CV_PI/180

#endif
