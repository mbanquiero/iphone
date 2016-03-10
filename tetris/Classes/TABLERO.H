

#define BUFFER_LEN			32
#define MAX_TABLEROS		20


#include "figuras.h"


@interface tablero : NSObject
{

		int ox;
		int oy;
		int cdx;
		int cdy;
		int offset_x;
		int offset_y; 
		int offset_angulo; 

		unsigned char datos[MAX_FIL][MAX_COL];
		figura *pieza_actual;
		figura *pieza_siguiente;

		// identificacion del tablero
		char nick[17];
		char nro_jugador;
		bool perdio;
		int score;
	
	
}

@property bool perdio;
@property int ox;
@property int oy;
@property int cdx;
@property int cdy;
@property int offset_x;
@property int offset_y;
@property int offset_angulo;
@property int score;

-init;
-(void)dibujar:(CGContextRef) pDC;
-(void) pegarPieza;
-(bool) tocaPieza: (figura *)pieza;
-(bool) tocaPieza;
-(bool) posValida;
-(void) nuevaPieza;
-(void) bajarFila;
-(void) bajarPieza;
-(void) penalizarLineas:(int) cant;

-(void) limpiarTablero;
-(void) eliminarLinea:(int) nro_linea;
-(bool) lineaCompleta:(int) nro_linea;
-(void) nuevaLinea:(int) nro_linea;
-(int) packLineas;

-(bool) posSobrePieza:(CGPoint)pt;
-(bool) posSobreTablero:(CGPoint)pt;

-(figura *) pieza_actual;



@end
 
