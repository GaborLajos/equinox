//
//  testParseArgs.m
//  test
//
//  Created by Gabor Lajos Mate on 2026. 09. 22..
//

#import <XCTest/XCTest.h>
#include <jni.h>
#include "eclipseUnicode.h"

extern JNIEXPORT int run(int argc, _TCHAR* argv[], _TCHAR* vmArgs[]);

@interface testParseArgs : XCTestCase

@end

@implementation testParseArgs

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

@end
