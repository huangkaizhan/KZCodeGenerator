//
//  AppDelegate.m
//  CodeGenerator
//
//  Created by huangkaizhan on 2017/12/4.
//  Copyright © 2017年 huangkaizhan. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication
                    hasVisibleWindows:(BOOL)flag{
    if (!flag){
        [NSApp activateIgnoringOtherApps:NO];
        [theApplication.windows.firstObject makeKeyAndOrderFront:self];
    }
    return YES;
}

@end
