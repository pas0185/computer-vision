//
//  ComputerVisionTests.m
//  ComputerVisionTests
//
//  Created by Patrick Sheehan on 5/28/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TVUtility.h"
#import "TVBulletSeekerAlgorithm.h"

@interface ComputerVisionTests : XCTestCase
{
    UIImage *img_target_0_bullets;
    UIImage *img_target_1_bullet;
    UIImage *img_target_2_bullets;
    UIImage *img_target_3_bullets;
    
}
@end

@implementation ComputerVisionTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    // Load example images
    img_target_0_bullets = [UIImage imageNamed:@"target-0-shots"];
    img_target_1_bullet = [UIImage imageNamed:@"target-1-shot"];
    img_target_2_bullets = [UIImage imageNamed:@"target-2-shots"];
    img_target_3_bullets = [UIImage imageNamed:@"target-3-shots"];
    
    // Convert images to matrices
    //cv::Mat matrix_empty_target = [TVUtility cvMatFromUIImage:img_target_empty];
    //cv::Mat matrix_one_bullet = [TVUtility cvMatFromUIImage:img_target_one_bullet];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

#pragma mark - Meshach TODO - Test for Density Calculation

#pragma mark - Patrick TODO - Test for Adjacency/flooding calculation

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
    
    
    // (1) empty -> empty
    cv::Mat diff_matrix_0_to_0 = [TVUtility differenceMatrixFrom:img_target_0_bullets Minus:img_target_0_bullets];
    NSArray *arr1 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_0_to_0];
    XCTAssertEqual(arr1.count, (NSUInteger)0, @"Array has wrong number of bullets, expected 0");
    
    // (2) empty -> 1 bullet
    cv::Mat diff_matrix_0_to_1 = [TVUtility differenceMatrixFrom:img_target_1_bullet Minus:img_target_0_bullets];
    NSArray *arr2 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_0_to_1];
    XCTAssertEqual(arr2.count, (NSUInteger)1, @"Array has wrong number of bullets, expected 1");
    
    // (3) 1 bullet -> 1 bullet
    cv::Mat diff_matrix_1_to_1 = [TVUtility differenceMatrixFrom:img_target_1_bullet Minus:img_target_1_bullet];
    NSArray *arr3 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_1_to_1];
    XCTAssertEqual(arr3.count, (NSUInteger)0, @"Array has wrong number of bullets, expected 0");
    
    // (4) 1 bullet -> 2 bullets
    cv::Mat diff_matrix_1_to_2 = [TVUtility differenceMatrixFrom:img_target_2_bullets Minus:img_target_1_bullet];
    NSArray *arr4 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_1_to_2];
    XCTAssertEqual(arr4.count, (NSUInteger)1, @"Array has wrong number of bullets, expected 1");

    // (5) empty -> 2 bullets
    cv::Mat diff_matrix_0_to_2 = [TVUtility differenceMatrixFrom:img_target_2_bullets Minus:img_target_0_bullets];
    NSArray *arr5 = [TVBulletSeekerAlgorithm getTVBulletCandidatesFromDiffMatrix:diff_matrix_0_to_2];
    XCTAssertEqual(arr5.count, (NSUInteger)2, @"Array has wrong number of bullets, expected 2");
    
}

@end
