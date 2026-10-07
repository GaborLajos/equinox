//
//  eclipseappTests.m
//  eclipseappTests
//
//  Created by Gabor Lajos Mate on 2026. 09. 23..
//

#import <XCTest/XCTest.h>
#include <jni.h>
#include "eclipseJNI.h"
#include "eclipseUnicode.h"
#include "MockDisplayMessage.h"

extern JNIEXPORT int run(int argc, _TCHAR* argv[], _TCHAR* vmArgs[]);

static _Thread_local int test_argc;

int initWindowSystem( int* argc, _TCHAR* argv[] ) {
  XCTAssertEqual(test_argc, *argc, "Invalid argc");
  return 0;
}
int showSplash( const _TCHAR* featureImage ) {
  return 0;
}
_TCHAR** getArgVM( _TCHAR *vm ) {
  return NULL;
}

/* Find the vm shared library associated with the given java executable */
_TCHAR * findVMLibrary( _TCHAR * command ) {
  return NULL;
}

void dispatchMessages() {
  
}

jlong getSplashHandle() {
  return 0;
}

void takeDownSplash() {
  
}

void restartLauncher( _TCHAR* program, _TCHAR* args[] ) {
  
}

/* launch the vm in a separate process and wait for it to finish */
JavaResults* launchJavaVM( _TCHAR* args[] ) {
  return NULL;
}

/* launch the vm in this process using JNI invocation */
JavaResults* startJavaVM( _TCHAR* libPath, _TCHAR* vmArgs[], _TCHAR* progArgs[], _TCHAR* jarFile ) {
  return NULL;
}

/* do any platform specific processing of the user vmargs */
void processVMArgs(_TCHAR **vmargs[] ) {
  return;
}

/* an array of paths that will need to be on the search path to load the vm shared library */
_TCHAR ** getVMLibrarySearchPath(_TCHAR * vmLibrary) {
  return NULL;
}

int reuseWorkbench(_TCHAR** filePath, int timeout) {
  return 0;
}

_TCHAR* getFolderForApplicationData() {
  return NULL;
}

_TCHAR* getProgramDir() {
  _TCHAR* temp;
  _TCHAR* result;
  temp = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  result = malloc( (_tcslen( temp ) + 1) * sizeof(_TCHAR) );
  _tcscpy( result, temp );
  return result;
}
_TCHAR* findFile( _TCHAR* path, _TCHAR* prefix) {
  _TCHAR* temp;
  _TCHAR* result;
  temp = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/startup.jar";
  result = malloc( (_tcslen( temp ) + 1) * sizeof(_TCHAR) );
  _tcscpy( result, temp );
  return result;
}


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

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
