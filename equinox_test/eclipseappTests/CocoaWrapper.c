//
//  CocoaWrapper.c
//  eclipseappTests
//
//  Created by Gabor Lajos Mate on 2026. 09. 27..
//

#define main invalid_main

#define dispatchMessages orig_dispatchMessages
#define getSplashHandle orig_getSplashHandle
#define takeDownSplash orig_takeDownSplash
#define restartLauncher orig_restartLauncher
#define displayMessage orig_displayMessage
#define initWindowSystem orig_initWindowSystem
#define showSplash orig_showSplash
#define getArgVM orig_getArgVM
#define findVMLibrary orig_findVMLibrary
#define launchJavaVM orig_launchJavaVM
#define startJavaVM orig_startJavaVM
#define processVMArgs orig_processVMArgs
#define getVMLibrarySearchPath orig_getVMLibrarySearchPath
#define getFolderForApplicationData orig_getFolderForApplicationData
#define reuseWorkbench orig_reuseWorkbench

#include "eclipseCocoa.c"
