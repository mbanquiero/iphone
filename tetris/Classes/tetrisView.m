//
//  tetrisView.m
//  tetris
//
//  Created by user on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "tetrisView.h"
#include <sys/time.h>
#include "FIGURAS.H"

#define COMPUTE_USECS(a) (a).tv_sec * 1000000 + (a).tv_usec

@implementation tetrisView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
		
		[self cargar_piezas];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	
    if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
		
		[self cargar_piezas];
		pos.x = pos.y = 0;
		eventoInterno = 0;
		tablero_local = [tablero new];
		[tablero_local nuevaPieza];
		timer_bajar_fila = 0;
		vel = 1;			// 2 lineas x segundo , tarda 0.5 segundos por linea
		timer_rotar = 0;
		trot = 0.2;			// segundos que tarda en completar una rotacion (de 90 grados)
		timer_pos_x = 0;
		cant_filas_abajo = 0;

		// Creo un timer
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1
												 target:self
												selector:@selector(refreshScreen)
												userInfo:nil
												repeats:YES];
		
		struct timeval time;
		gettimeofday(&time,NULL); 
		cur_time = COMPUTE_USECS(time);
		
    }
    return self;
}

-(void) refreshScreen
{
	NSLog(@"Refreshing screen!");
	// teoricamente 0.1 segundos, pero el timer no es muy preciso
	
	struct timeval time;
	gettimeofday(&time,NULL); 
	long lTime = COMPUTE_USECS(time);
	float dt = (float)(lTime - cur_time)/1000000.0;
	cur_time = lTime;
	[self updateFrame: dt];	
}



-(void)cargar_piezas
{
	 for(int i=0;i<MAX_FIGURA;++i)
		 PIEZAS[i] = [[figura new] initWithTipo:i] ;
		
}
 

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// fondo negro
	CGContextSetRGBFillColor(context,0,0,0,1);
	CGContextFillRect(context,CGRectMake(0,0,320,480));
	
	//int y_final = [tablero_local oy] + [tablero_local cdy]*MAX_FIL;
	//CGContextSetRGBFillColor(context,1,0,0,1);
	//CGContextFillRect(context,CGRectMake(0,y_final,300,20));

	// dibujo el tablero
	[tablero_local dibujar:context];

	// para debug dibujo la posicon del dedo
	if(0)
	{
		CGContextSetRGBFillColor(context,1,1,1,0.5);
		CGContextFillRect(context,CGRectMake(pos.x-10,pos.y-10,20,20));
		CGContextSetRGBFillColor(context,1,1,1,1);
		CGContextFillRect(context,CGRectMake(pos.x-5,pos.y-5,10,10));
	}
	
	CGContextScaleCTM(context,1,-1);
	CGContextTranslateCTM(context,0,-480);

	CGContextSetRGBStrokeColor(context,1,1,1,1);
	char buffer[255];
	if([tablero_local perdio])
	{
		CGContextSelectFont(context,"Helvetica-Bold",30, kCGEncodingMacRoman);
		strcpy(buffer,"GAME OVER!");
		CGContextShowTextAtPoint(context,10,200,buffer,strlen(buffer));
	}
	else 
	{
		
		CGContextSelectFont(context,"Helvetica-Bold",12, kCGEncodingMacRoman);
		sprintf(buffer,"Elapsed Time = %.1f Cant Frames %d",elapsed_time,cant_frames);
		CGContextShowTextAtPoint(context,10,10,buffer,strlen(buffer));
	}
	CGContextRestoreGState(context);
	
}

