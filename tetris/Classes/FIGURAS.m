#import "FIGURAS.H"
#import "TABLERO.H"

@implementation figura

@synthesize tipo_pieza;
@synthesize cant_piezas;
@synthesize rotacion;
@synthesize fil;
@synthesize col;
@synthesize R;
@synthesize G;
@synthesize B;

figura *PIEZAS[20];

-initWithTipo:(unsigned char) tipo
{
	if(self = [super init])
	{
		tipo_pieza = tipo;
		rotacion = 0;
		col = 0;
		fil = 0;
		cant_piezas=4;
		
		NSString *fname;
		switch(tipo_pieza)
		{
			case F_ELE_1:
				fname = @"ELE1";
				break;
			case F_ELE_2:
				fname = @"ELE2";
				break;
			case F_LINEA:
				fname = @"LINEA";
				break;
			case F_CUBO:
				fname = @"CUBO";
				break;
			case F_TORCIDO_1:
				fname = @"TOR1";
				break;
			case F_TORCIDO_2:
				fname = @"TOR2";
				break;
			case F_TRI:
				fname = @"TRI";
				break;
		}
		
		
		NSError *error;
		NSString *fileLocation = [[NSBundle mainBundle] pathForResource:fname
																 ofType:@"txt"];
		NSString *file  = [[NSString alloc] initWithContentsOfFile:fileLocation
														  encoding:NSUTF8StringEncoding
															 error:&error];
		if(file!=nil)
		{
			NSArray *lines = [file componentsSeparatedByString:@"\r\n"];
			int nro_linea = 0;
			++nro_linea;	// salteo el titulo
			// color
			R = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
			G = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
			B = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
		
			for(int i=0;i<4;++i)
			{
				++nro_linea;			// rotacion numero
				topes[i] = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
				anchos[i] = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
				
				++nro_linea;			// posiciones
				for(int j=0;j<4;++j)
				{
					x[4*i+j] = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
					y[4*i+j] = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
				}
				++nro_linea;			// topes
				for(int j=0;j<4;++j)
				{
					tx[4*i+j] = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
					ty[4*i+j] = atoi([[lines objectAtIndex:nro_linea++] UTF8String]);
				}
			}
			
			[file dealloc];
		}
		
		
	}
	return self;

}


-initWithFigura:(figura *) p
{
	int i;
	int j;

	tipo_pieza = p->tipo_pieza;
	cant_piezas = p->cant_piezas;
	R = p->R;
	G = p->G;
	B = p->B;
	for(i=0;i<4;++i)
	{
		topes[i] = p->topes[i];
		anchos[i] = p->anchos[i];
		for(j=0;j<4;++j)
		{
			x[4*i+j] = p->x[4*i+j];
			y[4*i+j] = p->y[4*i+j];
		}
		for(j=0;j<4;++j)
		{
			tx[4*i+j] = p->tx[4*i+j];
			ty[4*i+j] = p->ty[4*i+j];
		}
	}
	fil = p->fil;
	col = p->col;
	rotacion = p->rotacion;
	return self;
}



-(figura *)duplicar
{
	figura *rta = [figura new];
	[rta initWithFigura:self];
	return rta;
}



-(NSInteger) ancho
{
	return anchos[rotacion];
}


-(NSInteger)  cant_topes
{
	return topes[rotacion];
}

-(NSInteger) posX:(NSInteger) pieza
{
		return col+x[rotacion*4+pieza];
}

-(NSInteger) posY:(NSInteger) pieza
{
	return fil+y[rotacion*4+pieza];
}

-(NSInteger) topeX:(NSInteger) pieza
{
	return col+tx[rotacion*4+pieza];
}

-(NSInteger) topeY:(NSInteger) pieza
{
	return fil+ty[rotacion*4+pieza];
}

-(void) dibujar:(CGContextRef)pDC con_tablero:(tablero *)T
{
	[self dibujar:pDC con_ox:[T ox] con_oy:[T oy] con_cdx:[T cdx] con_cdy:[T cdy] 
		con_offset_x:[T offset_x] con_offset_y:[T offset_y] con_angulo:[T offset_angulo]];
}

