//
//  tetrisAppDelegate.h
//  tetris
//
//  Created by user on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class tetrisViewController;

@interface tetrisAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    tetrisViewController *viewController;
	
	id displayLink;
	CFTimeInterval lastFrameTime;	
}

-(void) gameLoop;


@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet tetrisViewController *viewController;

@end