-(void) updateFrame:(CFTimeInterval)timeElapsed
{
	elapsed_time = timeElapsed;
	++cant_frames;

	if(![tablero_local perdio])
	{
		// Logica del juego
		if([tablero_local tocaPieza])
		{
			[tablero_local pegarPieza];
			[tablero_local nuevaPieza];
		}
	
		// es tiempo de bajar la figura una fila?
		timer_bajar_fila+=elapsed_time;
		float tl = 1.0/vel;
		if(timer_bajar_fila>=tl)
		{
			timer_bajar_fila -= tl;
			[tablero_local bajarFila];
			[tablero_local setOffset_y: 0];
		}
		else
			// interpolo linealmente para lograr un efecto mas continuo
			[tablero_local setOffset_y: [tablero_local cdy]*timer_bajar_fila*vel];
		
		// suavizar movimientos de rotacion y mov. horizontal usando timers.
		if(timer_rotar>0)
		{
			timer_rotar-=elapsed_time;
			if(timer_rotar<0)
				timer_rotar = 0;
		
			// interpolo linealmente para lograr un efecto mas continuo
			[tablero_local setOffset_angulo: 90*timer_rotar/trot*(rot_derecha?-1:1)];
		}
		
		// esta opcion se ve mas lindo pero confunde al jugador
		/*
		if(timer_pos_x>0)
		{
			timer_pos_x-=elapsed_time;
			if(timer_pos_x<0)
				timer_pos_x = 0;
			
			// interpolo linealmente para lograr un efecto mas continuo
			[tablero_local setOffset_x: [tablero_local cdx]*timer_pos_x*10*vel*dcol];
		}
		 */
		
	}
		
	[self setNeedsDisplay];	
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(eventoInterno==0)
	{
		NSSet *toques = [event touchesForView: self];
		UITouch *t = [toques anyObject];
		posant = [t locationInView:self];
		touch_begin = [t timestamp];
		cant_filas_abajo = 0;
		eventoInterno = 1;
	}
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(eventoInterno==1 || eventoInterno==2)
	{
		// si habia comenzado una secuencia para mover la pieza
		// Proceso el mov. del dedo
		UITouch *t = [touches anyObject];
		pos = [t locationInView:self];
		int dx = (float)(pos.x - posant.x)/ (float)[tablero_local cdx];
		int dy = (float)(pos.y - posant.y)/ (float)[tablero_local cdy];
		if(dy<0)
			// no lo dejo mover para arriba, puede mover para abajo para acelerar la caida
			dy = 0;

		[[tablero_local pieza_actual] moverPieza: tablero_local con_dx:dx con_dy:dy];
		if(dx)
			posant.x += dx* (float)[tablero_local cdx];
	
		if(dy)
		{
			posant.y += dy* (float)[tablero_local cdy];
			
			cant_filas_abajo += dy;
			NSTimeInterval dt = [t timestamp] - touch_begin;

			if(cant_filas_abajo>3)
				if(dt<1.5)
			{
				// la velocidad de mov hacia abajo es superior a 5 filas x segundos
				[tablero_local bajarPieza];
				eventoInterno = 99;
				// tengo que cancelar la secuencia
				// [self resignFirstResponder];
				return;
			}
		}
		
		if(dx || dy)
			eventoInterno = 2;
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(eventoInterno==1)
	{
		// si no movio la pieza, verifico si hico TAP con el dedo
		UITouch *t = [touches anyObject];
		CGPoint p = [t locationInView:self];
		if(t.tapCount == 1)
		{
			int y_final = [tablero_local oy] + [tablero_local cdy]*MAX_FIL;

			if(p.y>y_final)
			{
				[tablero_local bajarPieza];
			}
			else 
			{
			
				timer_rotar = trot;
			
				int col = (float)(p.x -[tablero_local ox])/ (float)[tablero_local cdx] + 0.5;

				if(col<[[tablero_local pieza_actual] col])
				{
					// rotar dizquierda
					rot_derecha = false;
					[[tablero_local pieza_actual] rotarPiezaI:tablero_local];
				}
				else 
				{
					// rotar derecha
					rot_derecha = true;
					[[tablero_local pieza_actual] rotarPiezaD:tablero_local];
				}
			}
		}
	}
	eventoInterno=0;
	
}



- (void)dealloc {
	
	for(int i=0;i<MAX_FIGURA;++i)
		[PIEZAS[i] dealloc] ;
	[tablero_local dealloc];
	[super dealloc];
	
}


@end
