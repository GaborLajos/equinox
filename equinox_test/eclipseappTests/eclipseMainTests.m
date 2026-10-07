//
//  eclipseMainTests.m
//  eclipseappTests
//
//  Created by Gabor Lajos Mate on 2026. 09. 27..
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#include <string.h>
#include "MockDisplayMessage.h"
#include "eclipseOS.h"

static FILE log_file = {  };

extern int cocoa_main(int argc, char* argv[]);
extern int original_main(int argc, char* argv[]) {
  return 0;
}

FILE  *fopen(const char * __restrict __filename, const char * __restrict __mode) {
  XCTAssertTrue(strcmp(__filename, "/dev/console") == 0, "Expected filename:/dev/console");
  XCTAssertTrue(strcmp(__mode, "w") == 0, "Expected: write mode");
 return NULL;
}

pid_t getpid(void) {
  pid_t pid;
  pid = 100;
  return pid;
}

int   fprintf(FILE * __restrict __filename, const char * __restrict __format, ...) {
  XCTAssertTrue(__filename == NULL, "Filename NULL expected");
  if (strcmp(__format, "start") == 0) {

  } else if (strcmp(__format, "%05d: ") == 0) {
  } else if (strcmp(__format, "%") == 0) {
  } else if (strcmp(__format, " <%s>") == 0) {
  } else if (strcmp(__format, "\n") == 0) {
  } else if (strcmp(__format, "no Eclipse dict found\n") == 0) {
    
  } else {
    XCTFail("Unexpected output: %s", __format);
  }
  return 0;
}

int   vfprintf(FILE * __restrict __filename, const char * __restrict __format, va_list _v) {
  XCTAssertTrue(__filename == NULL, "Filename NULL expected");
  return 0;
}

@interface EclipseMainInvalidVersionTests : XCTestCase

@end

@interface DummyNSProcessInfo : NSProcessInfo
{
@private
    NSInteger _majorVersion;
    NSInteger _minorVersion;
    NSInteger _patchVersion;
}

- (instancetype)initWithMajorVersion:(NSInteger)majorVersion
                        minorVersion:(NSInteger)minorVersion
                        patchVersion:(NSInteger)patchVersion;

- (NSOperatingSystemVersion) operatingSystemVersion;

@end

@implementation DummyNSProcessInfo
- (instancetype)initWithMajorVersion:(NSInteger)majorVersion minorVersion:(NSInteger)minorVersion patchVersion:(NSInteger)patchVersion {
  self = [super init];
  if (self) {
    _majorVersion = majorVersion;
    _minorVersion = minorVersion;
    _patchVersion = patchVersion;
  }
  return self;
}
- (NSOperatingSystemVersion) operatingSystemVersion {
  NSOperatingSystemVersion dummyVersion;
  dummyVersion.majorVersion = _majorVersion;
  dummyVersion.minorVersion = _minorVersion;
  dummyVersion.patchVersion = _patchVersion;
  return dummyVersion;
}

@end

@implementation EclipseMainInvalidVersionTests

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testCocoaMainInvalidMajorVersion {
  NSProcessInfo *dummyProcessInfo = [[DummyNSProcessInfo alloc]initWithMajorVersion:9 minorVersion:10 patchVersion:0];
  id processInfoMock = OCMClassMock([NSProcessInfo class]);
  OCMStub([processInfoMock processInfo]).andReturn(dummyProcessInfo);
  
  char* argv[3];
  argv[0] = "program";
  argv[1] = "arg";
  argv[2] = NULL;
  int result = cocoa_main(3, argv);
  XCTAssertEqual(result, 0);
}
- (void)testCocoaMainInvalidMinorVersion {
  NSProcessInfo *dummyProcessInfo = [[DummyNSProcessInfo alloc]initWithMajorVersion:10 minorVersion:9 patchVersion:0];
  id processInfoMock = OCMClassMock([NSProcessInfo class]);
  OCMStub([processInfoMock processInfo]).andReturn(dummyProcessInfo);
  
  char* argv[3];
  argv[0] = "program";
  argv[1] = "arg";
  argv[2] = NULL;
  int result = cocoa_main(3, argv);
  XCTAssertEqual(result, 0);
}

- (void)testCocoaMainWithoutArgs {
  NSProcessInfo *dummyProcessInfo = [[DummyNSProcessInfo alloc]initWithMajorVersion:10 minorVersion:10 patchVersion:0];
  id processInfoMock = OCMClassMock([NSProcessInfo class]);
  OCMStub([processInfoMock processInfo]).andReturn(dummyProcessInfo);
  
  char* argv[1];
  argv[0] = "program";
  int result = cocoa_main(1, argv);
  XCTAssertEqual(result, 0);
}

- (void)testCocoaMainWithoutArgsAsApp {
  NSProcessInfo *dummyProcessInfo = [[DummyNSProcessInfo alloc]initWithMajorVersion:10 minorVersion:10 patchVersion:0];
  id processInfoMock = OCMClassMock([NSProcessInfo class]);
  OCMStub([processInfoMock processInfo]).andReturn(dummyProcessInfo);
  
  char* argv[1];
  argv[0] = "program.app/Contents/MacOS/eclipse";
  int result = cocoa_main(1, argv);
  XCTAssertEqual(result, 0);
}

- (void)testCocoaMainWithUnknownArgs {
  NSProcessInfo *dummyProcessInfo = [[DummyNSProcessInfo alloc]initWithMajorVersion:10 minorVersion:10 patchVersion:0];
  id processInfoMock = OCMClassMock([NSProcessInfo class]);
  OCMStub([processInfoMock processInfo]).andReturn(dummyProcessInfo);
  
  char* argv[2];
  argv[0] = "program";
  argv[1] = "arg_test1";
  int result = cocoa_main(1, argv);
  XCTAssertEqual(result, 0);
}

@end
