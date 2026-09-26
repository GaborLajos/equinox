//
//  AppDelegate.h
//  eclipseapp
//
//  Created by Gabor Lajos Mate on 2026. 09. 23..
//

#import <Cocoa/Cocoa.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;


@end

