//
//  TVViewController.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/13/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVViewController.h"
#import "GPUImage.h"

#define IMAGE_A @"target-0-shots"
#define IMAGE_B @"target-2-shots"

@interface TVViewController ()
{
    GPUImageHoughTransformLineDetector *houghTransformLineDetector, *houghTransformLineDetector2, *houghTransformLineDetector3, *houghTransformLineDetector4;
    GPUImagePicture *blackAndWhiteBoxImage, *chairPicture, *lineTestPicture, *lineTestPicture2;
    GPUImageAverageColor *averageColor;
    GPUImageLuminosity *averageLuminosity;
    GPUImageHarrisCornerDetectionFilter *harrisCornerFilter;
    GPUImageNobleCornerDetectionFilter *nobleCornerFilter;
    GPUImageShiTomasiFeatureDetectionFilter *shiTomasiCornerFilter;
}


@end

@implementation TVViewController


#pragma mark -
#pragma mark Initialization and teardown

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *currentDefaults = [NSUserDefaults standardUserDefaults];
        
        [currentDefaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                           [NSNumber numberWithFloat:0.89f], @"thresholdColorR",
                                           [NSNumber numberWithFloat:0.78f], @"thresholdColorG",
                                           [NSNumber numberWithFloat:0.0f], @"thresholdColorB",
                                           [NSNumber numberWithFloat:0.7], @"thresholdSensitivity",
                                           nil]];
        
        thresholdColor.one = [currentDefaults floatForKey:@"thresholdColorR"];
        thresholdColor.two = [currentDefaults floatForKey:@"thresholdColorG"];
        thresholdColor.three = [currentDefaults floatForKey:@"thresholdColorB"];
        displayMode = PASSTHROUGH_VIDEO;
        thresholdSensitivity = [currentDefaults floatForKey:@"thresholdSensitivity"];
    }
    return self;
}




//*************************************//


