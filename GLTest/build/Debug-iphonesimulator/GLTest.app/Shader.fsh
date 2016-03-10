//
//  Shader.fsh
//  GLTest
//
//  Created by user on 27/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
