//
//  SpriteAppDelegate.m
//  Sprite
//
//  Created by Ignacio Liverotti on 05/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "SpriteAppDelegate.h"
#import "EAGLView.h"

@implementation SpriteAppDelegate

@synthesize window;
@synthesize glView;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [glView startAnimation];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [glView startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [glView stopAnimation];
}

- (void)dealloc
{
    [window release];
    [glView release];

    [super dealloc];
}

@end