- (void)testFeatureDetection
{
    UIImage *inputImage = [UIImage imageNamed:@"71yih.png"];
    blackAndWhiteBoxImage = [[GPUImagePicture alloc] initWithImage:inputImage];
    UIImage *chairImage = [UIImage imageNamed:@"ChairTest.png"];
    chairPicture = [[GPUImagePicture alloc] initWithImage:chairImage];
    UIImage *lineTestImage = [UIImage imageNamed:@"LineTest.png"];
    lineTestPicture = [[GPUImagePicture alloc] initWithImage:lineTestImage];
    UIImage *lineTestImage2 = [UIImage imageNamed:@"LineTest2.png"];
    lineTestPicture2 = [[GPUImagePicture alloc] initWithImage:lineTestImage2];
    
    // Testing feature detection
    [self testHarrisCornerDetectorAgainstPicture:blackAndWhiteBoxImage withName:@"WhiteBoxes"];
    [self testNobleCornerDetectorAgainstPicture:blackAndWhiteBoxImage withName:@"WhiteBoxes"];
    [self testShiTomasiCornerDetectorAgainstPicture:blackAndWhiteBoxImage withName:@"WhiteBoxes"];
    
    // Testing Hough transform
    houghTransformLineDetector = [[GPUImageHoughTransformLineDetector alloc] init];
    [self testHoughTransform:houghTransformLineDetector ofName:@"HoughTransform" againstPicture:blackAndWhiteBoxImage withName:@"WhiteBoxes"];
    houghTransformLineDetector2 = [[GPUImageHoughTransformLineDetector alloc] init];
    [self testHoughTransform:houghTransformLineDetector2 ofName:@"HoughTransform" againstPicture:chairPicture withName:@"Chair"];
    houghTransformLineDetector3 = [[GPUImageHoughTransformLineDetector alloc] init];
    [self testHoughTransform:houghTransformLineDetector3 ofName:@"HoughTransform" againstPicture:lineTestPicture withName:@"LineTest"];
    houghTransformLineDetector4 = [[GPUImageHoughTransformLineDetector alloc] init];
    [self testHoughTransform:houghTransformLineDetector4 ofName:@"HoughTransform" againstPicture:lineTestPicture2 withName:@"LineTest2"];
    
    // Testing erosion and dilation
    GPUImageErosionFilter *erosionFilter = [[GPUImageErosionFilter alloc] initWithRadius:4];
    [blackAndWhiteBoxImage removeAllTargets];
    [blackAndWhiteBoxImage addTarget:erosionFilter];
    [erosionFilter useNextFrameForImageCapture];
    [blackAndWhiteBoxImage processImage];
    UIImage *erosionImage = [erosionFilter imageFromCurrentFramebuffer];
    [self saveImage:erosionImage fileName:@"Erosion4.png"];
    
    GPUImageDilationFilter *dilationFilter = [[GPUImageDilationFilter alloc] initWithRadius:4];
    [blackAndWhiteBoxImage removeAllTargets];
    [blackAndWhiteBoxImage addTarget:dilationFilter];
    [dilationFilter useNextFrameForImageCapture];
    [blackAndWhiteBoxImage processImage];
    UIImage *dilationImage = [dilationFilter imageFromCurrentFramebuffer];
    [self saveImage:dilationImage fileName:@"Dilation4.png"];
    
    GPUImageOpeningFilter *openingFilter = [[GPUImageOpeningFilter alloc] initWithRadius:4];
    [blackAndWhiteBoxImage removeAllTargets];
    [blackAndWhiteBoxImage addTarget:openingFilter];
    [openingFilter useNextFrameForImageCapture];
    [blackAndWhiteBoxImage processImage];
    UIImage *openingImage = [openingFilter imageFromCurrentFramebuffer];
    [self saveImage:openingImage fileName:@"Opening4.png"];
    
    GPUImageClosingFilter *closingFilter = [[GPUImageClosingFilter alloc] initWithRadius:4];
    [blackAndWhiteBoxImage removeAllTargets];
    [blackAndWhiteBoxImage addTarget:closingFilter];
    [closingFilter useNextFrameForImageCapture];
    [blackAndWhiteBoxImage processImage];
    UIImage *closingImage = [closingFilter imageFromCurrentFramebuffer];
    [self saveImage:closingImage fileName:@"Closing4.png"];
    
    UIImage *compressionInputImage = [UIImage imageNamed:@"8pixeltest.png"];
    GPUImagePicture *compressionImage = [[GPUImagePicture alloc] initWithImage:compressionInputImage];
    GPUImageColorPackingFilter *packingFilter = [[GPUImageColorPackingFilter alloc] init];
    [compressionImage addTarget:packingFilter];
    [packingFilter useNextFrameForImageCapture];
    [compressionImage processImage];
    UIImage *compressedImage = [packingFilter imageFromCurrentFramebuffer];
    [self saveImage:compressedImage fileName:@"Compression.png"];
    
    // Testing local binary patterns
    UIImage *inputLBPImage = [UIImage imageNamed:@"LBPTest.png"];
    GPUImagePicture *lbpImage = [[GPUImagePicture alloc] initWithImage:inputLBPImage];
    
    GPUImageLocalBinaryPatternFilter *lbpFilter = [[GPUImageLocalBinaryPatternFilter alloc] init];
    [lbpImage removeAllTargets];
    [lbpImage addTarget:lbpFilter];
    [lbpFilter useNextFrameForImageCapture];
    [lbpImage processImage];
    UIImage *lbpOutput = [lbpFilter imageFromCurrentFramebuffer];
    [self saveImage:lbpOutput fileName:@"LocalBinaryPatterns.png"];
    
    // Testing image color averaging
    averageColor = [[GPUImageAverageColor alloc] init];
    [averageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime){
        NSLog(@"Red: %f, green: %f, blue: %f, alpha: %f", redComponent, greenComponent, blueComponent, alphaComponent);
    }];
    
    averageLuminosity = [[GPUImageLuminosity alloc] init];
    [averageLuminosity setLuminosityProcessingFinishedBlock:^(CGFloat luminosity, CMTime frameTime) {
        NSLog(@"Luminosity: %f", luminosity);
    }];
    
    // Testing Gaussian blur
    UIImage *gaussianBlurInput = [UIImage imageNamed:@"GaussianTest.png"];
    GPUImagePicture *gaussianImage = [[GPUImagePicture alloc] initWithImage:gaussianBlurInput];
    GPUImageGaussianBlurFilter *gaussianBlur = [[GPUImageGaussianBlurFilter alloc] init];
    gaussianBlur.blurRadiusInPixels = 2.0;
    [gaussianImage addTarget:gaussianBlur];
    [gaussianBlur useNextFrameForImageCapture];
    [gaussianImage processImage];
    UIImage *gaussianOutput = [gaussianBlur imageFromCurrentFramebuffer];
    [self saveImage:gaussianOutput fileName:@"Gaussian-GPUImage.png"];
    
    CIContext *coreImageContext = [CIContext contextWithEAGLContext:[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2]];
    
    //    CIContext *coreImageContext = [CIContext contextWithOptions:nil];
    
    //    NSArray *cifilters = [CIFilter filterNamesInCategory:kCICategoryBuiltIn];
    //    for (NSString *ciFilterName in cifilters)
    //    {
    //        NSLog(@"%@", ciFilterName);
    //    }
    CIImage *inputCIGaussianImage = [[CIImage alloc] initWithCGImage:gaussianBlurInput.CGImage];
    CIFilter *gaussianBlurCIFilter = [CIFilter filterWithName:@"CIGaussianBlur"
                                                keysAndValues: kCIInputImageKey, inputCIGaussianImage,
                                      @"inputRadius", [NSNumber numberWithFloat:2.0], nil];
    CIImage *coreImageResult = [gaussianBlurCIFilter outputImage];
    CGImageRef resultRef = [coreImageContext createCGImage:coreImageResult fromRect:CGRectMake(0, 0, gaussianBlurInput.size.width, gaussianBlurInput.size.height)];
    UIImage *coreImageResult2 = [UIImage imageWithCGImage:resultRef];
    [self saveImage:coreImageResult2 fileName:@"Gaussian-CoreImage.png"];
    CGImageRelease(resultRef);
    
    GPUImageBoxBlurFilter *boxBlur = [[GPUImageBoxBlurFilter alloc] init];
    boxBlur.blurRadiusInPixels = 3.0;
    [gaussianImage removeAllTargets];
    [gaussianImage addTarget:boxBlur];
    [boxBlur useNextFrameForImageCapture];
    [gaussianImage processImage];
    UIImage *boxOutput = [boxBlur imageFromCurrentFramebuffer];
    [self saveImage:boxOutput fileName:@"BoxBlur-GPUImage.png"];
    
    CIImage *inputCIBoxImage = [[CIImage alloc] initWithCGImage:gaussianBlurInput.CGImage];
    CIFilter *boxBlurCIFilter = [CIFilter filterWithName:@"CIBoxBlur"
                                           keysAndValues: kCIInputImageKey, inputCIBoxImage,
                                 @"inputRadius", [NSNumber numberWithFloat:2.0], nil];
    
    NSLog(@"Box blur: %@", boxBlurCIFilter);
    CIImage *coreImageResult3 = [boxBlurCIFilter outputImage];
    CGImageRef resultRef2 = [coreImageContext createCGImage:coreImageResult3 fromRect:CGRectMake(0, 0, gaussianBlurInput.size.width, gaussianBlurInput.size.height)];
    UIImage *coreImageResult4 = [UIImage imageWithCGImage:resultRef2];
    [self saveImage:coreImageResult4 fileName:@"BoxBlur-CoreImage.png"];
    CGImageRelease(resultRef2);
    
    [chairPicture removeAllTargets];
    [chairPicture addTarget:averageColor];
    [chairPicture addTarget:averageLuminosity];
    [chairPicture processImage];
    //    UIImage *lbpOutput = [lbpFilter imageFromCurrentlyProcessedOutput];
    //    [self saveImage:lbpOutput fileName:@"LocalBinaryPatterns.png"];
    

}

