//
//  eclipseInvalidMainTest.m
//  eclipseappTests
//
//  Created by Gabor Lajos Mate on 2026. 09. 27..
//

#import <XCTest/XCTest.h>
#undef cocoa_main
extern int invalid_main( int argc, char* argv[] );

@interface EclipseInvalidMainTest : XCTestCase

@end

@implementation EclipseInvalidMainTest

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testInvalidMain {
  char* argv[3];
  argv[0] = "program";
  argv[1] = "arg";
  argv[2] = NULL;
  int result = invalid_main(3, argv);
  XCTAssertEqual(result, -1);
}

@end
