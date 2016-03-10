
#import "tablero.h"
#include <sys/time.h>


@implementation tablero

-init
{
	if(self = [super init])
	{
		perdio = FALSE;
		pieza_actual = nil;
		pieza_siguiente = nil;
		
		cdx = 20;
		cdy = 18;
		offset_x = 0;
		offset_y = 0;
		offset_angulo = 0;

		ox = (320-MAX_COL*cdx)/2;
		oy = 10;

		
		for(int i=0;i<MAX_FIL;++i)
			for(int j=0;j<MAX_COL;++j)
				datos[i][j]=i==MAX_FIL-1?1+MAX_FIGURA:0;
		
		
		struct timeval time;
		gettimeofday(&time,NULL); 
		srand ( time.tv_usec );
		
		score = 0;
	
		

		
	}
	return self;	
	
}

@synthesize perdio;
@synthesize ox;
@synthesize oy;
@synthesize cdx;
@synthesize cdy;
@synthesize offset_x;
@synthesize offset_y;
@synthesize offset_angulo;
@synthesize score;

-(figura *)pieza_actual
{
	return pieza_actual;
}

-(void)dibujar:(CGContextRef) pDC
{
	int i,j;
	
	// Recuadro
	CGContextBeginPath(pDC);
	CGContextMoveToPoint(pDC, ox-2,oy-2);
	CGContextAddLineToPoint(pDC,MAX_COL*cdx+ox,oy-2);
	CGContextAddLineToPoint(pDC,MAX_COL*cdx+ox,MAX_FIL*cdy+oy);
	CGContextAddLineToPoint(pDC,ox-2,MAX_FIL*cdy+oy);
	CGContextAddLineToPoint(pDC,ox-2,oy-2);
	CGContextDrawPath(pDC, kCGPathStroke);
	
	// FALTA el scoreboard, nombre del jugador, etc


	// Dibujo el tablero pp dicho
	for(i=0;i<MAX_FIL;++i)
		for(j=0;j<MAX_COL;++j)
		{
			unsigned char R,G,B;
			if(datos[i][j]==0)
				// es fondo
				R = 64,G=64,B=64;
			else
			if(datos[i][j]<=MAX_FIGURA)
			{
				// es una pieza
				unsigned char tipo_pieza = datos[i][j] - 1;
				R = [PIEZAS[tipo_pieza] R];
				G = [PIEZAS[tipo_pieza] G];
				B = [PIEZAS[tipo_pieza] B];
			}
			else
				// es el borde o una basura puesta x el juego
				R = 192,G=0,B=255;

			CGContextSetRGBFillColor(pDC,(float)R/255.0,(float)G/255.0,(float)B/255.0,1);
			CGContextFillRect(pDC,CGRectMake(ox+j*cdx,oy+i*cdy,cdx-1,cdy-1));
		}

	
	if(pieza_actual!=nil)
		[pieza_actual dibujar:pDC con_tablero: self];

	// Ayuda Hint para pieza siguiente 
	if(pieza_siguiente!=nil)
		[pieza_siguiente dibujar:pDC con_ox:230 con_oy:20 con_cdx:15 con_cdy:15 con_offset_x:0 con_offset_y:0 ];
	
	if(pieza_actual!=nil)
	{
		figura *p = [pieza_actual duplicar];
		while(![self tocaPieza: p])
			[p setFil: [p fil]+1];
	
		
		[p dibujar:pDC con_ox:ox con_oy:oy con_cdx:cdx con_cdy:cdy con_blending:0.2];
			
		[p dealloc];
	}
}


// Determina si la pieza quedo trabada 
-(bool) tocaPieza: (figura *)pieza
{
	if(!pieza)
		return false;

	int i;
	bool toca=false;
	int x,y;
	for(i=0;i<[pieza cant_topes] && !toca;++i)
	{
		x = [pieza topeX:i];
		y = [pieza topeY:i];
		if(datos[y][x])
			toca = true;
	}

	return toca;
}

-(bool)tocaPieza
{
	return [self tocaPieza: pieza_actual];
}



// Determina si la pieza puede moverse en dicha posicion
-(bool) posValida
{
	if(!pieza_actual)
		return false;

	int i;
	bool valida = true;
	int x,y;
	for(i=0;i<[pieza_actual cant_piezas] && valida;++i)
	{
		x = [pieza_actual topeX:i];
		y = [pieza_actual topeY:i];
		if(y>=MAX_FIL || x>=MAX_COL || datos[y][x])
			valida = false;
	}

	return valida;
}

// Pega la pieza en el tablero 
-(void)pegarPieza
{
	if(!pieza_actual)
		return;

	unsigned char tipo = [pieza_actual tipo_pieza];
	int i;
	int x,y;
	for(i=0;i<[pieza_actual cant_piezas];++i)
	{
		x = [pieza_actual posX:i];
		y = [pieza_actual posY:i];
		datos[y][x] = 1 + tipo;
	}

	// Recompongo el tablero, a ver si lleno lineas
	[self packLineas];
	
}