-(void) dibujar:(CGContextRef)pDC con_ox:(int)ox con_oy:(int)oy con_cdx:(int)cdx con_cdy:(int)cdy con_offset_x:(int)offset_x con_offset_y:(int)offset_y
{
	
	CGContextSetRGBStrokeColor(pDC,(float)R/455.0,(float)G/455.0,(float)B/455.0,1);
	CGContextSetRGBFillColor(pDC,(float)R/255.0,(float)G/255.0,(float)B/255.0,1);
	for(int i=0;i<cant_piezas;++i)
	{
		int X = [self posX:i];
		int Y = [self posY:i];
		
		CGContextFillRect(pDC,CGRectMake(ox+X*cdx+offset_x,oy+Y*cdy+offset_y ,cdx-1,cdy-1));
		CGContextStrokeRectWithWidth(pDC, CGRectMake(ox+X*cdx+offset_x+1,oy+Y*cdy+offset_y+1 ,cdx-2,cdy-2),1);
		
	}
}

-(void) dibujar:(CGContextRef)pDC con_ox:(int)ox con_oy:(int)oy con_cdx:(int)cdx con_cdy:(int)cdy con_blending:(float)alpha
{
	CGContextSetRGBStrokeColor(pDC,(float)R/455.0,(float)G/455.0,(float)B/455.0,alpha);
	CGContextSetRGBFillColor(pDC,(float)R/255.0,(float)G/255.0,(float)B/255.0,alpha);
	for(int i=0;i<cant_piezas;++i)
	{
		int X = [self posX:i];
		int Y = [self posY:i];
		
		CGContextFillRect(pDC,CGRectMake(ox+X*cdx,oy+Y*cdy ,cdx-1,cdy-1));
		CGContextStrokeRectWithWidth(pDC, CGRectMake(ox+X*cdx+1,oy+Y*cdy+1 ,cdx-2,cdy-2),1);
		
	}
}


-(void) dibujar:(CGContextRef)pDC con_ox:(int)ox con_oy:(int)oy con_cdx:(int)cdx con_cdy:(int)cdy con_offset_x:(int)offset_x con_offset_y:(int)offset_y con_angulo:(int)angulo
{
	if(angulo)
	{
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSaveGState(context);
	
		int cx = ox + (col+2)*cdx;
		int cy = oy + (fil+2)*cdy;

		CGContextTranslateCTM(pDC,cx,cy);
		CGContextRotateCTM(pDC,angulo*M_PI/180.0);
		CGContextTranslateCTM(pDC,-cx,-cy);

		[self dibujar:pDC con_ox:ox con_oy:oy con_cdx:cdx con_cdy:cdy con_offset_x:offset_x con_offset_y:offset_y];

	
		CGContextRestoreGState(context);
	}
	else {
		[self dibujar:pDC con_ox:ox con_oy:oy con_cdx:cdx con_cdy:cdy con_offset_x:offset_x con_offset_y:offset_y];
	}

}


-(void) moverPieza:(tablero *)T con_dx: (int) px con_dy:(int) py
{
	int ant_col = col;
	int ant_fil = fil;
	
	int dx = [self ancho];
	col+=px;
	if(col<0)
		col=0;
	if(col+dx>MAX_COL)
			col=MAX_COL-dx;
	fil+=py;

	if(![T posValida])
	{
		col = ant_col;
		fil = ant_fil;
	
	}
	
}

-(void) moverPiezaToXY:(tablero *)T con_posx:(int) px con_posy:(int) py
{	
	int dy = py - fil;
	if(dy<0)
		dy = 0;
	[self moverPieza: T con_dx: px-col con_dy:0];
	
}


-(void)rotarPiezaD:(tablero *)T
{
	int ant_rot = rotacion;
	if((++rotacion)>=4)
		rotacion=0;
	if(![T posValida])
   		rotacion = ant_rot;
}
	
-(void)rotarPiezaI:(tablero *)T
{
	int ant_rot = rotacion;
	if((--rotacion)<0)
		rotacion=3;
	if(![T posValida])
   		rotacion = ant_rot;
}



@end


