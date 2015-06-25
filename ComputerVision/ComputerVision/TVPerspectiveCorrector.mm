//
//  TVPerspectiveCorrector.m
//  ComputerVision
//
//  Created by Patrick Sheehan on 6/23/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import "TVPerspectiveCorrector.h"

using namespace cv;
using namespace std;

@implementation TVPerspectiveCorrector

+ (void)startWarpCorrection:(UIImage *)image
                WithOptions:(NSDictionary *)options
                 Completion:(void (^)(UIImage *))callback {
    
    id cannyLowThresh = [options valueForKey:KEY_CANNY_LOW_THRESHOLD];
    id houghRho = [options valueForKey:KEY_HOUGH_RHO];
    id houghTheta = [options valueForKey:KEY_HOUGH_THETA];
    id houghIntThresh = [options valueForKey:KEY_HOUGH_INTERSECTION_THRESHOLD];
    id houghMinLineLen = [options valueForKey:KEY_HOUGH_MIN_LINE_LENGTH];
    id houghMaxLineGap = [options valueForKey:KEY_HOUGH_MAX_LINE_GAP];
    id onlyShowLines = [options valueForKey:KEY_ONLY_SHOW_LINES];
    
    Mat src = [TVUtility cvMatFromUIImage:image];
    
    // Convert to Grayscale
    cvtColor(src, src, CV_BGR2GRAY);
    
    // Apply blur
    blur(src);
    
    // Detect Canny Edges
    if (cannyLowThresh) {
        canny(src, [cannyLowThresh floatValue]);
    } else {
        NSLog(@"WHOOPS! No lower threshold provided for Canny edge detection");
        canny(src);
    }
    
    // Find lines with Hough transform
    vector<Vec4i> lines;
    if (houghRho && houghIntThresh && houghMinLineLen && houghMaxLineGap) {
        lines = hough(src, [houghRho floatValue], [houghTheta floatValue], [houghIntThresh floatValue], [houghMinLineLen intValue], [houghMaxLineGap intValue]);
    } else {
        NSLog(@"WHOOPS! Some parameters were missing for the Hough transform calculation");
        lines = hough(src);
    }
    
    // Draw the lines (temporary)


    if ([onlyShowLines boolValue]) {
        
        // Callback image only has the lines
        
        Mat linedMat = cv::Mat::zeros(src.rows, src.cols, CV_32FC1);
        drawLines(linedMat, lines);
        UIImage *linedImage = [TVUtility UIImageFromCVMat:linedMat];
        callback(linedImage);

    } else {
        
        // Callback image has everything
        
        drawLines(src, lines);
        UIImage *linedImage = [TVUtility UIImageFromCVMat:src];
        callback(linedImage);
    }
    
    
    
    return;
    
    
    
    
    vector<Point2f> corners = findCorners(lines);
    sortCorners(corners);
    
    warpImage(src, corners);
    
    UIImage *warpedImage = [TVUtility UIImageFromCVMat:src];
    callback(warpedImage);
    
}

void drawLines(Mat &src,
               vector<Vec4i> lines) {
    
    for (int i = 0; i < lines.size(); i ++) {
        
        Vec4i line = lines[i];
        int x1 = line[0];
        int y1 = line[1];
        
        int x2 = line[2];
        int y2 = line[3];
        
        Point2f p1(x1, y1);
        Point2f p2(x2, y2);
        Scalar color(102, 255, 200);
        
        cv::line(src, p1, p2, color, 5);
        
    }
    
}

void blur(Mat &src,
          BlurType blurType=Normal,
          cv::Size size=cv::Size(3, 3)) {
    
    // Apply a blur to an image
    
    switch (blurType) {
        case Normal:
            cv::blur(src, src, size);
            break;
        case Gaussian:
            cv::GaussianBlur(src, src, size, 0);
            break;
        case Median:
            cv::medianBlur(src, src, size.width);
            break;
        case Bilateral:
            break;
        default:
            break;
    }
}

