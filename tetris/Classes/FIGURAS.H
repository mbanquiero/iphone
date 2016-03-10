// tipos de figuras
#define F_ELE_1				0
#define F_ELE_2				1
#define F_CUBO					2
#define F_LINEA				3
#define F_TRI					4
#define F_TORCIDO_1			5
#define F_TORCIDO_2			6

#define MAX_FIGURA			7

#define BYTESXROTACION		16
#define CANT_ROTACIONES		 4
#define MAX_CELDAS		 	300
#define MAX_COL				10
#define MAX_FIL				20


@class tablero;

@interface figura : NSObject
{
		unsigned char R,G,B;
		unsigned char tipo_pieza;
		char cant_piezas;
		char topes[4];
   		// Posicion de cada uno de los cuadrados
		int x[16];
		int y[16];
		// Puntos donde puede encayar (topes)
		int tx[16];
		int ty[16];
		// Anchos
		int anchos[4];
		// Datos
		int fil;
		int col;
		int rotacion;

}

@property unsigned char tipo_pieza;
@property char cant_piezas;
@property int fil;
@property int col;
@property int rotacion;
@property unsigned char R;
@property unsigned char G;
@property unsigned char B;



-initWithTipo:(unsigned char) tipo;
-initWithFigura:(figura *) p;
-(figura *)duplicar;

-(NSInteger) ancho;
-(NSInteger) cant_topes;
-(NSInteger) posX:(NSInteger) pieza;
-(NSInteger) posY:(NSInteger) pieza;
-(NSInteger) topeX:(NSInteger) pieza;
-(NSInteger) topeY:(NSInteger) pieza;


-(void) dibujar:(CGContextRef)pDC con_ox:(int)ox con_oy:(int)oy con_cdx:(int)cdx con_cdy:(int)cdy con_offset_x:(int)offset_x con_offset_y:(int)offset_y con_angulo:(int)angulo;
-(void) dibujar:(CGContextRef)pDC con_ox:(int)ox con_oy:(int)oy con_cdx:(int)cdx con_cdy:(int)cdy con_offset_x:(int)offset_x con_offset_y:(int)offset_y;
-(void) dibujar:(CGContextRef)pDC con_tablero:(tablero *)T;
-(void) dibujar:(CGContextRef)pDC con_ox:(int)ox con_oy:(int)oy con_cdx:(int)cdx con_cdy:(int)cdy con_blending:(float)alpha;

-(void) moverPieza:(tablero *)T con_dx:(int) px con_dy:(int) py;
-(void) moverPiezaToXY:(tablero *)T con_posx:(int) px con_posy:(int) py;
-(void) rotarPiezaD:(tablero *)T;
-(void) rotarPiezaI:(tablero *)T;

@end


extern figura *PIEZAS[20];