- (void)testHoughTransform:(GPUImageHoughTransformLineDetector *)lineDetector ofName:(NSString *)detectorName againstPicture:(GPUImagePicture *)pictureInput withName:(NSString *)pictureName;
{
    [pictureInput removeAllTargets];
    [pictureInput addTarget:lineDetector];
    
    __unsafe_unretained GPUImageHoughTransformLineDetector * weakDetector = lineDetector;
    [lineDetector setLinesDetectedBlock:^(GLfloat* lineArray, NSUInteger linesDetected, CMTime frameTime){
        NSLog(@"Number of lines: %ld", (unsigned long)linesDetected);
        
        GPUImageLineGenerator *lineGenerator = [[GPUImageLineGenerator alloc] init];
        //        lineGenerator.crosshairWidth = 10.0;
        [lineGenerator setLineColorRed:1.0 green:0.0 blue:0.0];
        [lineGenerator forceProcessingAtSize:[pictureInput outputImageSize]];
        
        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        [blendFilter forceProcessingAtSize:[pictureInput outputImageSize]];
        
        [pictureInput addTarget:blendFilter];
        
        [lineGenerator addTarget:blendFilter];
        
        [blendFilter useNextFrameForImageCapture];
        
        [lineGenerator renderLinesFromArray:lineArray count:linesDetected frameTime:frameTime];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger currentImageIndex = 0;
            for (UIImage *currentImage in weakDetector.intermediateImages)
            {
                [self saveImage:currentImage fileName:[NSString stringWithFormat:@"%@-%@-%ld.png", detectorName, pictureName, (unsigned long)currentImageIndex]];
                
                currentImageIndex++;
            }
            
            UIImage *crosshairResult = [blendFilter imageFromCurrentFramebuffer];
            
            [self saveImage:crosshairResult fileName:[NSString stringWithFormat:@"%@-%@-Lines.png", detectorName, pictureName]];
        });
    }];
    
    [pictureInput processImage];
}

