//
//  test.m
//  test
//
//  Created by Gabor Lajos Mate on 2026. 09. 20..
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "eclipseCommon.h"

extern int counterCFString;
extern int counterCFURL;

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
}

- (void)testCFURLCreateWithFileSystemPath {
  char* input = "testNullURL";
  char* result = resolveSymlinks(input);
  XCTAssertEqual(input, result);
  XCTAssertEqual(0, counterCFString);
  XCTAssertEqual(0, counterCFURL);
}

- (void)testCFURLGetFileSystemRepresentation {
  char* input = "testFalse";
  char* result = resolveSymlinks(input);
  XCTAssertTrue(result == 0);
  XCTAssertEqual(0, counterCFString);
}

- (void)testURLByResolvingAliasFileAtURL {
  id classMockURL = OCMClassMock([NSURL class]);
  NSError *error = nil;
  OCMStub([classMockURL URLByResolvingAliasFileAtURL:(NSURL *)nil options:NSURLBookmarkResolutionWithSecurityScope error:&error]).andReturn(nil);

  char* input = "testError";
  char* result = resolveSymlinks(input);
  XCTAssertTrue(result == nil);
}

- (void)testRelativePathWithAlias {
  char* input = "/private/tmp/testfile02";
  char* expected = "/private/tmp/testfile01";
  char* result = resolveSymlinks(input);
  XCTAssertTrue(strcmp(expected, result) == 0);
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

//- (void)testPerformanceExample {
    // This is an example of a performance test case.
//    [self measureBlock:^{
        // Put the code you want to measure the time of here.
//    }];
//}


@end
