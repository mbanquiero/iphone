//
//  TileViewAppDelegate.h
//  TileView
//
//  Created by user on 19/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TileViewViewController;

@interface TileViewAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    TileViewViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet TileViewViewController *viewController;

@end

