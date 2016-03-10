//
//  guitarView.m
//  guitar
//
//  Created by user on 15/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "guitarView.h"
#import "guitarAppDelegate.h"

@implementation guitarView

#define D_TECLA	32


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}



-(id)initWithCoder:(NSCoder *)aDecoder
{
	
    if ((self = [super initWithCoder:aDecoder])) {
        // Initialization code
		
		cant_dedos = 0;
    }
    return self;
}




// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSaveGState(context);
	
	// fondo azul
	switch(_tipo_maquina)
	{
		case MAQ_PIANO:
			CGContextSetRGBFillColor(context,0.1,0.1,0.5,1);
			break;
		case MAQ_RUIDO:
			CGContextSetRGBFillColor(context,0.3,0.0,0.0,1);
			break;
		case MAQ_RUIDO_2:
			CGContextSetRGBFillColor(context,0,0.3,0.0,1);
			break;
		case MAQ_RUIDO_3:
			CGContextSetRGBFillColor(context,0,0.0,0.3,1);
			break;
			

	}		
	CGContextFillRect(context,CGRectMake(0,0,320,480));

	// controles
	CGContextSetRGBFillColor(context,0.2,0.2,0.2,1);
	CGContextFillRect(context,CGRectMake(300,0,20,480));

	
	if(_tipo_maquina==MAQ_PIANO)
	{
		// teclas
		CGContextBeginPath(context);
		CGContextSetRGBStrokeColor(context,0.2,0.2,0.2,1);
		CGContextSetRGBFillColor(context,1,1,1,1);
		for(int fil=0;fil<14;++fil)
			CGContextAddRect(context,CGRectMake(0,fil*D_TECLA,200,D_TECLA));
		CGContextDrawPath(context, kCGPathFillStroke);
		
		CGContextBeginPath(context);
		CGContextSetRGBFillColor(context,0,0,0,1);
		for(int fil=0;fil<13;++fil)
			if(fil%7!=2 && fil%7!=6) 
				CGContextAddRect(context,CGRectMake(100,fil*D_TECLA+D_TECLA-(D_TECLA-5)/2,100,D_TECLA-5));
		CGContextDrawPath(context, kCGPathFillStroke);
	}

	float R[] = {0,1,0,1,0,0,0,0,0,0};
	float G[] = {1,1,0,0,0,1,0,0,0,0};
	float B[] = {0,1,1,0,1,0,0,0,0,0};
	
	for(int i=0;i<cant_dedos;++i)
	{	
		CGContextSetRGBFillColor(context,R[i],G[i],B[i],0.5);
		if(_tipo_maquina==MAQ_PIANO)
		{
			CGContextBeginPath(context);
			bool negra = pos_dedo[i].x>100?true:false;
			if(negra)
			{
				int fil = (pos_dedo[i].y-D_TECLA/2) / D_TECLA;
				if(fil%7!=2 && fil%7!=6) 
					CGContextAddRect(context,CGRectMake(100,fil*D_TECLA+D_TECLA-(D_TECLA-5)/2,100,D_TECLA-5));
			}
			else 
			{
				int fil = pos_dedo[i].y / D_TECLA;
				CGContextAddRect(context,CGRectMake(0,fil*D_TECLA,200,D_TECLA));
			}
			CGContextDrawPath(context, kCGPathFillStroke);
			
		}
		else 
		{
			CGContextBeginPath(context);
			CGContextSetRGBStrokeColor(context,0.2,0.2,0.2,1);
			CGContextAddEllipseInRect(context,CGRectMake(pos_dedo[i].x-40,pos_dedo[i].y-40,80,80));
			CGContextDrawPath(context, kCGPathFillStroke);
		}
		
		CGContextSetRGBFillColor(context,1,1,1,1);
		CGContextFillRect(context,CGRectMake(pos_dedo[i].x-5,pos_dedo[i].y-5,10,10));
	}
	
	CGContextRestoreGState(context);

}

