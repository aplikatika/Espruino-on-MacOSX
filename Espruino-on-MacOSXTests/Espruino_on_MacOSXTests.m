//
//  Espruino_on_MacOSXTests.m
//  Espruino-on-MacOSXTests
//
//  Created by Blaž Jugovic on 28/03/2015.
//  Copyright (c) 2015 Aplikatika. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>

@interface Espruino_on_MacOSXTests : XCTestCase

@end

@implementation Espruino_on_MacOSXTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
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

@end
