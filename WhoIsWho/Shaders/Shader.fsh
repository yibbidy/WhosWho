//
//  Shader.fsh
//  WhoIsWho
//
//  Created by Hongbing  Carter on 2/22/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
