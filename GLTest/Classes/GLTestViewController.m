//
//  GLTestViewController.m
//  GLTest
//
//  Created by user on 27/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "GLTestViewController.h"
#import "EAGLView.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};


struct vect3 LF;
struct vect3 LA;
struct vect3 UP;


@interface GLTestViewController ()
@property (nonatomic, retain) EAGLContext *context;

@end

@implementation GLTestViewController

@synthesize context;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
    [(EAGLView *)self.view setContext:context];
    [(EAGLView *)self.view setFramebuffer];
    
	
	// Creo un timer
	timer = [NSTimer scheduledTimerWithTimeInterval:0.1
											 target:self
										   selector:@selector(drawFrame)
										   userInfo:nil
											repeats:YES];
	
	//struct timeval time;
	//gettimeofday(&time,NULL); 
	//cur_time = COMPUTE_USECS(time);
	
	
	
	// Creo el vertex Buffer
	[self createVertexBuffer];
	
	// Inicializao las matrices
	 LF.x = 0;
	 LF.y = 2;
	 LF.z = -2.5;
	 LA.x = 0;
	 LA.y = 0;
	 LA.z = 0;
	 UP.x = 0;
	 UP.y = 1;
	 UP.z = 0;
	
	cant_frames = 0;
	
}

- (void)dealloc
{
	
	// Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
    [super dealloc];
}


- (void)viewDidUnload
{
	[super viewDidUnload];
	
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
}

void _F3(float u,float v,float *f,float *g,float *h)
{
	
	*f = 1.5*cos(u)*sin(v);
	*g = 0.3*sin(u)*sin(v);
	*h = 0.5*cos(v);

}


void _F2(float u,float v,float *f,float *g,float *h)
{

	float X = cos(u)*sin(v);
	float Y = sin(u)*sin(v);
	float Z = cos(u);

	*f = 0.5*(2*X*X -Y*Y -Z*Z + 2*X*Z*(Y*Y - Z*Z) + Z*X*(X*X -Z*Z) + X*Y*(Y*Y - X*X));
	*g = 0.8660254*(Y*Y - Z*Z + (Z*X*(Z*Z - X*X) * X*Y*(Y*Y - X*X)));
	*h = (X+Y+Z)*(pow(X+Y+Z,3) + 4*(Y-X)*(Z-Y)*(X-Z));
	
	*h/=8.0;
}
	
// Botella de Klein
void _F(float u,float v,float *f,float *g,float *h)
{
	
	*f = -2.0/15.0*cos(u)*(3*cos(v) + 5*sin(u)*cos(v)*cos(u)-30*sin(u)
						   -60*sin(u)*pow(cos(u),6)+90*sin(u)*pow(cos(u),4));
	*g = -1.0/15.0*sin(u)*(80*cos(v)*pow(cos(u),7)*sin(u) + 48*cos(v)*pow(cos(u),6)
						   -80*cos(v)*pow(cos(u),5)*sin(u) - 48*cos(v)*pow(cos(u),4)
						   -5*cos(v)*pow(cos(u),3)*sin(u) - 3*cos(v)*pow(cos(u),2)
						   +5*sin(u)*cos(v)*cos(u) + 3*cos(v) -60*sin(u));
	*h = 2.0/15.0*sin(v)*(3 + 5*sin(u)*cos(v));
	
}


struct vect3 *cross(struct vect3 *rta,struct vect3 *a,struct vect3 *b)
{
	rta->x = a->y*b->z - a->z*b->y;
	rta->y = a->z*b->x - a->x*b->z;
	rta->z = a->x*b->y - a->y*b->x;
	
	return rta;
}

float dot(struct vect3*a,struct vect3 *b)
{
	return a->x*b->x + a->y*b->y + a->z*b->z; 
}
 

struct vect3 *normalize(struct vect3 *a)
{
	float mod = sqrt(a->x*a->x + a->y*a->y + a->z*a->z);
	if(mod!=0)
	{
		a->x /= mod;
		a->y /= mod;
		a->z /= mod;
	}
	
	return a;
}
	
