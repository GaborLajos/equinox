//
//  ResolveSymlinksTests.m
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <CoreFoundation/CoreFoundation.h>
#import "fishhook.h"
#import "eclipseCommon.h"

static _Thread_local int counterCFString;
static _Thread_local int counterCFURL;
static void (*orig_CFRelease)(CFTypeRef cf);
static CFURLRef (*orig_CFURLCreateWithFileSystemPath)(
    CFAllocatorRef allocator,
    CFStringRef string,
    CFURLPathStyle pathStyle,
    Boolean isDirectory
);
static Boolean (*orig_CFURLGetFileSystemRepresentation)(CFURLRef, Boolean, UInt8 *, CFIndex);
static CFStringRef (*orig_CFStringCreateWithCString)(
    CFAllocatorRef allocator,
    const char *cStr,
    CFStringEncoding encoding
);

#pragma mark - Original allocator


static CFAllocatorRef getOrigAllocator(void)
{
    static CFAllocatorRef gOriginalAllocator = NULL;
    if (!gOriginalAllocator) {
        gOriginalAllocator = CFAllocatorGetDefault();
    }
    return gOriginalAllocator;
}

#pragma mark - Custom allocator callbacks

static void *my_allocate(CFIndex size,
                         CFOptionFlags hint,
                         void *info)
{
    counterCFString++;

    return CFAllocatorAllocate(
        getOrigAllocator(),
        size,
        hint);
}

static void *my_reallocate(void *ptr,
                           CFIndex newsize,
                           CFOptionFlags hint,
                           void *info)
{
    return CFAllocatorReallocate(
        getOrigAllocator(),
        ptr,
        newsize,
        hint);
}

static void my_deallocate(void *ptr,
                          void *info)
{
    counterCFString--;

    CFAllocatorDeallocate(
        getOrigAllocator(),
        ptr);
}

static void my_release(const void *info)
{
    if (info) {
        free((void *)info);
    }
}

#pragma mark - Test allocator

static CFAllocatorRef myAllocator(void)
{
    static CFAllocatorRef allocator = NULL;

    if (!allocator) {

        CFAllocatorContext context = {
            .version = 0,
            .info = malloc(sizeof(int)),
            .retain = NULL,
            .release = my_release,
            .copyDescription = NULL,
            .allocate = my_allocate,
            .reallocate = my_reallocate,
            .deallocate = my_deallocate,
            .preferredSize = NULL
        };

        allocator = CFAllocatorCreate(NULL, &context);
    }

    return allocator;
}

void my_CFRelease(CFTypeRef cf)
{

    if (cf == CFStringGetTypeID()) {
              // CFString
      counterCFString--;
    } else if (cf == CFURLGetTypeID()) {
      counterCFURL--;
    } else {
    
    }
  XCTAssertNotNil(cf);
  if (cf != nil) {
    orig_CFRelease(cf);
  }
}

CFStringRef my_CFStringCreateWithCString(CFAllocatorRef allocator,
                                      const char *cStr,
                                      CFStringEncoding encoding)
{

    if (cStr && strcmp(cStr, "testNullString") == 0) {
        return NULL;
    }
  counterCFString++;

    return orig_CFStringCreateWithCString(allocator, cStr, encoding);
}

CFURLRef my_CFURLCreateWithFileSystemPath(CFAllocatorRef allocator,
                                       CFStringRef str,
                                       CFURLPathStyle pathStyle,
                                       Boolean isDirectory)
{
  XCTAssertNotNil(str);
    if (str == NULL || (str && CFEqual(str, CFSTR("testNullURL")))) {
        return NULL;
    }
    counterCFURL++;
    return orig_CFURLCreateWithFileSystemPath(allocator, str, pathStyle, isDirectory);
}

Boolean my_CFURLGetFileSystemRepresentation(CFURLRef url,
                                         Boolean resolveAgainstBase,
                                         UInt8 *buffer,
                                         CFIndex maxBufLen)
{
    CFStringRef path = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    Boolean equal = CFEqual(path, CFSTR("testFalse"));
    CFRelease(path);
    if (equal == true) {
      return false;
    }

    return orig_CFURLGetFileSystemRepresentation(url,
                                                     resolveAgainstBase,
                                                     buffer,
                                                     maxBufLen);
}


#pragma mark - Tests

@interface ResolveSymlinksTests : XCTestCase
@end

@implementation ResolveSymlinksTests

- (void)setUp
{
    [super setUp];

    counterCFString = 0;
    counterCFURL = 0;

    getOrigAllocator();

    CFAllocatorSetDefault(myAllocator());
  rebind_symbols((struct rebinding[5]) {
    {"CFURLGetFileSystemRepresentation", my_CFURLGetFileSystemRepresentation, &orig_CFURLGetFileSystemRepresentation},
    {"CFURLCreateWithFileSystemPath", my_CFURLCreateWithFileSystemPath, &orig_CFURLCreateWithFileSystemPath},
    {"CFStringCreateWithCString", my_CFStringCreateWithCString, &orig_CFStringCreateWithCString},
    {"CFURLCreateWithFileSystemPath", my_CFURLCreateWithFileSystemPath, &orig_CFURLCreateWithFileSystemPath},
    {"CFRelease", my_CFRelease, &orig_CFRelease}
  }, 5);
}

- (void)tearDown
{
  rebind_symbols((struct rebinding[5]) {
    {"CFURLGetFileSystemRepresentation", orig_CFURLGetFileSystemRepresentation, NULL},
    {"CFURLCreateWithFileSystemPath", orig_CFURLCreateWithFileSystemPath, NULL},
    {"CFStringCreateWithCString", orig_CFStringCreateWithCString, NULL},
    {"CFURLCreateWithFileSystemPath", orig_CFURLCreateWithFileSystemPath, NULL},
    {"CFRelease", orig_CFRelease, NULL}
  }, 5);

  CFAllocatorSetDefault(getOrigAllocator());

    [super tearDown];
}

- (void)testNullInput
{
    char *input = NULL;

    char *result = resolveSymlinks(input);

    XCTAssertEqual(input, result);
}

- (void)testNullString
{
    char *input = "testNullString";

    char *result = resolveSymlinks(input);

    XCTAssertEqual(input, result);
    XCTAssertEqual(0, counterCFString);
    XCTAssertEqual(0, counterCFURL);
}

- (void)testCFURLCreateWithFileSystemPath
{
    char *input = "testNullURL";

    char *result = resolveSymlinks(input);

    XCTAssertEqual(input, result);
    XCTAssertEqual(0, counterCFString);
    XCTAssertEqual(0, counterCFURL);
}

- (void)testCFURLGetFileSystemRepresentation
{
    char *input = "testFalse";

    char *result = resolveSymlinks(input);

    XCTAssertTrue((__bridge id)result == NULL);
    XCTAssertEqual(0, counterCFString);
}

- (void)testURLByResolvingAliasFileAtURL
{
    id classMockURL = OCMClassMock([NSURL class]);

    NSError *error = nil;

    OCMStub(
        [classMockURL URLByResolvingAliasFileAtURL:nil
                                           options:NSURLBookmarkResolutionWithSecurityScope
                                             error:&error]
    ).andReturn(nil);

    char *input = "testError";

    char *result = resolveSymlinks(input);

    XCTAssertTrue(result == NULL);

    [classMockURL stopMocking];
}

- (void)testRelativePathWithAlias
{
    char *input = "/private/tmp/testfile02";
    char *expected = "/private/tmp/testfile01";

    char *result = resolveSymlinks(input);

    XCTAssertTrue(result != NULL);
    XCTAssertEqual(0, strcmp(expected, result));
}

@end