void canny(Mat &src,
           float lowThreshold=50,
           float ratio=3,
           int kernelSize=3) {
    
    // Perform Canny edge detection on an image
    
    Canny(src, src, lowThreshold, lowThreshold * ratio, kernelSize);
    
}

vector<Vec4i> hough(Mat &src,
                    float rho=1,
                    float theta=CV_PI/180,
                    float threshold=80,
                    int minLineLength=40,
                    int maxLineGap=10,
                    bool probablistic=TRUE) {
    
    // Find lines in an image using the Hough Transform
    
    vector<Vec4i> lines;
    
    if (probablistic) {
        HoughLinesP(src, lines, rho, theta, threshold, minLineLength, maxLineGap);
    }
    else {
        HoughLines(src, lines, rho, theta, threshold);
    }
    
    return lines;
}

vector<Point2f> findCorners(vector<Vec4i> lines) {

    // Return the intersections of the lines
    
    std::vector<cv::Point2f> corners;
    for (int i = 0; i < lines.size(); i++)
    {
        for (int j = i+1; j < lines.size(); j++)
        {
            cv::Point2f pt = computeIntersect(lines[i], lines[j]);
            if (pt.x >= 0 && pt.y >= 0)
                corners.push_back(pt);
        }
    }
    
    return corners;
}

void sortCorners(vector<Point2f>& corners) {
    
    // Sort a list of corners to be in clockwise order:
    // (TopLeft, TopRight, BottomRight, BottomLeft)
    
    std::vector<cv::Point2f> top, bot;
    
    // Find the center of mass of the corners
    Point2f center(0,0);
    for (int i = 0; i < corners.size(); i++)
        center += corners[i];
    center *= (1. / corners.size());
    
    for (int i = 0; i < corners.size(); i++)
    {
        if (corners[i].y < center.y)
            top.push_back(corners[i]);
        else
            bot.push_back(corners[i]);
    }
    
    cv::Point2f tl = top[0].x > top[1].x ? top[1] : top[0];
    cv::Point2f tr = top[0].x > top[1].x ? top[0] : top[1];
    cv::Point2f bl = bot[0].x > bot[1].x ? bot[1] : bot[0];
    cv::Point2f br = bot[0].x > bot[1].x ? bot[0] : bot[1];
    
    corners.clear();
    corners.push_back(tl);
    corners.push_back(tr);
    corners.push_back(br);
    corners.push_back(bl);
}

void warpImage(Mat &src, vector<Point2f> corners) {
    
    // Apply a warp perspective to the image using the corners skewed corners of a quadrilateral

    // Corners of the destination image
    std::vector<Point2f> quad_pts;
    quad_pts.push_back(Point2f(0, 0));
    quad_pts.push_back(Point2f(src.cols, 0));
    quad_pts.push_back(Point2f(src.cols, src.rows));
    quad_pts.push_back(Point2f(0, src.rows));
    
    // Get transformation matrix
    cv::Mat transmtx = cv::getPerspectiveTransform(corners, quad_pts);
    
    // Apply perspective transformation
    cv::warpPerspective(src, src, transmtx, src.size());
}

#pragma mark - Helper Methods

Point2f computeIntersect(Vec4i a, Vec4i b) {
    
    // Return the intersection point of two lines
    
    int x1 = a[0], y1 = a[1], x2 = a[2], y2 = a[3];
    int x3 = b[0], y3 = b[1], x4 = b[2], y4 = b[3];
    
    if (float d = ((float)(x1-x2) * (y3-y4)) - ((y1-y2) * (x3-x4)))
    {
        Point2f pt;
        pt.x = ((x1*y2 - y1*x2) * (x3-x4) - (x1-x2) * (x3*y4 - y3*x4)) / d;
        pt.y = ((x1*y2 - y1*x2) * (y3-y4) - (y1-y2) * (x3*y4 - y3*x4)) / d;
        return pt;
    }
    else
        return Point2f(-1, -1);
}


@end