struct vect3 *resta(struct vect3 *rta,struct vect3 *a,struct vect3 *b)
{
	rta->x = a->x - b->x;
	rta->y = a->y - b->y;
	rta->z = a->z - b->z;
	return rta;
}

struct vect3 *suma(struct vect3 *rta,struct vect3 *a,struct vect3 *b)
{
	rta->x = a->x + b->x;
	rta->y = a->y + b->y;
	rta->z = a->z + b->z;
	return rta;
}

void D3DXMatrixLookAtLH(GLfloat *m,struct vect3 *pEye,struct vect3 *pAt,struct vect3 *pUp)
{
	struct vect3 X,Y,Z;
	
	// Z = | pEye - pAt|
	normalize(resta(&Z,pEye,pAt));
	
	// X = UP x Z
	normalize(cross(&X,pUp,&Z));
	
	// Y = Z x X
	cross(&Y,&Z,&X);
	
	m[0]=X.x,			m[1]=Y.x,			m[2]=Z.x,			m[3]=0;
	m[4]=X.y,			m[5]=Y.y,			m[6]=Z.y,			m[7]=0;
	m[8]=X.z,			m[9]=Y.z,			m[10]=Z.z,			m[11]=0;
	m[12]=-dot(&X,pEye),m[13]=-dot(&Y,pEye),m[14]=-dot(&Z,pEye),m[15]=1;
}

void glPerspectiveFovLH(float fovy,float Aspect,float zn,float zf)
{
	double y = zn * tan(fovy*M_PI/360.0);
	glFrustumf(-y*Aspect,y*Aspect,-y,y,zn,zf);
}


