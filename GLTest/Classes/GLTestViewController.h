//
//  GLTestViewController.h
//  GLTest
//
//  Created by user on 27/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define COMPUTE_USECS(a) (a).tv_sec * 1000000 + (a).tv_usec
#define MAX_VERTEX			100000
struct VERTEX
{
	GLfloat x;
	GLfloat y;
	GLfloat z;
	unsigned char r;
	unsigned char g;
	unsigned char b;
	unsigned char a;
	
	
	
};

void _F(float u,float v,float *f,float *g,float *h);

struct vect3
{
	float x;
	float y;
	float z;
};

struct vect3 *cross(struct vect3 *rta,struct vect3 *a,struct vect3 *b);
struct vect3 *normalize(struct vect3 *a);
struct vect3 *resta(struct vect3 *rta,struct vect3 *a,struct vect3 *b);
struct vect3 *suma(struct vect3 *rta,struct vect3 *a,struct vect3 *b);
float dot(struct vect3*a,struct vect3 *b);


void D3DXMatrixLookAtLH(GLfloat *m,struct vect3 *pEye,struct vect3 *pAt,struct vect3 *pUp);
void glPerspectiveFovLH(float fovy,float Aspect,float zn,float zf); 

extern struct vect3 LF;
extern struct vect3 LA;
extern struct vect3 UP;

@interface GLTestViewController : UIViewController
{
    EAGLContext *context;

    float elapsed_time;
	NSTimer *timer;
	long cur_time;
	
	struct VERTEX vb[MAX_VERTEX];
	int cant_v;

	struct VERTEX vb2[MAX_VERTEX];
	int cant_v2;

	
	int cant_frames;
	
	
}


- (void)createVertexBuffer;
- (void)drawFrame;


@end
