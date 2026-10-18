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


//extern JNIEXPORT int runPtr(int argc, _TCHAR* argv[], _TCHAR* vmArgs[]);

static pid_t (*orig_getpid)(void);
static int (*orig_setenv)(const char * __name, const char * __value, int __overwrite);

static _Thread_local int getpid_first;
static _Thread_local int setenv_first;

typedef struct {
  const char *programDir;
  const char *homeDir;
  const char *programName;
  const char *argumentFirstAfterDeletion;
  const char *argumentDeleted;
  const char *argumentVM;
  const char *argumentVMValue;
  const char *startupJar;
  pid_t fakePid;

  int getpidCalled;
  int setenvCalled;

  int argcExpected;
} MockState;

static _Thread_local MockState mockState;

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
  int result = 0;
  XCTAssertEqual(mockState.argcExpected, *argc, "Invalid argc");
  if (mockState.programName != NULL)
    XCTAssertEqual(strcmp(mockState.programName, argv[0]), 0, "Invalid program name");
  if (mockState.argumentFirstAfterDeletion != NULL && *argc > 1)
    XCTAssertEqual(strcmp(mockState.argumentFirstAfterDeletion, argv[1]), 0, "Invalid argument");
  if (mockState.homeDir != NULL) {
    result = chdir(mockState.homeDir);
  }
  return result;
}
int showSplash( const _TCHAR* featureImage ) {
  return 0;
}
_TCHAR** getArgVM( _TCHAR *vm ) {
  return NULL;
}

