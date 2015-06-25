//
//  TVPerspectiveCorrector.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/23/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVPerspectiveCorrector : NSObject

enum BlurType { Normal, Gaussian, Median, Bilateral };

+ (void)startWarpCorrection:(UIImage *)image
                WithOptions:(NSDictionary *)options
                 Completion:(void (^)(UIImage *, int))callback;

@end
