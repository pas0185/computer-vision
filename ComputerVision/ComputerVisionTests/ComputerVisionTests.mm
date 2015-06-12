//
//  ComputerVisionTests.mm
//  ComputerVisionTests
//
//  Created by Patrick Sheehan on 5/28/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TVUtility.h"
#import "TVBulletSeekerAlgorithm.h"

@interface ComputerVisionTests : XCTestCase
{
    TVBullet* firstBullet;
    TVBullet* secondBullet;
    TVBullet* thirdBullet;
    TVBullet* fourthBullet;
    
    NSMutableArray *arrDenseBullets;
    NSArray *testArray;
}
@end

@implementation ComputerVisionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - Tests with Actual Camera Footage

- (void)testRecognitionBetweenTwoFrames {
    
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString *dirStillWhiteFrames = [bundle pathForResource:@"Still-White-Frames" ofType:nil];
    NSArray *filesStillWhite = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirStillWhiteFrames error: nil];

    UIImage *img1, *img2;
    
    for (NSString *fileName in filesStillWhite) {
        
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", dirStillWhiteFrames, fileName];
        img2 = [UIImage imageNamed:filePath];
        
        if (img1 != nil) {
            // Process the difference
            cv::Mat diff = [TVUtility differenceMatrixFrom:img2 Minus:img1];
            NSMutableArray *bullets = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff];
            if (bullets.count > 0) {
                NSLog(@"Found %lu bullets in diff matrix between %@ and %@", bullets.count, img1, img2);
            }
        }
        
        // Assign img1 to be the old frame in the next iteration
        img1 = [img2 copy];
        
    }
    
}

#pragma mark - Tests for Density Calculation

- (void)testDensity {
    
    firstBullet = [TVBullet new];
    secondBullet = [TVBullet new];
    thirdBullet = [TVBullet new];
    fourthBullet = [TVBullet new];
    
    arrDenseBullets = [NSMutableArray new];
    testArray = [NSArray new];
    
    //bullet
    [firstBullet addToArray:CGPointMake(1, 2)];
    [firstBullet addToArray:CGPointMake(2, 1)];
    [firstBullet addToArray:CGPointMake(3, 2)];
    [firstBullet addToArray:CGPointMake(2, 2)];
    [firstBullet addToArray:CGPointMake(2, 3)];
    [arrDenseBullets addObject:firstBullet];
    
    //squigly line
    [secondBullet addToArray:CGPointMake(3, 5)];
    [secondBullet addToArray:CGPointMake(3, 6)];
    [secondBullet addToArray:CGPointMake(4, 4)];
    [secondBullet addToArray:CGPointMake(5, 3)];
    [secondBullet addToArray:CGPointMake(5, 4)];
    [secondBullet addToArray:CGPointMake(6, 2)];
    [arrDenseBullets addObject:secondBullet];
    
    //bullet
    [thirdBullet addToArray:CGPointMake(5, 3)];
    [thirdBullet addToArray:CGPointMake(5, 4)];
    [thirdBullet addToArray:CGPointMake(5, 5)];
    [thirdBullet addToArray:CGPointMake(5, 6)];
    [thirdBullet addToArray:CGPointMake(6, 4)];
    [thirdBullet addToArray:CGPointMake(6, 5)];
    [thirdBullet addToArray:CGPointMake(6, 6)];
    [arrDenseBullets addObject:thirdBullet];
    
    //squigly line
    [fourthBullet addToArray:CGPointMake(0, 7)];
    [fourthBullet addToArray:CGPointMake(1, 6)];
    [fourthBullet addToArray:CGPointMake(1, 5)];
    [fourthBullet addToArray:CGPointMake(1, 4)];
    [fourthBullet addToArray:CGPointMake(1, 3)];
    [fourthBullet addToArray:CGPointMake(2, 3)];
    [fourthBullet addToArray:CGPointMake(2, 4)];
    [fourthBullet addToArray:CGPointMake(3, 3)];
    [arrDenseBullets addObject:fourthBullet];

    
    
    testArray = [TVBulletSeekerAlgorithm filterTVBulletsByDensity:arrDenseBullets];
    XCTAssertEqual(testArray.count, (NSUInteger)2, @"Array has wrong number of bullets, expected 0");
}

