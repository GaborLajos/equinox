//
//  MockURLResolver.m
//  test
//
//  Created by Gabor Lajos Mate on 2026. 09. 21..
//

#include <Foundation/Foundation.h>
#include <CoreFoundation/CoreFoundation.h>
#include <dlfcn.h>

static CFStringRef (*original_CFStringCreateWithCString)(
    CFAllocatorRef allocator,
    const char *cStr,
    CFStringEncoding encoding
) = NULL;

int counterCFString = 0;
int counterCFURL = 0;

CFStringRef CFStringCreateWithCString(CFAllocatorRef allocator,
                                      const char *cStr,
                                      CFStringEncoding encoding)
{
    if (original_CFStringCreateWithCString == NULL) {
        original_CFStringCreateWithCString =
            dlsym(RTLD_NEXT, "CFStringCreateWithCString");
    }
  
    counterCFString++;

//    if (cStr && strcmp(cStr, "testNullString") == 0) {
//        return NULL;
//    }

    // Ha nem mockoljuk → hívjuk az eredetit
    return original_CFStringCreateWithCString(allocator, cStr, encoding);
}


static CFURLRef (*original_CFURLCreateWithFileSystemPath)(
    CFAllocatorRef allocator,
    CFStringRef string,
    CFURLPathStyle pathStyle,
    Boolean isDirectory
) = NULL;

CFURLRef CFURLCreateWithFileSystemPath(CFAllocatorRef allocator,
                                       CFStringRef str,
                                       CFURLPathStyle pathStyle,
                                       Boolean isDirectory)
{ 
    if (original_CFURLCreateWithFileSystemPath == NULL) {
        original_CFURLCreateWithFileSystemPath =
            dlsym(RTLD_NEXT, "CFURLCreateWithFileSystemPath");
    }

    if (CFEqual(str, CFSTR("testNullURL"))) {
        return NULL;
    }
    counterCFURL++;
    return original_CFURLCreateWithFileSystemPath(allocator, str, pathStyle, isDirectory);
}

static Boolean (*original_CFURLGetFileSystemRepresentation)(
    CFURLRef, Boolean, UInt8 *, CFIndex) = NULL;

Boolean CFURLGetFileSystemRepresentation(CFURLRef url,
                                         Boolean resolveAgainstBase,
                                         UInt8 *buffer,
                                         CFIndex maxBufLen)
{
    if (!original_CFURLGetFileSystemRepresentation) {
        original_CFURLGetFileSystemRepresentation =
            dlsym(RTLD_NEXT, "CFURLGetFileSystemRepresentation");
    }

    CFStringRef path = CFURLCopyFileSystemPath(url, kCFURLPOSIXPathStyle);
    Boolean equal = CFEqual(path, CFSTR("testFalse"));
    CFRelease(path);
    if (equal == true) {
      return false;
    }

    return original_CFURLGetFileSystemRepresentation(url,
                                                     resolveAgainstBase,
                                                     buffer,
                                                     maxBufLen);
}

static void (*original_CFRelease)(CFTypeRef cf) = NULL;

void CFRelease(CFTypeRef cf)
{
    if (original_CFRelease == NULL) {
        original_CFRelease = dlsym(RTLD_NEXT, "CFRelease");
    }

    CFTypeID type = CFGetTypeID(cf);

    if (type == CFStringGetTypeID()) {
              // CFString
      counterCFString--;
    } else if (type == CFURLGetTypeID()) {
      counterCFURL--;
    } else {
    
    }

    original_CFRelease(cf);
}