- (void)createVertexBuffer
{
	
	float x,y,z;
	float u0 = -M_PI;
	float u1 = M_PI;
	float v0 = M_PI;
	float v1 = 2*M_PI;
	float du = (u1-u0)/50.0;
	float dv = (v1-v0)/50.0;
	
	struct vect3 F[60][60];
	struct vect3 N[60][60];
	// F= campo vectorial
	for(int i=0;i<=50;++i)
		for(int j=0;j<=50;++j)
		{
			float u = u0 + du*i;
			float v = v0 + dv*j;
			_F(u,v,&x,&y,&z);
			F[i][j].x = x; 
			F[i][j].y = y; 
			F[i][j].z = z;
		}
			
	// Gradiente
	for(int i=0;i<50;++i)
		for(int j=0;j<50;++j)
		{
			struct vect3 U,V;
			resta(&U,&F[i][j],&F[i+1][j]);
			resta(&V,&F[i][j],&F[i][j+1]);
			cross(&N[i][j],normalize(&U),normalize(&V));
			
		}

	float a=0.5;
	// Vertices pp dichos
	cant_v = 0;
	for(int i=0;i<50;++i)
		for(int j=0;j<50;++j)
		{
			vb[cant_v].x = F[i][j].x; 
			vb[cant_v].y = F[i][j].z; 
			vb[cant_v].z = F[i][j].y;
			vb[cant_v].r = N[i][j].x*255;
			vb[cant_v].g = N[i][j].y*255;
			vb[cant_v].b = N[i][j].z*255;
			vb[cant_v].a = a*255;
			cant_v++;

			vb[cant_v].x = F[i+1][j].x; 
			vb[cant_v].y = F[i+1][j].z; 
			vb[cant_v].z = F[i+1][j].y;
			vb[cant_v].r = N[i+1][j].x*255;
			vb[cant_v].g = N[i+1][j].y*255;
			vb[cant_v].b = N[i+1][j].z*255;
			vb[cant_v].a = a*255;
			cant_v++;
			
			vb[cant_v].x = F[i][j+1].x; 
			vb[cant_v].y = F[i][j+1].z; 
			vb[cant_v].z = F[i][j+1].y;
			vb[cant_v].r = N[i][j+1].x*255;
			vb[cant_v].g = N[i][j+1].y*255;
			vb[cant_v].b = N[i][j+1].z*255;
			vb[cant_v].a = a*255;
			cant_v++;
			
			vb[cant_v].x = F[i+1][j+1].x; 
			vb[cant_v].y = F[i+1][j+1].z; 
			vb[cant_v].z = F[i+1][j+1].y;
			vb[cant_v].r = N[i+1][j+1].x*255;
			vb[cant_v].g = N[i+1][j+1].y*255;
			vb[cant_v].b = N[i+1][j+1].z*255;
			vb[cant_v].a = a*255;
			
			vb[cant_v+1] = vb[cant_v-1];
			vb[cant_v+2] = vb[cant_v-2];
			cant_v+=3;
			
			
		}

	// vertices para el wireframe
	cant_v2 = 0;
	for(int i=0;i<50;++i)
		for(int j=0;j<50;++j)
		{
			// linea 1
			vb2[cant_v2].x = F[i][j].x; 
			vb2[cant_v2].y = F[i][j].z; 
			vb2[cant_v2].z = F[i][j].y;
			vb2[cant_v2].r = 0;
			vb2[cant_v2].g = 0;
			vb2[cant_v2].b = 0;
			vb2[cant_v2].a = 255;

			vb2[cant_v2+1].x = F[i+1][j].x; 
			vb2[cant_v2+1].y = F[i+1][j].z; 
			vb2[cant_v2+1].z = F[i+1][j].y;
			vb2[cant_v2+1].r = 0;
			vb2[cant_v2+1].g = 0;
			vb2[cant_v2+1].b = 0;
			vb2[cant_v2+1].a = 255;
			
			// linea 2
			vb2[cant_v2+2] = vb2[cant_v2+1];
			
			vb2[cant_v2+3].x = F[i+1][j+1].x; 
			vb2[cant_v2+3].y = F[i+1][j+1].z; 
			vb2[cant_v2+3].z = F[i+1][j+1].y;
			vb2[cant_v2+3].r = 0;
			vb2[cant_v2+3].g = 0;
			vb2[cant_v2+3].b = 0;
			vb2[cant_v2+3].a = 255;
			
			// linea 3
			vb2[cant_v2+4] = vb2[cant_v2+3];
			
			vb2[cant_v2+5].x = F[i][j+1].x; 
			vb2[cant_v2+5].y = F[i][j+1].z; 
			vb2[cant_v2+5].z = F[i][j+1].y;
			vb2[cant_v2+5].r = 0;
			vb2[cant_v2+5].g = 0;
			vb2[cant_v2+5].b = 0;
			vb2[cant_v2+5].a = 255;
			
			// linea 4
			vb2[cant_v2+6] = vb2[cant_v2+5];
			vb2[cant_v2+7] = vb2[cant_v2];
			
			cant_v2+=8;
			
		}
	
	
	
}
	


- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
    
	//float an = M_PI/64.0;
	//float x = LF_x;
	//float z = LF_z;
	//LF_x = x*cos(an) - z*sin(an);
	//LF_z = x*sin(an) + z*cos(an);
		
	
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
	//glEnable(GL_DEPTH_TEST);
    //glDepthMask(GL_TRUE);
	//glEnable(GL_CULL_FACE);
	//glFrontFace(GL_CW);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	glPerspectiveFovLH(45,0.5,1,400);
	 
	glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	GLfloat m[16];
	D3DXMatrixLookAtLH(m, &LF, &LA, &UP);
	glMultMatrixf(m);
	
	
	glVertexPointer(3, GL_FLOAT, sizeof(struct VERTEX), vb);
	glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(struct VERTEX), &(vb[0].r));
    glEnableClientState(GL_COLOR_ARRAY);
    glDrawArrays(GL_TRIANGLES, 0, cant_v);
    
	// Wire Frame
	glDisable(GL_BLEND);
	glVertexPointer(3, GL_FLOAT, sizeof(struct VERTEX), vb2);
    glColorPointer(4, GL_UNSIGNED_BYTE, sizeof(struct VERTEX), &(vb2[0].r));
    glDrawArrays(GL_LINES, 0, cant_v2);
	
	
    [(EAGLView *)self.view presentFramebuffer];
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end
