# Integration Steps

## 1. Add Source File References
- Add all required source files (`.c`, `.h`) to the Xcode project as references.
- Ensure correct Target Membership.

## 2. Extend Preprocessor Macros
Add the following macros to **Build Settings → Preprocessor Macros**:

COCOA  
MACOSX  
DEFAULT_OS="\"macosx\""  
DEFAULT_OS_ARCH="\"x86_64\""  
DEFAULT_WS="\"cocoa\""

## 3. Configure Java Native Interface (JNI)

### 3.1 User-Defined Setting
JAVA_HOME = /Library/Java/JavaVirtualMachines/jdk-XX.jdk/Contents/Home

### 3.2 Header Search Paths
$(JAVA_HOME)/include  
$(JAVA_HOME)/include/darwin

### 3.3 Library Search Paths
$(JAVA_HOME)/lib/server

### 3.4 Runtime Search Paths
$(JAVA_HOME)/lib/server

### 3.5 Link JVM Dynamic Library
Add to **Link Binary With Libraries**:
libjvm.dylib

## 4. Enable Objective-C Compilation
Add compiler flag:
-x objective-c

## 5. Disable Automatic Reference Counting (ARC)
Objective-C Automatic Reference Counting = NO
