//
//  guitarView.m
//  guitar
//
//  Created by user on 15/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "guitarView.h"
#import "guitarAppDelegate.h"
#include <sys/time.h>

@implementation guitarView

#define D_TECLA	32
#define CUERDA_OX		30
#define COMPUTE_USECS(a) (a).tv_sec * 1000000 + (a).tv_usec

#define sign(a)	(a)<0?-1:1

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
		d_cuerda = (320 - 2*CUERDA_OX)/5;		// dist. entre cuerdas
		for(int i=0;i<6;++i)
		{
			timer_vibrando[i] = 0;
			acepta_punteo[i] = true;
			traste[i] = 0;
			volumen_cuerda[i] = 1;
		}
		
		freq_cuerda[0] = 329.628;
		freq_cuerda[1] = 440;
		freq_cuerda[2] = 587.33;
		freq_cuerda[3] = 783.991;
		freq_cuerda[4] = 987.767;
		freq_cuerda[5] = 1318.91;
		
		for(int i=0;i<50;++i)
			for(int j=0;j<6;++j)
				chord[i][j] = 0;
	
		// re menor
		chord_name[0] = "Dm";
		chord[0][5] = 1;
		chord[0][4] = 3;
		chord[0][3] = 2;

		chord_name[1] = "Am";
		chord[1][4] = 1;
		chord[1][3] = 2;
		chord[1][2] = 2;

		chord_name[2] = "Em";
		chord[2][3] = 1;
		chord[2][2] = 2;
		chord[2][1] = 2;

		chord_name[3] = "C";
		chord[3][4] = 1;
		chord[3][2] = 2;
		chord[3][1] = 3;

		chord_name[4] = "G";
		chord[4][5] = 3;
		chord[4][1] = 2;
		chord[4][0] = 3;
		
		chord_name[5] = "D";
		chord[5][5] = 2;
		chord[5][4] = 3;
		chord[5][3] = 2;
		
		cant_chords = 6;
		
		chord_sel = 0;
		
		guitar_sel = 0;
		_cant_samples = _cant_samples1;
		_pcm = _pcm1;
		
		redraw = 0;

		// Creo un timer
		timer = [NSTimer scheduledTimerWithTimeInterval:0.1
												 target:self
											   selector:@selector(actualizar)
											   userInfo:nil
												repeats:YES];
		
		struct timeval time;
		gettimeofday(&time,NULL); 
		cur_time = COMPUTE_USECS(time);
		
	
			
			
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
		case MAQ_GUITAR:
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

	
	if(_tipo_maquina!=MAQ_GUITAR)
	{
		// controles
		CGContextSetRGBFillColor(context,0.2,0.2,0.2,1);
		CGContextFillRect(context,CGRectMake(300,0,20,480));
	}
	
	if(_tipo_maquina==MAQ_GUITAR)
	{
		// dibujo las cuerdas
		for(int cuerda=0;cuerda<6;++cuerda)
		{
			int dc = 2;
			CGContextBeginPath(context);
			CGContextSetRGBStrokeColor(context,0.2,0.2,0.2,1);
			CGContextSetRGBFillColor(context,0.4,0.4,0.3,1);
			CGContextAddRect(context,CGRectMake(CUERDA_OX+cuerda*d_cuerda-dc,100,2*dc,350));
			CGContextDrawPath(context, kCGPathFillStroke);
			
			if(timer_vibrando[cuerda])
			{
				dc = 6;
				CGContextSetRGBFillColor(context,1,1,1,_volumen[cuerda]);
				CGContextAddRect(context,CGRectMake(CUERDA_OX+cuerda*d_cuerda-dc,100,2*dc,350));
				CGContextDrawPath(context, kCGPathFillStroke);
			}
				
		}
		
	}
	else
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
			
			
			CGContextBeginPath(context);
			CGContextSetRGBStrokeColor(context,0.4,0.4,0.4,1);
			CGContextAddEllipseInRect(context,CGRectMake(pos_ini[i].x-10,pos_ini[i].y-10,20,20));
			CGContextDrawPath(context, kCGPathFillStroke);
			
			CGContextBeginPath(context);
			CGContextMoveToPoint(context, pos_dedo[i].x, pos_dedo[i].y);
			CGContextAddLineToPoint(context,pos_ini[i].x, pos_ini[i].y);
			CGContextDrawPath(context, kCGPathStroke);
			
		}
		
		CGContextSetRGBFillColor(context,1,1,1,1);
		CGContextFillRect(context,CGRectMake(pos_dedo[i].x-5,pos_dedo[i].y-5,10,10));
	}
	
	if(_tipo_maquina==MAQ_GUITAR)
	{
			
		CGContextScaleCTM(context,1,-1);
		CGContextTranslateCTM(context,0,-480);
		CGContextSetRGBStrokeColor(context,1,0.2,0.3,1);
		CGContextSetRGBFillColor(context,1,0,0,1);
		char buffer[255];
		CGContextSelectFont(context,"Helvetica-Bold",12, kCGEncodingMacRoman);

		// dibujo las cuerdas
		for(int cuerda=0;cuerda<6;++cuerda)
		if(timer_vibrando[cuerda])
		{
			//sprintf(buffer,"%d",_sample_ndx[cuerda]);
			sprintf(buffer,"%.1f",_freq[cuerda]);
			CGContextShowTextAtPoint(context,CUERDA_OX+cuerda*d_cuerda-5,20,buffer,strlen(buffer));
		}
		
		// Area de acordes
		CGContextSetRGBStrokeColor(context,1,1,1,1);
		int n = 0;
		int cant_botones = 6;
		int dboton = 320/cant_botones;
		for(int i=0;i<cant_botones && n<cant_chords;++i)
		{
			CGContextBeginPath(context);
			if(chord_sel==n)
				CGContextSetRGBFillColor(context,1,1,1,1);
			else
				CGContextSetRGBFillColor(context,0.2,0.2,0.2,1);
			CGContextAddRect(context,CGRectMake(i*dboton+3,440,dboton-6,40));
			CGContextDrawPath(context, kCGPathFillStroke);
			if(chord_sel==n)
				CGContextSetRGBFillColor(context,0,0,0,1);
			else
				CGContextSetRGBFillColor(context,0.5,0.5,1,1);
			char *p = chord_name[n++];	
			CGContextShowTextAtPoint(context,i*dboton+10,455,p,strlen(p));
		}
		
		// guitarra seleccionada
		for(int i=0;i<4;++i)
		{
			CGContextBeginPath(context);
			if(guitar_sel==i)
				CGContextSetRGBFillColor(context,1,1,1,1);
			else
				CGContextSetRGBFillColor(context,0.2,0.2,0.2,1);
			CGContextAddRect(context,CGRectMake(i*dboton+3,50,dboton-6,40));
			CGContextDrawPath(context, kCGPathFillStroke);
			if(guitar_sel==i)
				CGContextSetRGBFillColor(context,0,0,0,1);
			else
				CGContextSetRGBFillColor(context,0.5,0.5,1,1);
			char saux[20];
			sprintf(saux,"#%d",i+1);
			CGContextShowTextAtPoint(context,i*dboton+10,65,saux,strlen(saux));
		}
		
		
	}
	
	CGContextRestoreGState(context);

}

