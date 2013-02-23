// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

attribute vec4 inPosition;
attribute vec2 inUV;

uniform mat4 kMVPMat;

varying lowp vec2 gUV;

void main()
{
    gl_Position = kMVPMat * inPosition;
    gUV = inUV;
}
