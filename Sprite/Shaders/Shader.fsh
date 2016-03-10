//
//  Shader.fsh
//  Sprite
//
//  Created by Ignacio Liverotti on 05/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
