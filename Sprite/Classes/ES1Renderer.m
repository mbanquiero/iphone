//
//  ES1Renderer.m
//  Sprite
//
//  Created by Ignacio Liverotti on 05/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "ES1Renderer.h"

@implementation ES1Renderer

// Create an OpenGL ES 1.1 context
- (id)init
{
    if ((self = [super init]))
    {
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];

        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }

        // Create default framebuffer object. The backing will be allocated for the current layer in -resizeFromLayer
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, colorRenderbuffer);
    }

    return self;
}

-(void)configureProjectionAndLoadTexture
{
	// This application only creates a single context which is already set current at this point.
    // This call is redundant, but needed if dealing with multiple contexts.
    [EAGLContext setCurrentContext:context];
	
    // This application only creates a single default framebuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple framebuffers.
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    glViewport(0, 0, backingWidth, backingHeight);
	
    glMatrixMode(GL_PROJECTION);
    
	glLoadIdentity();
	glRotatef(-90.0f, 0, 0, 1);
	glOrthof(-backingHeight/2, backingHeight/2, -backingWidth/2, backingWidth/2, -1, 1);
	
	static bool bTextureHasBeenLoaded = false;
	if(!bTextureHasBeenLoaded) {
		GLuint textureID;
		[self loadTextureImage:@"SpaceRocksAtlas.png" textureID:&textureID];
		bTextureHasBeenLoaded = true;
	}
}
 

- (void)render
{
    // Replace the implementation of this method to do your own custom drawing

    static const GLfloat squareVertices[] = {
		-100,-100,
		100,-100,
		-100,100,
		100,100
    };

    static const GLubyte squareColors[] = {
    /*
		255,   0,   0, 255,
        0,   255,   0, 255,
        0,     0, 255, 255,
        0,     0,   0, 255,
	 */
		255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
		
    };
	
	static const GLfloat uvCoordinates[] = {
		0,1,
		1,1,
		0,0,
		1,0,
		
	};	
	
	[self configureProjectionAndLoadTexture];

    static float transY = 0.0f;

    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glTranslatef( 240.0f*(GLfloat)(sinf(transY)/3.0f), 0.0f, 0.0f);
    transY += .05f;
	NSLog(@"transY: %.3f",(sinf(transY)/2.0f));

    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    
	glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
	
	glTexCoordPointer(2, GL_FLOAT, 0, uvCoordinates);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    // This application only creates a single color renderbuffer which is already bound at this point.
    // This call is redundant, but needed if dealing with multiple renderbuffers.
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
}

- (BOOL)resizeFromLayer:(CAEAGLLayer *)layer
{	
    // Allocate color buffer backing based on the current layer size
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);

    if (glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES)
    {
        NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }

    return YES;
}

- (void)dealloc
{
    // Tear down GL
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }

    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }

    // Tear down context
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];

    [context release];
    context = nil;

    [super dealloc];
}



// does the heavy lifting for getting a named image into a texture
// that is loaded into openGL
// this is a modified version of the way Apple loads textures in their sample code
-(CGSize)loadTextureImage:(NSString*)imageName textureID:(GLuint*)textureID
{
	CGContextRef spriteContext; //context ref for the UIImage
	GLubyte *spriteData; // a temporary buffer to hold our image data
	size_t	width, height;

	// grab the image off the file system, jam it into a CGImageRef
	
	UIImage*	uiImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageName ofType:nil]];
	CGImageRef spriteImage = [uiImage CGImage];
	// Get the width and height of the image
	width = CGImageGetWidth(spriteImage);
	height = CGImageGetHeight(spriteImage);
	
	CGSize imageSize = CGSizeMake(width, height);
	// Texture dimensions must be a power of 2. If you write an application that allows users to supply an image,
	// you'll want to add code that checks the dimensions and takes appropriate action if they are not a power of 2.
	
	if (spriteImage) {
		// Allocated memory needed for the bitmap context
		spriteData = (GLubyte *) malloc(width * height * 4);
		memset(spriteData, 0, (width * height * 4)); 
		// Uses the bitmatp creation function provided by the Core Graphics framework. 
		spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
		// After you create the context, you can draw the sprite image to the context.
		CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), spriteImage);
		// You don't need the context at this point, so you need to release it to avoid memory leaks.
		CGContextRelease(spriteContext);
		
		// Use OpenGL ES to generate a name for the texture.
		glGenTextures(1, textureID);
		// Bind the texture name. 
		glBindTexture(GL_TEXTURE_2D, *textureID);
		// Specidfy a 2D texture image, provideing the a pointer to the image data in memory
		
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);			
		
		free(spriteData);
		// Release the image data
		// Set the texture parameters to use a minifying filter and a linear filer (weighted average)
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		// Enable use of the texture
		glEnable(GL_TEXTURE_2D);
		// Set a blending function to use
		glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
		// Enable blending
		glEnable(GL_BLEND);
	} else {
		return CGSizeZero;
	}
	[uiImage release];
	
	return imageSize;
}

@end