- (void)testCornerDetector:(GPUImageHarrisCornerDetectionFilter *)cornerDetector ofName:(NSString *)detectorName againstPicture:(GPUImagePicture *)pictureInput withName:(NSString *)pictureName;
{
    cornerDetector.threshold = 0.4;
    cornerDetector.sensitivity = 4.0;
    //    cornerDetector.blurSize = 1.0;
    [pictureInput removeAllTargets];
    
    [pictureInput addTarget:cornerDetector];
    
    __unsafe_unretained GPUImageHarrisCornerDetectionFilter * weakDetector = cornerDetector;
    [cornerDetector setCornersDetectedBlock:^(GLfloat* cornerArray, NSUInteger cornersDetected, CMTime frameTime) {
        GPUImageCrosshairGenerator *crosshairGenerator = [[GPUImageCrosshairGenerator alloc] init];
        crosshairGenerator.crosshairWidth = 10.0;
        [crosshairGenerator setCrosshairColorRed:1.0 green:0.0 blue:0.0];
        [crosshairGenerator forceProcessingAtSize:[pictureInput outputImageSize]];
        
        GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
        [blendFilter forceProcessingAtSize:[pictureInput outputImageSize]];
        
        [pictureInput addTarget:blendFilter];
        
        [crosshairGenerator addTarget:blendFilter];
        
        [blendFilter useNextFrameForImageCapture];
        
        NSLog(@"Number of corners: %ld", (unsigned long)cornersDetected);
        [crosshairGenerator renderCrosshairsFromArray:cornerArray count:cornersDetected frameTime:frameTime];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUInteger currentImageIndex = 0;
            for (UIImage *currentImage in weakDetector.intermediateImages)
            {
                [self saveImage:currentImage fileName:[NSString stringWithFormat:@"%@-%@-%ld.png", detectorName, pictureName, (unsigned long)currentImageIndex]];
                
                currentImageIndex++;
            }
            
            UIImage *crosshairResult = [blendFilter imageFromCurrentFramebuffer];
            
            [self saveImage:crosshairResult fileName:[NSString stringWithFormat:@"%@-%@-Crosshairs.png", detectorName, pictureName]];
        });
    }];
    
    
    [pictureInput processImage];
}

- (void)testHarrisCornerDetectorAgainstPicture:(GPUImagePicture *)pictureInput withName:(NSString *)pictureName;
{
    harrisCornerFilter = [[GPUImageHarrisCornerDetectionFilter alloc] init];
    [self testCornerDetector:harrisCornerFilter ofName:@"Harris" againstPicture:pictureInput withName:pictureName];
}

- (void)testNobleCornerDetectorAgainstPicture:(GPUImagePicture *)pictureInput withName:(NSString *)pictureName;
{
    nobleCornerFilter = [[GPUImageNobleCornerDetectionFilter alloc] init];
    [self testCornerDetector:nobleCornerFilter ofName:@"Noble" againstPicture:pictureInput withName:pictureName];
}

- (void)testShiTomasiCornerDetectorAgainstPicture:(GPUImagePicture *)pictureInput withName:(NSString *)pictureName;
{
    shiTomasiCornerFilter = [[GPUImageShiTomasiFeatureDetectionFilter alloc] init];
    [self testCornerDetector:shiTomasiCornerFilter ofName:@"ShiTomasi" againstPicture:pictureInput withName:pictureName];
}

- (void)saveImage:(UIImage *)imageToSave fileName:(NSString *)imageName;
{
    NSData *dataForPNGFile = UIImagePNGRepresentation(imageToSave);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSError *error = nil;
    if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:imageName] options:NSAtomicWrite error:&error])
    {
        return;
    }
}







