//
//  TVBulletSeekerAlgorithimTest.m
//  ComputerVision
//
//  Created by Meshach Joshua on 6/5/15.
//  Copyright (c) 2015 Sheehan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "TVUtility.h"
#import "TVBulletSeekerAlgorithm.h"

@interface TVBulletSeekerAlgorithimTest : XCTestCase
{
    TVBullet* firstBullet;
    TVBullet* secondBullet;
    TVBullet* thirdBullet;
    TVBullet* fourthBullet;
    
    NSMutableArray *arrDenseBullets;
    
}
@end

@implementation TVBulletSeekerAlgorithimTest

- (void)setUp {
    [super setUp];
    
    arrDenseBullets = [NSMutableArray new];

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

-(void)testDensity {
    NSMutableArray *testArray = [TVBulletSeekerAlgorithm filterTVBulletsByDensity:arrDenseBullets];
    XCTAssertEqual(testArray.count, (NSUInteger)2, @"Array has wrong number of bullets, expected 0");
}



// Meshach TODO - write test for Density Calculation

// Patrick TODO - write test for Adjacency/flooding calculation

@end
