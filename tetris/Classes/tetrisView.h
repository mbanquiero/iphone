//
//  tetrisView.h
//  tetris
//
//  Created by user on 06/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FIGURAS.H"
#import "TABLERO.H"

@interface tetrisView : UIView {
		float elapsed_time;
		float timer_bajar_fila;
		NSTimeInterval touch_begin;
		int cant_filas_abajo;
		float timer_rotar;
		float timer_pos_x;
		int cant_frames;
		char eventoInterno;
		CGPoint pos,posant;
		tablero *tablero_local;
		float vel;					// lineas x segundos
		float trot;					// tiempo que tarda en girar 90 grados
		bool rot_derecha;
		int dcol;
		NSTimer *timer;
		long cur_time;
	
		
}
-(void) refreshScreen;
-(void) updateFrame:(CFTimeInterval) timeElapsed;
-(void)cargar_piezas;

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;

@end
