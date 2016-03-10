//
//  GLTestAppDelegate.h
//  GLTest
//
//  Created by user on 27/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GLTestViewController;

@interface GLTestAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    GLTestViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet GLTestViewController *viewController;

@end

