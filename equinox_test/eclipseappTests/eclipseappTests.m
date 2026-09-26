//
//  eclipseappTests.m
//  eclipseappTests
//
//  Created by Gabor Lajos Mate on 2026. 09. 23..
//

#import <XCTest/XCTest.h>
#include <jni.h>
#include "eclipseUnicode.h"

extern JNIEXPORT int run(int argc, _TCHAR* argv[], _TCHAR* vmArgs[]);

@interface eclipseappTests : XCTestCase

@end

@implementation eclipseappTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNullInput {
  char* program = "testProgram";
  char** args;
  args = (char**) malloc(sizeof(char*));
  args[0] = program;
  run(1, args, NULL);
  free(args);
//  XCTAssertEqual(input, result);
}

- (void)testExample {
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
