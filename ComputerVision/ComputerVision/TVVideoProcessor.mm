//
//  TVVideoProcessor.mm
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/11/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVVideoProcessor.h"

using namespace cv;

@interface TVVideoProcessor()
{
    GPUImagePicture *myImageTemplate;
}
@end

@implementation TVVideoProcessor

#pragma mark - 
#pragma mark - Singleton Configuration

+ (id)sharedInstance {
    static TVVideoProcessor *sharedMyInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyInstance = [[self alloc] init];
    });
    return sharedMyInstance;
}

- (id)init {
    if (self = [super init]) {

        // Initialize default properties here
    }
    return self;
}

#pragma mark -
#pragma mark - Public Methods

- (void)setTemplateImage:(UIImage *)image {
    
    myImageTemplate = [[GPUImagePicture alloc] initWithImage:image];
}

- (void)setTemplateImages:(NSArray *)images {
    
    // TODO: iterate through images to find the 'average template'
}

- (void)findTVBulletsWithImage:(UIImage *)image
                    Completion:(void (^)(NSArray *))callback {

    UIImage *subtractedImage = [self performGPUImageProcessing:image];
    
    Mat canny = [self getCannyMatrix:subtractedImage];


    TVBulletSpace *bulletSpace = [[TVBulletSpace alloc] initWithCannyOutput:canny];

    NSArray *bullets = [bulletSpace getBullets];
    
    callback(bullets);
}

#pragma mark -
#pragma mark - GPUImage Processing

- (UIImage *)performGPUImageProcessing:(UIImage *)image {
    
    GPUImagePicture *templateImage = [self averageTemplate];
    
    if (templateImage == nil) {
        NSLog(@"ERROR: Could not get the average template GPUImagePicture");
        
        return image;
    }
    
    // Apply Difference Blend Filter to cancel out template image
    GPUImagePicture *gpuImage = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageDifferenceBlendFilter *diffFilter = [[GPUImageDifferenceBlendFilter alloc] init];
    
    // Add both pictures to the Difference Blend Filter
    [templateImage addTarget:diffFilter];
    [gpuImage addTarget:diffFilter];
    
    // Capture the next frame
    [diffFilter useNextFrameForImageCapture];
    
    // Process the images
    [templateImage processImage];
    [gpuImage processImage];
    
    
    return [diffFilter imageFromCurrentFramebuffer];
    
    
    // TODO: remove this one? It seems to be taken care of in OpenCV Canny function
//    GPUImageGaussianBlurFilter *gaussFilter = [[GPUImageGaussianBlurFilter alloc] init];
//    [diffFilter addTarget:gaussFilter];
//    [gaussFilter useNextFrameForImageCapture];
//    [templateImage processImage];
//    [gpuImage processImage];
//    
//    
//    return [gaussFilter imageFromCurrentFramebuffer];
    
}

#pragma mark -
#pragma mark - OpenCV Image Processing

- (cv::Mat)getCannyMatrix:(UIImage *)image {
    
    cv::Mat srcGray;
    int thresh = 20;
    RNG rng(12345);
    cv::Mat src = [TVUtility cvMatFromUIImage:image];
    
    /// Convert image to gray and blur it
    cvtColor(src, srcGray, CV_BGR2GRAY );
    
    /// Detect edges using canny
    Mat cannyOutput;
    cv::Canny(srcGray, cannyOutput, thresh, thresh * 2, 3);
    
    return cannyOutput;
}

#pragma mark -
#pragma mark - Lazy Loaded Properties

- (GPUImagePicture *)averageTemplate {
    
    if (myImageTemplate == nil) {
        
        // Initialize it
        UIImage *templateImage = [UIImage imageNamed:@"target-0-shots"];
        myImageTemplate = [[GPUImagePicture alloc] initWithImage:templateImage];
    }
    
    return myImageTemplate;
}


#pragma mark -
#pragma mark - Trash ??

- (UIImage *)imageWithContoursFrom:(UIImage *)image {
    
    cv::Mat src_gray;
    int thresh = 20;
    RNG rng(12345);
    cv::Mat src = [TVUtility cvMatFromUIImage:image];

    /// Convert image to gray and blur it
    cvtColor( src, src_gray, CV_BGR2GRAY );
    blur( src_gray, src_gray, cv::Size(3,3) );

    Mat canny_output;
    std::vector<std::vector<cv::Point> > contours;
    std::vector<Vec4i> hierarchy;

    /// Detect edges using canny
    cv::Canny( src_gray, canny_output, thresh, thresh * 2, 3 );
    /// Find contours
    findContours( canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
    
    /// Draw contours
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    for( int i = 0; i < contours.size(); i++ )
    {
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }


    return [TVUtility UIImageFromCVMat:drawing];

}

//- (std::vector<std::vector<cv::Point> >)getContoursFromImage:(UIImage *)image {
- (NSArray *)getContoursFromImage:(UIImage *)image {
    
//    TVBulletSpace *bulletSpace = [[TVBulletSpace alloc] initWithCannyOutput:cannyOutput];
    
    
    return nil;
    
    
    // *********** //
    
    
    
//    std::vector<Contour> contours;
//    std::vector<Vec4i> hierarchy;
//    
//    
//    
//    
//    /// Find contours
//    findContours( canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cv::Point(0, 0) );
//    
//    
//    int cannyImageRows = canny_output.rows;
//    int cannyImageCols = canny_output.cols;
//    NSLog(@"Canny image - (%d rows, %d cols)", cannyImageRows, cannyImageCols);
//    
//    
//    NSMutableArray *arrBullets = [[NSMutableArray alloc] initWithCapacity:contours.size()];
//    
//    /// Get the moments
//    vector<Moments> mu(contours.size() );
//    for( int i = 0; i < contours.size(); i++ ){
//        mu[i] = moments( contours[i], false );
//    }
//    
//    ///  Get the mass centers:
//    vector<Point2f> mc( contours.size() );
//    for( int i = 0; i < contours.size(); i++ ) {
//        
//        Point2f center = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 );
//        
//        NSLog(@"Contour center point - (%.2f, %.2f)", center.x
//              , center.y);
//        
//        mc[i] = center;
//        
//        Point2f percentCenter = Point2f(center.x / cannyImageCols, center.y / cannyImageRows);
//        TVBullet *bullet = [[TVBullet alloc] initWithCenterPoint:percentCenter];
//        bullet.vecPoints = contours[i];
//        [arrBullets addObject:bullet];
//    }
//    
//    return arrBullets;
}

@end
