//
//  Shader.fsh
//  TileView
//
//  Created by user on 19/07/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
