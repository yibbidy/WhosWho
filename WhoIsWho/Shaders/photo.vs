// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

attribute vec4 inPosition;
attribute vec2 inUV;

uniform mat4 kMVPMat;
uniform float kScale;

varying lowp vec2 gUV;

void main()
{
    gUV = inUV;
    
    gl_Position = kMVPMat * vec4(inPosition.xyz*kScale, 1);
}
