//
//  ESRenderer.h
//  Sprite
//
//  Created by Ignacio Liverotti on 05/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>

@protocol ESRenderer <NSObject>

- (void)render;
- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer;

@end