//*************************************//


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
//    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
//    UIView *primaryView = [[UIView alloc] initWithFrame:mainScreenFrame];
//    primaryView.backgroundColor = [UIColor blueColor];
//    self.view = primaryView;
    
//    [self testThisShit];
    [self poop];
}

- (void)poop {
    
    UIImage *image1 = [UIImage imageNamed:IMAGE_A];
    UIImage *image2 = [UIImage imageNamed:IMAGE_B];
    
    
    /**************************************/
    /************* SUBTRACTOR *************/
    /**************************************/
    GPUImagePicture *mainPicture = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImagePicture *topPicture = [[GPUImagePicture alloc] initWithImage:image2];
    
    GPUImageDifferenceBlendFilter *differenceFilter = [[GPUImageDifferenceBlendFilter alloc] init];
    
    // Add both pictures to the Difference Blend Filter
    [mainPicture addTarget:differenceFilter];
    [topPicture addTarget:differenceFilter];
    /**************************************/
    /**************************************/

    
    
    /**************************************/
    /********** GAUSSIAN FILTER ***********/
    /**************************************/
    GPUImageGaussianBlurFilter *gaussianFilter = [[GPUImageGaussianBlurFilter alloc] init];
    
    [differenceFilter addTarget:gaussianFilter];
    
    [gaussianFilter useNextFrameForImageCapture];
    /**************************************/
    /**************************************/
    
    
    
    /**************************************/
    /******* HISTOGRAM THRESHOLDING *******/
    /**************************************/
    
    
    
    /**************************************/
    /**************************************/
    
    [mainPicture processImage];
    [topPicture processImage];


    UIImage *gaussianImage = [gaussianFilter imageFromCurrentFramebuffer];

    CIImage *coreImage = [[CIImage alloc] initWithImage:gaussianImage];

    
    /**************************************/
    /************* CIDetector *************/
    /**************************************/
    CIContext *context = [CIContext contextWithOptions:nil];                    // 1
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };      // 2
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                              context:context
                                              options:opts];                    // 3
    
    
    
//    opts = @{ CIDetectorImageOrientation :
//                  [[gaussianImage properties] valueForKey:kCGImagePropertyOrientation] }; // 4

    
    NSArray *features = [detector featuresInImage:coreImage options:opts];        // 5
    NSLog(@"%@", features);
    
    /**************************************/
    /**************************************/
    
}

- (void)testThisShit {
    
    
    
    UIImage *image1 = [UIImage imageNamed:IMAGE_A];
    UIImage *image2 = [UIImage imageNamed:IMAGE_B];
    
    GPUImageAlphaBlendFilter *filter = [[GPUImageAlphaBlendFilter alloc] init];

//    GPUImageDifferenceBlendFilter *filter = [[GPUImageDifferenceBlendFilter alloc] init];

    
    GPUImagePicture *imageToProcess = [[GPUImagePicture alloc] initWithImage:image1];
    GPUImagePicture *border = [[GPUImagePicture alloc] initWithImage:image2];
    
    filter.mix = 1.0f;
    [imageToProcess addTarget:filter];
    [border addTarget:filter];
    
    [imageToProcess processImage];
    [border processImage];
    
    
    
    
    
    UIImage *image3 = [filter imageFromCurrentFramebuffer];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image3];
    
    [self.view addSubview:imageView];
    imageView.contentMode = UIViewContentModeScaleAspectFit;