-(void) actualizar
{
	// Parche para cambiar de instrumento
	if(cant_dedos && pos_dedo[0].x>280)
	{
		if(_tipo_maquina==MAQ_PIANO)
			_tipo_maquina = MAQ_RUIDO;
		else 
		{
			_tipo_maquina++;
			if(_tipo_maquina > MAQ_RUIDO_3)
				_tipo_maquina = MAQ_PIANO;
		}
				
		
		// repinto la pantalla	
		[self setNeedsDisplay];
	
		return;
	}
	
		
	
	
	// Actualizo las frecuencias
	for(int i=0;i<MAX_CANALES;++i)
		if(i<cant_dedos)
		{
			if(_tipo_maquina<MAQ_PIANO)
			{
				// desplazamiento continuo: la X reprenta el volumen y la Y la frecuencia
				_freq[i] = (float)pos_dedo[i].y / 480.0 * 2500 + 440;
				_volumen[i] = (float)pos_dedo[i].x / 320.0;
			}
			else 
			{
				// notas musicales
				bool negra = pos_dedo[i].x>100?true:false;
				if(negra)
				{
					int fil = (pos_dedo[i].y-D_TECLA/2) / D_TECLA;
					if(fil%7!=2 && fil%7!=6) 
					{
						int negras[]={1,3,-1,6,8,10,-1};
						int nota = fil%7;
						int octava = fil/7;
						
						float n = negras[nota] + 12*octava;
						_freq[i] = 440 * pow(2,n/12.0);
						_volumen[i] = 1;
					}						
				}
				else 
				{
					int blancas[]={0,2,4,5,7,9,11};
					int fil = pos_dedo[i].y / D_TECLA;
					int nota = fil%7;
					int octava = fil/7;
					
					float n = blancas[nota] + 12*octava;
					_freq[i] = 440 * pow(2,n/12.0);
					_volumen[i] = 1;
				}
				
			}

		}
		else 
			_volumen[i] = 0;

	
	// repinto la pantalla	
	[self setNeedsDisplay];	
	
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Proceso los mov. del dedo
	for(UITouch *touch in touches)
	{
		// Guardo la posicion inicial de cada dedo y la direccion de memoria del uitouch que lo representa
		// qye es lo que voy a usar para hacer el tracking de cada dedo
		if(cant_dedos<MAX_DEDOS)
		{
			pos_dedo[cant_dedos] = [touch locationInView:self];
			dedo[cant_dedos] = touch;
			++cant_dedos;
			
		}
	}
		
	[self actualizar];
		
	
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	// Proceso los mov. del dedo
	for(UITouch *touch in touches)
	{
		CGPoint p = [touch locationInView:self];
// antes usaba la posicion anterior para rastrear el dedo, pero es mejor usar la direccion del evento
//		CGPoint p_ant = [touch previousLocationInView:self];
	
		// busco que dedo es el que se esta moviendo
		bool flag = false;
		int i = 0;
		while(i<cant_dedos && !flag)
			if(dedo[i]==touch)
			//if(abs(pos_dedo[i].x - p_ant.x)<3 && abs(pos_dedo[i].y - p_ant.y)<3)
				flag = true;
			else
				++i;

		// actualizo la pos. del dedo
		if(flag)
			pos_dedo[i] = p;
			
	}
	[self actualizar];

		
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for(UITouch *touch in touches)
	{
		// busco que dedo es el que se esta levantando
		bool flag = false;
		int i = 0;
		while(i<cant_dedos && !flag)
			if(dedo[i]==touch)
				flag = true;
			else
				++i;
		
		// actualizo la pos. del dedo
		if(flag)
		{
			// elimino el dedo de la lista
			for(int j=i;j<cant_dedos-1;++j)
			{
				pos_dedo[j] = pos_dedo[j+1];
				dedo[j] = dedo[j+1];
			}
			cant_dedos--;
		}
	}
	
	[self actualizar];

}


- (void)dealloc {
    [super dealloc];
}


@end