#pragma mark - Tests for Adjacency/flooding calculation

- (void)testMuchSimpler {
    
    UIImage *img_target_0_bullets = [UIImage imageNamed:@"target-0-shots"];
    UIImage *img_target_1_bullet = [UIImage imageNamed:@"target-1-shot"];
    
    cv::Mat m0 = [TVBulletSeekerAlgorithm binaryMatrix:img_target_0_bullets];
    cv::Mat m1 = [TVBulletSeekerAlgorithm binaryMatrix:img_target_1_bullet];

    cv::Mat diff = m1 - m0;
    
//    
    
}
- (void)testAdjacencyCalculation {
    
    /* Five test cases identified below for the following changes to a target
     Note that that diff matrix identifies only marginal changes (frame to frame)
     eg. a target with 5 holes that is shot a 6th time should only register the 6th bullet
     
     (1) empty -> empty
     (2) empty -> 1 bullet
     (3) 1 bullet -> 1 bullet
     (4) 1 bullet -> 2 bullets
     (5) empty -> 2 bullets
     
     TODO - Possible edge/error cases that are not yet handled
     (6) n bullets -> n-1 bullets
     (7) ...
     
     */
    
    // Load example images
    
    UIImage *img_target_0_bullets = [UIImage imageNamed:@"target-0-shots"];
    UIImage *img_target_1_bullet = [UIImage imageNamed:@"target-1-shot"];
    UIImage *img_target_2_bullets = [UIImage imageNamed:@"target-2-shots"];
    UIImage *img_target_3_bullets = [UIImage imageNamed:@"target-3-shots"];
    
    
    // (1) empty -> empty
//    cv::Mat diff_matrix_0_to_0 = [TVUtility differenceMatrixFrom:img_target_0_bullets Minus:img_target_0_bullets];
//    NSMutableArray *arr1 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_0_to_0];
//    XCTAssertEqual(arr1.count, (NSUInteger)0, @"Array has wrong number of bullets, expected 0");
//    NSLog(@"Finished first check! :)");
    
    // (2) empty -> 1 bullet
    cv::Mat diff_matrix_0_to_1 = [TVUtility differenceMatrixFrom:img_target_1_bullet Minus:img_target_0_bullets];
    NSMutableArray *arr2 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_0_to_1];
    XCTAssertEqual(arr2.count, (NSUInteger)1, @"Array has wrong number of bullets, expected 1");
    NSLog(@"Finished second check! :)");
    
    // (3) 1 bullet -> 1 bullet
    cv::Mat diff_matrix_1_to_1 = [TVUtility differenceMatrixFrom:img_target_1_bullet Minus:img_target_1_bullet];
    NSMutableArray *arr3 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_1_to_1];
    XCTAssertEqual(arr3.count, (NSUInteger)0, @"Array has wrong number of bullets, expected 0");
    NSLog(@"Finished third check! :)");
    
    // (4) 1 bullet -> 2 bullets
    cv::Mat diff_matrix_1_to_2 = [TVUtility differenceMatrixFrom:img_target_2_bullets Minus:img_target_1_bullet];
    NSMutableArray *arr4 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_1_to_2];
    XCTAssertEqual(arr4.count, (NSUInteger)1, @"Array has wrong number of bullets, expected 1");
    NSLog(@"Finished fourth check! :)");
    
    // (5) empty -> 2 bullets
    cv::Mat diff_matrix_0_to_2 = [TVUtility differenceMatrixFrom:img_target_2_bullets Minus:img_target_0_bullets];
    NSMutableArray *arr5 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_0_to_2];
    XCTAssertEqual(arr5.count, (NSUInteger)2, @"Array has wrong number of bullets, expected 2");
    NSLog(@"Finished fifth check! :)");
    
}



@end