//    
//    
//    
//    
//    
//    // Build a camera
//    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionFront];
//    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
//
//    // make a filter for the camera
//    // [camera addTarget:filter]
////    GPUImageGlassSphereFilter *filter = [[GPUImageGlassSphereFilter alloc] init];
////    GPUImageDifferenceBlendFilter *filter = [[GPUImageDifferenceBlendFilter alloc] init];
//    
//    [videoCamera addTarget:filter];
//    
//    
//    // Make a GPUImageView *filterView
//    // [filter addTarget:filterView]
//    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
//    filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainScreenFrame.size.width, mainScreenFrame.size.height)];
//    [filter addTarget:filteredVideoView];
//    
//    
//    [self.view addSubview:filteredVideoView];
//    
//    
//    // Start rolling the camera
//    [videoCamera startCameraCapture];
//
//    
//    
//    
//    
//    UIImage *inputImage = [UIImage imageNamed:IMAGE_A];
//    
//    UIImage *image2 = [UIImage imageNamed:IMAGE_B];
//    
//    
//    
//    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
//    GPUImagePicture *gpuImagePic2 = [[GPUImagePicture alloc] initWithImage:image2];
//    
//    GPUImageDifferenceBlendFilter *diffFilter = [[GPUImageDifferenceBlendFilter alloc] init];
//    
//    
////    GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];
//    
////    [stillImageSource addTarget:stillImageFilter];
////    [stillImageFilter useNextFrameForImageCapture];
////    [stillImageSource processImage];
//    
//    
//    
//    
//    [stillImageSource addTarget:diffFilter];
//    [diffFilter useNextFrameForImageCapture];
//    [stillImageSource processImage];
//    
//    
//    
//    [gpuImagePic2 addTarget:diffFilter];
////    [diffFilter useNextFrameForImageCapture];
//    [gpuImagePic2 processImage];
//    
//    
//    
//    
//    
//    
//    UIImage *currentFilteredVideoFrame = [gpuImagePic2 imageFromCurrentFramebuffer];
//    
//    
//    GPUImageView *imageView = [[GPUImageView alloc] init];
//
////    UIImageView *imageView = [[UIImageView alloc] initWithImage:currentFilteredVideoFrame];
//
//    [self.view addSubview:imageView];
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
}


- (void)configureVideoFiltering;
{
    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
    videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, mainScreenFrame.size.width, mainScreenFrame.size.height)];
    [self.view addSubview:filteredVideoView];
    
    thresholdFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"Threshold"];
    [thresholdFilter setFloat:thresholdSensitivity forUniformName:@"threshold"];
    [thresholdFilter setFloatVec3:thresholdColor forUniformName:@"inputColor"];
    positionFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"PositionColor"];
    [positionFilter setFloat:thresholdSensitivity forUniformName:@"threshold"];
    [positionFilter setFloatVec3:thresholdColor forUniformName:@"inputColor"];
    
    //    CGSize videoPixelSize = filteredVideoView.bounds.size;
    //    videoPixelSize.width *= [filteredVideoView contentScaleFactor];
    //    videoPixelSize.height *= [filteredVideoView contentScaleFactor];
    
    CGSize videoPixelSize = CGSizeMake(480.0, 640.0);
    
    positionRawData = [[GPUImageRawDataOutput alloc] initWithImageSize:videoPixelSize resultsInBGRAFormat:YES];
    __unsafe_unretained TVViewController *weakSelf = self;
    [positionRawData setNewFrameAvailableBlock:^{
        GLubyte *bytesForPositionData = weakSelf->positionRawData.rawBytesForImage;
        CGPoint currentTrackingLocation = [weakSelf centroidFromTexture:bytesForPositionData ofSize:[weakSelf->positionRawData maximumOutputSize]];
        //        NSLog(@"Centroid from CPU: %f, %f", currentTrackingLocation.x, currentTrackingLocation.y);
        CGSize currentViewSize = weakSelf.view.bounds.size;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf->trackingDot.position = CGPointMake(currentTrackingLocation.x * currentViewSize.width, currentTrackingLocation.y * currentViewSize.height);
        });
    }];
    
    positionAverageColor = [[GPUImageAverageColor alloc] init];
    [positionAverageColor setColorAverageProcessingFinishedBlock:^(CGFloat redComponent, CGFloat greenComponent, CGFloat blueComponent, CGFloat alphaComponent, CMTime frameTime) {
        //        NSLog(@"GPU Average R: %f, G: %f, A: %f", redComponent, greenComponent, alphaComponent);
        CGPoint currentTrackingLocation = CGPointMake(1.0 - (greenComponent / alphaComponent), (redComponent / alphaComponent));
        if (isnan(currentTrackingLocation.x) || isnan(currentTrackingLocation.y)) {
            //            NSLog(@"NaN in currentTrackingLocation");
            return;
        }
        //        NSLog(@"Centroid from GPU: %f, %f", currentTrackingLocation.x, currentTrackingLocation.y);
        //                NSLog(@"Average color: %f, %f, %f, %f", redComponent, greenComponent, blueComponent, alphaComponent);
        CGSize currentViewSize = weakSelf.view.bounds.size;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf->trackingDot.position = CGPointMake(currentTrackingLocation.x * currentViewSize.width, currentTrackingLocation.y * currentViewSize.height);
        });
    }];
    
    videoRawData = [[GPUImageRawDataOutput alloc] initWithImageSize:videoPixelSize resultsInBGRAFormat:YES];
    [videoRawData setNewFrameAvailableBlock:^{
        if (weakSelf->shouldReplaceThresholdColor)
        {
            CGSize currentViewSize = weakSelf.view.bounds.size;
            CGSize rawPixelsSize = [weakSelf->videoRawData maximumOutputSize];
            
            
            CGPoint scaledTouchPoint;
            scaledTouchPoint.x = (weakSelf->currentTouchPoint.x / currentViewSize.width) * rawPixelsSize.width;
            scaledTouchPoint.y = (weakSelf->currentTouchPoint.y / currentViewSize.height) * rawPixelsSize.height;
            
            GPUByteColorVector colorAtTouchPoint = [weakSelf->videoRawData colorAtLocation:scaledTouchPoint];
            
            weakSelf->thresholdColor.one = (float)colorAtTouchPoint.red / 255.0;
            weakSelf->thresholdColor.two = (float)colorAtTouchPoint.green / 255.0;
            weakSelf->thresholdColor.three = (float)colorAtTouchPoint.blue / 255.0;
            
                        NSLog(@"Color at touch point: %d, %d, %d, %d", colorAtTouchPoint.red, colorAtTouchPoint.green, colorAtTouchPoint.blue, colorAtTouchPoint.alpha);
            
            [[NSUserDefaults standardUserDefaults] setFloat:weakSelf->thresholdColor.one forKey:@"thresholdColorR"];
            [[NSUserDefaults standardUserDefaults] setFloat:weakSelf->thresholdColor.two forKey:@"thresholdColorG"];
            [[NSUserDefaults standardUserDefaults] setFloat:weakSelf->thresholdColor.three forKey:@"thresholdColorB"];
            
            [weakSelf->thresholdFilter setFloatVec3:weakSelf->thresholdColor forUniformName:@"inputColor"];
            [weakSelf->positionFilter setFloatVec3:weakSelf->thresholdColor forUniformName:@"inputColor"];
            
            weakSelf->shouldReplaceThresholdColor = NO;
        }
    }];
    
    [videoCamera addTarget:filteredVideoView];
    [videoCamera addTarget:videoRawData];
    
    [videoCamera startCameraCapture];
}