-(void) actualizar
{
	struct timeval time;
	gettimeofday(&time,NULL); 
	long lTime = COMPUTE_USECS(time);
	elapsed_time = (float)(lTime - cur_time)/1000000.0;
	cur_time = lTime;
		
	// Analizo si el dedo rasguea una o varias cuerdas
	for(int cuerda=0;cuerda<6;++cuerda)
	{
		// de paso actualizo los timers x  eventos ya iniciados
		if(timer_vibrando[cuerda])
		{
			timer_vibrando[cuerda] -= elapsed_time;
			if(timer_vibrando[cuerda]<0)
			{
				// la cuerda termina de vibrar
				timer_vibrando[cuerda] = 0;
				// le elimino la asosiacion con el dedo que la habia hecho vibrar
				acepta_punteo[cuerda] = true;
			}
		}
		
		int pos_cuerda = CUERDA_OX+cuerda*d_cuerda;
		for(int i=0;i<cant_dedos;++i)	
		{
			// el mismo punteo no puede hacer sonar 2 veces a la misma cuerda,
			if(acepta_punteo[cuerda] && pos_dedo[i].y>100 && pos_dedo[i].y<340)
			if((pos_ini[i].x < pos_cuerda -2 && pos_dedo[i].x > pos_cuerda + 2) ||
			   (pos_dedo[i].x < pos_cuerda - 2 && pos_ini[i].x > pos_cuerda + 2) ||
			   abs(pos_dedo[i].x-pos_cuerda)<10)
			{
				// el dedo i toca contra la cuerda, la pongo a vibrar durante 5 segundos
				timer_vibrando[cuerda] = 5;
				// la mano izquierda la simulo con el acorde actual
				// hago de cuenta que esta en el traste que le corresponde
				traste[cuerda] = chord[chord_sel][cuerda];
				// no permito que esta cuerda vuelva a vibrar hasta que no levante el dedo 
				acepta_punteo[cuerda] = false;
				_sample_ndx[cuerda] = 0;
				// volumen del punteo, depende de la velocidad
				// minimo un 50% y maximo un 30% de overdriven
				volumen_cuerda[cuerda] = 0.5;
				float dt = time_dedo[i] - time_ini_dedo[i];
				if(dt!=0)
				{
					float vel = fabs(pos_ini[i].x - pos_dedo[i].x) / dt;
					volumen_cuerda[cuerda] += vel/500.0;
					if(volumen_cuerda[cuerda]>1.3)
						volumen_cuerda[cuerda] = 1.3;
				}
				// Parche porque la guitarra 2 y 3 estan con overdrive
				if(guitar_sel)
					volumen_cuerda[cuerda]*=0.5;
			}
		}
	}
			
	float t0 = 0.1;
	float t1 = 0.2;
	float t2 = 3;
	float t3 = 5;
	float A = 2;
	float D = 0.95;
	float S = 1;
	
	
	// Actualizo las frecuencias (un canal para cada cuerda)
	for(int i=0;i<6;++i)
		if(timer_vibrando[i])
		{
			
			_freq[i] = freq_cuerda[i]*pow(2,traste[i]/12.0);
			
			float t = t3-timer_vibrando[i];
			if(t<t0)
				// attack
				_volumen[i] = A*t/t0;
			else
			if(t<t1)
			{
				// decay
				float k = (t-t0)/(t1-t0);
				_volumen[i] = A*(1-k) + D*k;
			}
			else
			if(t<t2)
			{
				// sustain
				float k = (t-t1)/(t2-t1);
				_volumen[i] = D*(1-k) + S*k;
			}
			else
			{
				// relax
				float k = (t-t2)/(t3-t2);
				_volumen[i] = S*(1-k);
			}
			
			// Le aplico el volumen de la cuerda pp dicha
			_volumen[i] *= volumen_cuerda[i];
		}
		else 
			_volumen[i] = 0;
	
	// Parche para cambiar de instrumento
	/*
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

	 */
	
	// repinto la pantalla, cada N veces
	if(++redraw>5)
	{
		redraw = 0;
		[self setNeedsDisplay];	
	}
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
			pos_ant[cant_dedos] = pos_ini[cant_dedos] = pos_dedo[cant_dedos] = [touch locationInView:self];
			dedo[cant_dedos] = touch;
			time_dedo[cant_dedos] = time_ini_dedo[cant_dedos] = [touch timestamp];
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
		double time = [touch timestamp];
		// busco que dedo es el que se esta moviendo
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
			char dir_ant = sign(pos_dedo[i].x-pos_ant[i].x);
			pos_ant[i] = pos_dedo[i];
			pos_dedo[i] = p;
			time_dedo[i] = time;
			char dir = sign(pos_dedo[i].x-pos_ant[i].x);
			
			if(dir!=dir_ant)
			{
				// cambio en la direccion del rasgueo:
				// empiezdo de nuevo
				pos_ini[i] = pos_ant[i];
				time_ini_dedo[i] = time_dedo[i];
				// vuelvo a aceptar punteo en las cuerdas
				for(int t=0;t<6;++t)
					acepta_punteo[t] = true;
			}
		}
			
	}
	[self actualizar];

		
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
	if(cant_dedos && pos_dedo[0].y<100)
	{
		
		// Cambia de acorde
		int cant_botones = 6;
		int dboton = 320/cant_botones;
		chord_sel = pos_dedo[0].x / dboton;
		if(chord_sel<0)
			chord_sel = 0;
		else
		if(chord_sel>=cant_chords)
			chord_sel = cant_chords - 1;
	}
	else
	if(cant_dedos && pos_dedo[0].y>400)
	{
		
		// Cambia de acorde
		int cant_botones = 6;
		int dboton = 320/cant_botones;
		guitar_sel = pos_dedo[0].x / dboton;
		if(guitar_sel<0)
			guitar_sel = 0;
		else
			if(guitar_sel>=4)
				guitar_sel = 3;
		
		switch (guitar_sel) {
			case 0:
				_cant_samples = _cant_samples1;
				_pcm = _pcm1;
				_freq_base = _freq_base1;
				break;
			case 1:
				_cant_samples = _cant_samples2;
				_pcm = _pcm2;
				_freq_base = _freq_base2;
				break;
			case 2:
				_cant_samples = _cant_samples3;
				_pcm = _pcm3;
				_freq_base = _freq_base3;
				break;
			case 3:
				_pcm = NULL;
				break;
				
		}
		
	}
	
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
				pos_ant[j] = pos_ant[j+1];
				pos_ini[j] = pos_ini[j+1];
				time_dedo[j] = time_dedo[j+1];
				time_ini_dedo[j] = time_ini_dedo[j+1];
				dedo[j] = dedo[j+1];
			}
			cant_dedos--;
		}
	}
	
	for(int i=0;i<6;++i)
		acepta_punteo[i] = true;
	
	
	[self actualizar];

}


- (void)dealloc {
    [super dealloc];
}


@end
