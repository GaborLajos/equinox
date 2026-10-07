//
//  testParseArgs.m
//  test
//
//  Created by Gabor Lajos Mate on 2026. 09. 22..
//

#import <XCTest/XCTest.h>
#include <jni.h>
#include <stdlib.h>
#include <sys/types.h>
#include <execinfo.h>
#include <dlfcn.h>
#include <stdio.h>
#include "fishhook.h"
#include "eclipseUnicode.h"
#include "eclipseCommon.h"
#include "eclipseOS.h"


extern JNIEXPORT int run(int argc, _TCHAR* argv[], _TCHAR* vmArgs[]);

static pid_t (*orig_getpid)(void);
static int (*orig_setenv)(const char * __name, const char * __value, int __overwrite);

static _Thread_local int test_argc;
static _Thread_local int getpid_first;
static _Thread_local int setenv_first;

pid_t my_getpid(void)
{
  if (getpid_first) {
    void *caller = __builtin_return_address(0);
    
    Dl_info info;
    dladdr(caller, &info);
    if (strcmp(info.dli_sname, "run") == 0) {
      getpid_first = 0;
      return 110;
    } else {
      return orig_getpid();
    }
  } else {
    return orig_getpid();
  }
}

int my_setenv(const char * __name, const char * __value, int __overwrite) {
  if (setenv_first) {
    void *caller = __builtin_return_address(0);
    
    Dl_info info;
    dladdr(caller, &info);
    if (strcmp(info.dli_sname, "run") == 0) {
      setenv_first = 0;
      XCTAssertEqual(strcmp(__name, "JAVA_STARTED_ON_FIRST_THREAD_110"), 0, "Error when setting environment");
      XCTAssertEqual(strcmp(__value, "1"), 0, "Error when setting environment value");
      XCTAssertTrue(__overwrite, "Error when setting environment overwrite");
      return 0;
    } else {
      return orig_setenv(__name, __value, __overwrite);
    }
  } else {
    return orig_setenv(__name, __value, __overwrite);
  }
}
void displayMessage( _TCHAR* title, _TCHAR* message ) {
  
  
}

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


@interface ParseArgsTests : XCTestCase

@end

@implementation ParseArgsTests

- (void)setUp {
  rebind_symbols((struct rebinding[2]) {
    {"getpid", my_getpid, &orig_getpid},
    {"setenv", my_setenv, &orig_setenv}
  }, 2);
  getpid_first = 0;
  setenv_first = 0;
  test_argc = 0;
  // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testNullInput {
  test_argc = 1;
  char* program = "testProgram";
  char** args;
  int exitcode;
  args = (char**) malloc((test_argc + 1) * sizeof(char*));
  args[0] = program;
  args[1] = 0;
  exitcode = run(test_argc, args, NULL);
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testUnknownArg {
  test_argc = 2;
  char* program = "testProgram";
  char* arg = "testArg";
  char** args;
  int exitcode;
  args = (char**) malloc((test_argc + 1) * sizeof(char*));
  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  exitcode = run(test_argc, args, NULL);
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testConsoleArg {
  test_argc = 2;
  char* program = "testProgram";
  char* arg = "-console";
  char** args;
  int exitcode;
  args = (char**) malloc((test_argc + 1) * sizeof(char*));
  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  exitcode = run(test_argc, args, NULL);
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testConsoleLogArg {
  test_argc = 2;
  char *program = "testProgram";
  char *arg = "-consoleLog";
  char **args = malloc((test_argc + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  
  exitcode = run(test_argc, args, NULL);
  
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testDebugArg {
  test_argc = 2;
  char *program = "testProgram";
  char *arg = "-debug";
  char **args = malloc((test_argc + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  
  exitcode = run(test_argc, args, NULL);
  
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testNoSplashArg {
  test_argc = 2;
  char *program = "testProgram";
  char *arg = "-nosplash";
  char **args = malloc((test_argc + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  exitcode = run(test_argc--, args, NULL);
  
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testOsArg {
  test_argc = 4;
  char *program = "testProgram";
  char *arg1 = "-os";
  char *arg2 = "macosx";
  char **args = malloc((test_argc + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg2;
  args[4] = 0;
  int argc = test_argc;
  test_argc -= 2;
  exitcode = run(argc, args, NULL);
  
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

- (void)testProtectRootArg {
  int exitcode;
  test_argc = 3;
  char *program = "testProgram";
  char *arg1 = "-protect";
  char *arg2 = "root";
  char **args = malloc((test_argc + 1) * sizeof(char *));

  args[0] = program;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = 0;

  int argc = test_argc;
  test_argc -= 2;
  exitcode = run(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}
@end
