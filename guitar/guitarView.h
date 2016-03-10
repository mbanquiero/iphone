//
//  guitarView.h
//  guitar
//
//  Created by user on 15/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#define MAX_DEDOS		4

@interface guitarView : UIView {
	
	int cant_dedos;
	CGPoint pos_dedo[MAX_DEDOS];
	UITouch *dedo[MAX_DEDOS];
	
	

}

-(void) actualizar;

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
@end
