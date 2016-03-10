//
//  EAGLView.h
//  TileView
//
//  Created by user on 19/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>


// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView subclass.
// The view content is basically an EAGL surface you render your OpenGL scene into.
// Note that setting the view non-opaque will only work if the EAGL surface has an alpha channel.
@interface EAGLView : UIView
{
@private
    EAGLContext *context;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer;
	
	CGPoint pos,posant;
	int pos_y;
	int pos_x;
	bool touching;
	int touch_x;
	int touch_y;

	
	
}

@property (nonatomic, retain) EAGLContext *context;
@property int pos_x;
@property int pos_y;
@property bool touching;
@property int touch_x;
@property int touch_y;

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
