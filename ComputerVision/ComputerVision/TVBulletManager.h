//
//  TVBulletManager.h
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "Headers.h"

@interface TVBulletManager : NSObject

+ (id)sharedManager;

- (void)addTemplateFrame:(GPUImagePicture *)frame;

- (void)addNewFrame:(GPUImagePicture *)frame;


@end
