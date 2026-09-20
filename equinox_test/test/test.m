//
//  test.m
//  test
//
//  Created by Gabor Lajos Mate on 2026. 09. 20..
//

#import <XCTest/XCTest.h>
#import "eclipseCommon.h"

@interface test : XCTestCase

@end

@implementation test

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNullInput {
  char* input = NULL;
  char* result = resolveSymlinks(input);
  XCTAssertEqual(input, result);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
