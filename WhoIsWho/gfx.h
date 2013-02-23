// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef test_gfx_h
#define test_gfx_h

#include <OpenGLES/ES2/gl.h>


enum EGLSLBinding {
    eGLSLBindingUniform,
    eGLSLBindingAttribute,
    eGLSLBindingEnd
};

bool GFX_ValidateProgram(GLuint prog);   
int GFX_LoadGLSLProgram(const char * inVS, const char * inFS, GLuint & outProgram, ...);


#endif
