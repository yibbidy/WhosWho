// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)
//

#include "gfx.h"
#include "utilities.h"
#include <vector>

using namespace std;


int GFX_LoadGLSLProgram(const char * inVS, const char * inFS, GLuint & outProgram, ...)
//  e.g.,
//  GFX_LoadGLSLProgram(vs, fs, programID, 
//      eGLSLBindingAttribute, "inPosition", &position,
//      eGLSLBindingAttribute, "inNormal", &normal,
//      eGLSLBindingUniform, "kUniform1", &uniform1,
//      eGLSLBindingUniform, "kUniform2", &uniform2,
//      eGLSLBindingEnd);
{
    int errorCode = 0;
    
    char infoLog[1024];
    int len;
    GLint compileStatus;
    
    GLuint vShader = 0;
    GLuint fShader = 0;
    
    if( !errorCode ) {
        vShader = glCreateShader(GL_VERTEX_SHADER);
        glShaderSource(vShader, 1, &inVS, 0);
        glCompileShader(vShader);
    
        glGetShaderInfoLog(vShader, 1024, &len, infoLog);
        glGetShaderiv(vShader, GL_COMPILE_STATUS, &compileStatus);
        if( compileStatus == GL_FALSE ) {
            errorCode = 1;
        }
    }
    
    if( !errorCode ) {
        fShader = glCreateShader(GL_FRAGMENT_SHADER);
        glShaderSource(fShader, 1, &inFS, 0);
        glCompileShader(fShader);
    
        glGetShaderInfoLog(fShader, 1024, &len, infoLog);
        glGetShaderiv(fShader, GL_COMPILE_STATUS, &compileStatus);
        if( compileStatus == GL_FALSE ) {
            errorCode = 2;
        }
    }
    
    if( !errorCode ) {
        GLint linkStatus;
        
        outProgram = glCreateProgram();
        glAttachShader(outProgram, vShader);
        glAttachShader(outProgram, fShader);
        
        glLinkProgram(outProgram);
        
        glGetProgramInfoLog(outProgram, 1024, &len, infoLog);
        glGetProgramiv(outProgram, GL_LINK_STATUS, &linkStatus);
        if( linkStatus == GL_FALSE ) {
            errorCode = 3;  // failed to link
        }
    }
    
    if( !errorCode ) {
        typedef pair<char *, int *> GLSLIdentifier;
    
        vector<GLSLIdentifier> uniforms;
        vector<GLSLIdentifier> attribs;
    
        va_list args;
        va_start(args, outProgram);
    
        EGLSLBinding bindingType;
        while( (bindingType = va_arg(args, EGLSLBinding)) != eGLSLBindingEnd && !errorCode ) 
        // extract the vertex attrib and uniform names so we can get their id later
        {
        
            vector<GLSLIdentifier> & array = (bindingType==eGLSLBindingAttribute) ? attribs : uniforms;
        
            char * name = va_arg(args, char *);
            int * id = va_arg(args, int *);
            
            if( !id ) {
                errorCode = 4;  // bad attrib parameter
            }
            array.push_back(GLSLIdentifier(name, id));
        }
            
        
        for( size_t i=0; i<attribs.size() && !errorCode; i++ ) {
            char * name = attribs[i].first;
            int * id = attribs[i].second;
            
            *id = glGetAttribLocation(outProgram, name);
            if( *id == -1 ) {
                errorCode = 5;  // attrib not found
            }
            
        }

    
        for( size_t i=0; i<uniforms.size() && !errorCode; i++ ) {
            char * name = uniforms[i].first;
            int * id = uniforms[i].second;
        
            *id = glGetUniformLocation(outProgram, name);
            if( *id == -1 ) {
                errorCode = 6;  // uniform not found
            }
        }

        va_end(args);
    }
    
    if( errorCode > 0 ) {
        glDeleteProgram(outProgram);
        outProgram = 0;
        glDeleteShader(vShader);
        glDeleteShader(fShader);
    }
    
    return errorCode;
    
}

bool GFX_ValidateProgram(GLuint prog)
{
                        
    GLint logLength, status;
    vector<char> log;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        log.resize(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, &log[0]);
        //NSLog(@"Program validate log:\n%s", log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return false;
    }
    
    return true;
}