/* Find the vm shared library associated with the given java executable */
_TCHAR * findVMLibrary( _TCHAR * command ) {
  return "./jnilib.dylib";
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
  int argCmdFound = 0;
  for (int i=0; progArgs[i]!=NULL; i++) {
    if (strcmp(progArgs[i], "-launcher") == 0) {
      argCmdFound = 1;
      XCTAssertNotEqual(progArgs[i+1], NULL, "Missing -launcher VM argument value");
      if (mockState.programName != NULL) {
        XCTAssertEqual(strcmp(mockState.programName, progArgs[i+1]), 0, "Invalid -launcher VM argument value");
      }
      break;
    }
  }
  int argNameFound = 0;
  for (int i=0; progArgs[i]!=NULL; i++) {
    if (strcmp(progArgs[i], "-name") == 0) {
      argNameFound = 1;
      XCTAssertNotEqual(progArgs[i+1], NULL, "Missing -name VM argument value");
      if (mockState.argumentDeleted != NULL && strcmp(mockState.argumentDeleted, "-name") == 0) {
        if (mockState.argumentVMValue != NULL) {
          XCTAssertEqual(strcmp(mockState.argumentVMValue, progArgs[i+1]), 0, "Invalid -name VM argument value");
        } else {
          XCTFail("Incomplete unit test - missing argumentVMValue");
        }
      } else {
        if (mockState.programName != NULL) {
          char programNameCopy[1024];

          strncpy(programNameCopy, mockState.programName, sizeof(programNameCopy) - 1);
          programNameCopy[sizeof(programNameCopy) - 1] = '\0';

          if (programNameCopy[0] != '\0') {
              programNameCopy[0] = (char)toupper((unsigned char)programNameCopy[0]);
          }
          XCTAssertEqual(strcmp(programNameCopy, progArgs[i + 1]), 0,
                         @"Invalid -name VM argument value: %s vs %s",
                         programNameCopy,
                         progArgs[i + 1]);
        } else {
          XCTFail("Incomplete unit test - missing programName");
        }
      }
      break;
    }
  }
  XCTAssertEqual(argNameFound, 1, "Missing -name VM argument");
  if (mockState.argumentVM != NULL) {
    if (mockState.argumentDeleted != NULL && strcmp(mockState.argumentDeleted, "-nosplash") == 0) {
      for (int i=0; progArgs[i]!=NULL; i++) {
        XCTAssertNotEqual(strcmp(progArgs[i], "-showsplash"), 0, "Invalid Showsplash argument");
      }
    } else if (mockState.argumentDeleted != NULL && strcmp(mockState.argumentDeleted, "-os") == 0) {
      int argFound = 0;
      for (int i=0; progArgs[i]!=NULL; i++) {
        if (strcmp(progArgs[i], "-os") == 0 || strcmp(progArgs[i], "-ws") == 0) {
          argFound = 1;
          XCTAssertNotEqual(progArgs[i+1], NULL, "Missing VM argument value");
          XCTAssertEqual(strcmp(mockState.argumentVMValue, progArgs[i+1]), 0, "Invalid VM argument value");
        }
      }
      XCTAssertEqual(argFound, 1, "Missing VM argument");
    } else {
//      XCTAssertEqual(strcmp(mockState.argumentVM, progArgs[i]), 0, "Invalid VM argument");
    }
  }
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

_TCHAR* getProgramDir(void) {
//  _TCHAR* temp;
  const char *src = mockState.programDir;

  if (src == NULL)
    return NULL;

  _TCHAR *result =
      malloc((_tcslen(src) + 1) * sizeof(_TCHAR));

  _tcscpy(result, src);

  return result;
  //temp = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  //result = malloc( (_tcslen( temp ) + 1) * sizeof(_TCHAR) );
  //_tcscpy( result, temp );
  //return result;
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
typedef int (*run_fn)(int, char **, char **);

static void *launcherHandle;
static run_fn runPtr;

- (void)setUp
{
  NSString *testBundle =
      [[NSBundle bundleForClass:[self class]] bundlePath];

  int rc = chdir([testBundle fileSystemRepresentation]);

  NSLog(@"bundle=%@", testBundle);
  NSLog(@"chdir rc=%d", rc);
  NSLog(@"cwd=%@", [[NSFileManager defaultManager] currentDirectoryPath]);
  dlerror();
  launcherHandle = dlopen(
        "/../plugins/org.eclipse.equinox.launcher.cocoa.macosx.x86_64_11925.so/eclipse_11925.so",
        RTLD_LOCAL | RTLD_NOW );

    assert(launcherHandle != NULL);

    runPtr = (run_fn)dlsym(launcherHandle, "run");
  if (runPtr == NULL) {
    NSLog(@"error %s", dlerror());
  }

    assert(runPtr != nil);
  rebind_symbols((struct rebinding[2]) {
    {"getpid", my_getpid, &orig_getpid},
    {"setenv", my_setenv, &orig_setenv}
  }, 2);
  getpid_first = 1;
  setenv_first = 1;
  // Put setup code here. This method is called before the invocation of each test method in the class.
  memset(&mockState, 0, sizeof(mockState));
  NSLog(@"setUp: mockState=%p", &mockState);
}

- (void)tearDown
{
    dlclose(launcherHandle);

    runPtr = NULL;
    launcherHandle = NULL;
}

- (void)testNullInput {
  mockState.argcExpected = 1;
  mockState.programName = "eclipseTester";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  char* program = "eclipseTester";
  char** args;
  int exitcode;
  args = (char**) malloc((mockState.argcExpected + 1) * sizeof(char*));
  args[0] = program;
  args[1] = 0;
  exitcode = runPtr(mockState.argcExpected, args, NULL);
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

/*
 Arguments not recognised and supported by the app are simply ignored by
 parseArgs of the run.
 */
- (void)testUnknownArg {
  mockState.argcExpected = 2;
  mockState.programName = "eclipseTester";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "testArg";
  char* program = "eclipseTester";
  char* arg = "testArg";
  char** args;
  int exitcode;
  args = (char**) malloc((mockState.argcExpected + 1) * sizeof(char*));
  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  exitcode = runPtr(mockState.argcExpected, args, NULL);
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

/*
 Argument -console recognized, but not removed
 */
- (void)testConsoleArg {
  mockState.argcExpected = 2;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-console";
  char* program = "testProgram";
  char* arg = "-console";
  char** args;
  int exitcode;
  args = (char**) malloc((mockState.argcExpected + 1) * sizeof(char*));
  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  exitcode = runPtr(mockState.argcExpected, args, NULL);
  free(args);

  XCTAssertEqual(exitcode, -11);
}

/*
 Argument -consoleLog recognized, but not removed
 */
- (void)testConsoleLogArg {
  mockState.argcExpected = 2;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-consoleLog";
  char *program = "testProgram";
  char *arg = "-consoleLog";
  char **args = malloc((mockState.argcExpected + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg;
  args[2] = 0;
  
  exitcode = runPtr(mockState.argcExpected, args, NULL);
  
  free(args);
  
  XCTAssertEqual(exitcode, -11);
}

/*
 Argument -debug recognized, but not removed
 */
- (void)testDebugArg {
  mockState.argcExpected = 2;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-debug";
  char *program = "testProgram";
  char *arg = "-debug";
  char **args = malloc((mockState.argcExpected + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg;
  args[2] = 0;

  exitcode = runPtr(mockState.argcExpected, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}

/*
 Argument -nosplash recognized, and removed
 */
- (void)testNoSplashArg {
  mockState.argcExpected = 3;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";
  mockState.argumentDeleted = "-nosplash";
  mockState.argumentVM = "-showsplash";
  char *program = "testProgram";
  const char *arg = "-nosplash";
  const char *arg3 = "-unknown";
  char **args = malloc((mockState.argcExpected + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg;
  args[2] = arg3;
  args[3] = 0;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 1;
  exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}
/*
 Argument -noRestart recognized and removed
 */
- (void)testNoRestartArg {
    mockState.argcExpected = 3;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
    mockState.argumentFirstAfterDeletion = "-unknown";

    char *program = "testProgram";
    const char *arg1 = "--launcher.noRestart";
    const char *arg2 = "-unknown";

    char **args = malloc(4 * sizeof(char *));
    int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = NULL;

    exitcode = runPtr(mockState.argcExpected--, args, NULL);

    free(args);

    XCTAssertEqual(exitcode, -11);
}

/*
 Argument -os recognized, and removed with its value
 */
- (void)testOsArg {
  mockState.argcExpected = 4;
  mockState.programName = "eclipseTester";
  mockState.programDir =
          "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";
  mockState.argumentVM = "-os";
  mockState.argumentVMValue = "macosy";
  char *program = "eclipseTester";
  char *arg1 = "-os";
  char *arg2 = "macosy";
  char *arg3 = "-unknown";
  char **args = malloc((mockState.argcExpected + 1) * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = arg3;
  args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}

/*
 Argument -suppressErrors recognized and removed
 */
- (void)testSuppressErrorsArg {
  mockState.argcExpected = 3;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "--launcher.suppressErrors";
  const char *arg2 = "-unknown";

  char **args = malloc(4 * sizeof(char *));
  int exitcode;

  args[0] = program;
  args[1] = (char *)arg1;
  args[2] = (char *)arg2;
  args[3] = NULL;

  exitcode = runPtr(mockState.argcExpected--, args, NULL);

    free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument -appendVmargs recognized and removed
 */
- (void)testAppendVmargsArg {
  mockState.argcExpected = 3;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

    char *program = "testProgram";
    const char *arg1 = "--launcher.appendVmargs";
    const char *arg2 = "-unknown";

    char **args = malloc(4 * sizeof(char *));
    int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = NULL;

    exitcode = runPtr(mockState.argcExpected--, args, NULL);

    free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument -vm recognized with value and removed
 */
- (void)testVmArg {
  mockState.argcExpected = 4;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "-vm";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument --launcher.ini recognized with value and removed
 */
- (void)testIniArg {
  mockState.argcExpected = 4;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "--launcher.ini";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument -showsplash recognized w/o value and removed
 */
- (void)testShowSplashArgWithouValue {
  mockState.argcExpected = 3;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "-showsplash";
  const char *arg2 = "-unknown";

  char **args = malloc(4 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 1;
  exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}
/*
 Argument -showsplash recognized with value and removed
 */
- (void)testShowSplashArg {
  mockState.argcExpected = 4;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "-showsplash";
  const char *arg2 = "image.png";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}
/*
 Argument -startup recognized with value and removed
 */
- (void)testStartupArg {
  mockState.argcExpected = 4;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "-startup";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}
/*
 Argument -name recognized with value and removed
 */
- (void)testNameArg {
  mockState.argcExpected = 4;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";
  mockState.argumentVM = "-name";
  mockState.argumentVMValue = "CustomMacEclipse";
  char *program = "testProgram";
  char *arg1 = "-name";
  char *arg2 = "CustomMacEclipse";
  char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument --launcher.XXMaxPermSize recognized with value and removed
 */
- (void)testPermGenArg {
  mockState.argcExpected = 4;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "--launcher.XXMaxPermSize";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument --launcher.timeout recognized with value and removed
 */
- (void)testTimeoutArg {
  mockState.argcExpected = 4;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "--launcher.timeout";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument --launcher.defaultAction recognized with value and removed
 */
- (void)testDefaultActionArg {
  mockState.argcExpected = 4;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "--launcher.defaultAction";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument -ws recognized with value and removed
 */
- (void)testWsArg {
  mockState.argcExpected = 4;
  mockState.programName = "testProgram";
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";
  mockState.argumentVM = "-ws";
  mockState.argumentVMValue = "cocoa";
  char *program = "testProgram";
  char *arg1 = "-os";
  char *arg2 = "cocoa";
  char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
/*
 Argument --launcher.GTK_version recognized with value and removed
 */
- (void)testGTKVersionArg {
  mockState.argcExpected = 4;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char *program = "testProgram";
  const char *arg1 = "--launcher.GTK_version";
  const char *arg2 = "/usr/bin/java";
  const char *arg3 = "-unknown";

  char **args = malloc(5 * sizeof(char *));
  int exitcode;

    args[0] = program;
    args[1] = (char *)arg1;
    args[2] = (char *)arg2;
    args[3] = (char *)arg3;
    args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

    XCTAssertEqual(exitcode, -11);
}
- (void)testLibraryArg {
  mockState.argcExpected = 4;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  mockState.argumentFirstAfterDeletion = "-unknown";

  char** args = malloc(5 * sizeof(char *));
  args[0] = "testProgram";
  args[1] = "--launcher.library";
  args[2] = "/tmp/libeclipse.dylib";
  args[3] = "-unknown";
  args[4] = NULL;
  int argc = mockState.argcExpected;
  mockState.argcExpected-=2;
  int exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}

- (void)testProtectRootArg {
  int exitcode;
  mockState.argcExpected = 3;
  mockState.programDir = "/Users/mateg/Library/Developer/Xcode/DerivedData/equinox_test-chxgbidiyeywndduibulfpiqpalh/Build/Products/Debug/eclipse.app/Contents/MacOS/";
  char *program = "testProgram";
  char *arg1 = "-protect";
  char *arg2 = "root";
  char **args = malloc((mockState.argcExpected + 1) * sizeof(char *));

  args[0] = program;
  args[1] = arg1;
  args[2] = arg2;
  args[3] = 0;

  int argc = mockState.argcExpected;
  mockState.argcExpected -= 2;
  exitcode = runPtr(argc, args, NULL);

  free(args);

  XCTAssertEqual(exitcode, -11);
}
@end