- (void)configureToolbar;
{
    UISegmentedControl *displayModeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"Video", nil), NSLocalizedString(@"Threshold", nil), NSLocalizedString(@"Position", nil), NSLocalizedString(@"Track", nil), nil]];
    displayModeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    displayModeControl.selectedSegmentIndex = 0;
    [displayModeControl addTarget:self action:@selector(handleSwitchOfDisplayMode:) forControlEvents:UIControlEventValueChanged];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:displayModeControl];
    CGRect mainScreenFrame = [[UIScreen mainScreen] applicationFrame];
    
    displayModeControl.frame = CGRectMake(0.0f, 10.0f, mainScreenFrame.size.width - 20.0f, 30.0f);
    
    NSArray *theToolbarItems = [NSArray arrayWithObjects:item, nil];
    
    UIToolbar *lowerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, self.view.frame.size.height - 44.0f, self.view.frame.size.width, 44.0f)];
    lowerToolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    lowerToolbar.tintColor = [UIColor blackColor];
    
    [lowerToolbar setItems:theToolbarItems];
    
    [self.view addSubview:lowerToolbar];
}

- (void)configureTrackingDot;
{
    trackingDot = [[CALayer alloc] init];
    trackingDot.bounds = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
    trackingDot.cornerRadius = 20.0f;
    trackingDot.backgroundColor = [[UIColor blueColor] CGColor];
    
    NSMutableDictionary *newActions = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNull null], @"position", nil];
    
    trackingDot.actions = newActions;
    
    trackingDot.position = CGPointMake(100.0f, 100.0f);
    trackingDot.opacity = 0.0f;
    
    [self.view.layer addSublayer:trackingDot];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)testGPUImagePhotoCapture {
    GPUImageStillCamera *stillCamera = [[GPUImageStillCamera alloc] init];
    stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    GPUImageGammaFilter *filter = [[GPUImageGammaFilter alloc] init];
    [stillCamera addTarget:filter];
    GPUImageView *filterView = (GPUImageView *)self.view;
    [filter addTarget:filterView];
    
    [stillCamera startCameraCapture];
}
- (void)testGPUImageVideoCamera {
    
    GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
//    GPUImageFilter *customFilter = [[GPUImageFilter alloc] init];// initWithFragmentShaderFromFile:@"CustomShader"];
    
    GPUImageGammaFilter *customFilter = [[GPUImageGammaFilter alloc] init];
    
    
    
    GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.height, self.view.frame.size.width)];
    
    // Add the view somewhere so it's visible
    [self.view addSubview:filteredVideoView];
    
    [videoCamera addTarget:customFilter];
    [customFilter addTarget:filteredVideoView];
    
    [videoCamera startCameraCapture];
}