-(void) nuevaPieza
{
	
	int aux_figura = rand() % MAX_FIGURA;
	
	if(pieza_actual)
		[pieza_actual dealloc];
	
	
	if(pieza_siguiente)
	{
		pieza_actual = pieza_siguiente;
		pieza_siguiente = [PIEZAS[aux_figura] duplicar];
		[pieza_siguiente setRotacion: 0];
		[pieza_siguiente setFil: 0];
		[pieza_siguiente setCol: (MAX_COL-[pieza_actual ancho])/2];
	}
	else
	{
		pieza_actual = [PIEZAS[aux_figura] duplicar];
		[pieza_actual setRotacion: 0];
		[pieza_actual setFil: 0];
		[pieza_actual setCol: (MAX_COL-[pieza_actual ancho])/2];

		aux_figura = rand() % MAX_FIGURA;
		pieza_siguiente = [PIEZAS[aux_figura] duplicar];
		[pieza_siguiente setRotacion: 0];
		[pieza_siguiente setFil: 0];
		[pieza_siguiente setCol: (MAX_COL-[pieza_actual ancho])/2];
	}

	if([self tocaPieza])
	{
		perdio = true;
		// le aviso al usuario remoto que aca perdi, 
		//enviarPerdi;
		// Falta Mensaje de que perdio
	}
}

// Baja la pieza actual una fila
-(void) bajarFila
{
	[pieza_actual setFil: [pieza_actual fil]+1];
}
	

-(void) bajarPieza
{
	while(![self tocaPieza])
		[pieza_actual setFil: [pieza_actual fil]+1];
	[self pegarPieza];
	[self nuevaPieza];

}


-(void) eliminarLinea:(int) nro_linea
{
	for(int i=nro_linea-1;i>=0;--i)
		for(int j=0;j<MAX_COL;++j)
			datos[i+1][j] = datos[i][j];
	[self nuevaLinea:0];
}

-(bool)lineaCompleta:(int) nro_linea
{
	bool rta = true;
	for(int j=0;j<MAX_COL && rta;++j)
		if(!datos[nro_linea][j])
			rta = 0;
	return rta;
}

-(void) nuevaLinea:(int) nro_linea
{
	for(int j=0;j<MAX_COL;++j)
		datos[nro_linea][j]=0;
}

-(int)packLineas
{
	int cant=0;				// Cantidad de lineas que baja 
	int i=MAX_FIL-2;

	while(i>=0)
		if([self lineaCompleta:i])
		{
			// falta Hacer un ruido 
      		++cant;
			[self eliminarLinea:i];
		}
		else
			--i;
	if(cant<2)
		score+=cant;
	else
		score+=2*cant;
	return cant;
}

-(void)limpiarTablero
{
	for(int i=0;i<MAX_FIL;++i)
		for(int j=0;j<MAX_COL;++j)
			datos[i][j]=i==MAX_FIL-1?1:0;

	if(pieza_actual)
		[pieza_actual dealloc];
	if(pieza_siguiente)
		[pieza_siguiente dealloc];
	pieza_actual = pieza_siguiente =  nil;
	perdio = FALSE;
}

// Penalizacion
-(void)penalizarLineas: (int) cant
{
	int i;
   // Subo todo el tablero cant lineas 
	for(i=cant;i<MAX_FIL-1;++i)
		for(int j=0;j<MAX_COL;++j)
			datos[i-cant][j] = datos[i][j];
	// Agrego mierda en las lineas de abajo

	srand((unsigned)time(NULL));

	for(i=0;i<cant;++i)
	{
   	// Primero los pongo llenos 
		for(int j=0;j<MAX_COL;++j)
			datos[MAX_FIL-1-i][j] = 1;
		// Luego les borro 4 elementos ( a lo sumo), por lo
		// menos 1   
		for(int h=0;h<4;++h)
			datos[MAX_FIL-1-i][rand() % MAX_COL] = 0;
	}

}

// Verifico si el pto esta sobre la figura actual
-(bool) posSobrePieza:(CGPoint)pt
{
	bool rta = false;
	if(pieza_actual!=nil)
	{
		int x = ox + [pieza_actual col]*cdx;
		int y = oy + [pieza_actual fil]*cdy;
		int dcol = [pieza_actual ancho];
		
		if(pt.x>=x && pt.x<=x+dcol*cdx && pt.y>=y && pt.y<=y + 4*cdy)
			rta = true;
	}
	return rta;
}


// Verifico si el pto esta sobre el tablero
-(bool) posSobreTablero:(CGPoint)pt
{
	bool rta = false;
	if(pieza_actual!=nil)
	{
		if(pt.x>=ox && pt.x<=ox+cdy*MAX_COL && pt.y>=oy && pt.y<= oy+cdy*MAX_FIL)
			rta = true;
	}
	return rta;
}


	
@end
	
	

