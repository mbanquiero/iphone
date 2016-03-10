//
//  Shader.vsh
//  Sprite
//
//  Created by Ignacio Liverotti on 05/02/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

attribute vec4 position;
attribute vec4 color;

varying vec4 colorVarying;

uniform float translate;

void main()
{
    gl_Position = position;
    gl_Position.y += sin(translate) / 2.0;

    colorVarying = color;
}
