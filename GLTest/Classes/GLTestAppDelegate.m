//
//  GLTestAppDelegate.m
//  GLTest
//
//  Created by user on 27/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GLTestAppDelegate.h"
#import "GLTestViewController.h"

@implementation GLTestAppDelegate

@synthesize window;
@synthesize viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self.window addSubview:self.viewController.view];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    //[self.viewController stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //[self.viewController startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //[self.viewController stopAnimation];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Handle any background procedures not related to animation here.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Handle any foreground procedures not related to animation here.
}

- (void)dealloc
{
    [viewController release];
    [window release];
    
    [super dealloc];
}

@end