#pragma mark -
#pragma mark Display mode switching

- (void)handleSwitchOfDisplayMode:(id)sender;
{
    ColorTrackingDisplayMode newDisplayMode = [sender selectedSegmentIndex];
    
    if (newDisplayMode != displayMode)
    {
        displayMode = newDisplayMode;
        if (displayMode == OBJECT_TRACKING)
        {
            trackingDot.opacity = 1.0f;
        }
        else
        {
            trackingDot.opacity = 0.0f;
        }
        
        [videoCamera removeAllTargets];
        [positionFilter removeAllTargets];
        [thresholdFilter removeAllTargets];
        [videoCamera addTarget:videoRawData];
        
        switch(displayMode)
        {
            case PASSTHROUGH_VIDEO:
            {
                [videoCamera addTarget:filteredVideoView];
            }; break;
            case SIMPLE_THRESHOLDING:
            {
                [videoCamera addTarget:thresholdFilter];
                [thresholdFilter addTarget:filteredVideoView];
            }; break;
            case POSITION_THRESHOLDING:
            {
                [videoCamera addTarget:positionFilter];
                [positionFilter addTarget:filteredVideoView];
            }; break;
            case OBJECT_TRACKING:
            {
                [videoCamera addTarget:filteredVideoView];
                [videoCamera addTarget:positionFilter];
                //                [positionFilter addTarget:positionRawData]; // Enable this for CPU-based centroid computation
                [positionFilter addTarget:positionAverageColor]; // Enable this for GPU-based centroid computation
            }; break;
        }
    }    
}



#pragma mark -
#pragma mark Image processing

- (CGPoint)centroidFromTexture:(GLubyte *)pixels ofSize:(CGSize)textureSize;
{
    CGFloat currentXTotal = 0.0f, currentYTotal = 0.0f, currentPixelTotal = 0.0f;
    
    if ([GPUImageContext supportsFastTextureUpload])
    {
        for (NSUInteger currentPixel = 0; currentPixel < (textureSize.width * textureSize.height); currentPixel++)
        {
            currentXTotal += (CGFloat)pixels[(currentPixel * 4) + 2] / 255.0f;
            currentYTotal += (CGFloat)pixels[(currentPixel * 4) + 1] / 255.0f;
            currentPixelTotal += (CGFloat)pixels[(currentPixel * 4) + 3] / 255.0f;
        }
    }
    else
    {
        for (NSUInteger currentPixel = 0; currentPixel < (textureSize.width * textureSize.height); currentPixel++)
        {
            currentXTotal += (CGFloat)pixels[currentPixel * 4] / 255.0f;
            currentYTotal += (CGFloat)pixels[(currentPixel * 4) + 1] / 255.0f;
            currentPixelTotal += (CGFloat)pixels[(currentPixel * 4) + 3] / 255.0f;
        }
    }
    
    //    NSLog(@"CPU Average R: %f, G: %f, A: %f", currentXTotal / (textureSize.width * textureSize.height), currentYTotal / (textureSize.width * textureSize.height), currentPixelTotal / (textureSize.width * textureSize.height));
    
    return CGPointMake((1.0 - currentYTotal / currentPixelTotal), currentXTotal / currentPixelTotal);
}



#pragma mark -
#pragma mark Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    currentTouchPoint = [[touches anyObject] locationInView:self.view];
    shouldReplaceThresholdColor = YES;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];
    CGFloat distanceMoved = sqrt( (movedPoint.x - currentTouchPoint.x) * (movedPoint.x - currentTouchPoint.x) + (movedPoint.y - currentTouchPoint.y) * (movedPoint.y - currentTouchPoint.y) );
    
    thresholdSensitivity = distanceMoved / 160.0f;
    [[NSUserDefaults standardUserDefaults] setFloat:thresholdSensitivity forKey:@"thresholdSensitivity"];
    
    [thresholdFilter setFloat:thresholdSensitivity forUniformName:@"threshold"];
    [positionFilter setFloat:thresholdSensitivity forUniformName:@"threshold"];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}




@end
