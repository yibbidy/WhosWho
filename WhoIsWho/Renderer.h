// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Renderer_h
#define Renderer_h

#include "utilities.h"
#include "WhosWho.h"
#include <string>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>


enum EGLSLBinding {
    eGLSLBindingUniform,
    eGLSLBindingAttribute,
    eGLSLBindingEnd
};

int GFX_LoadGLSLProgram(const char * inVS, const char * inFS, GLuint & outProgram, ...);

struct ColorProgram {
    GLuint _program;
    GLint _positionLoc, _uvLoc;  // vertex attribute
    GLint _colorLoc, _mvpMatLoc, _imageTexture, _imageWeight;  // uniforms
};

struct PhotoProgram
// this glsl program is used to draw the photos on the rings
{
    GLuint _program;
    GLint _positionLoc, _uvLoc;
    GLint _mvpLoc, _scaleLoc, _imageTexLoc, _imageAlphaLoc, _maskTexLoc, _maskWeightLoc;
};


class GLData
{
public:
    int Init();
    int DeInit();
    int RenderScene();
    
    ColorProgram _colorProgram;
    PhotoProgram _photoProgram;
    
    GLuint _diskVAO;  // run disk geometry through color program
    GLuint _diskInnerEdgeVAO;  // to emphasize the inner edge of the ring
    GLuint _diskOuterEdgeVAO;  // to emphasize the outer edge of the ring
    GLuint _diskVBO;  // disk geometry; vert[i] normal[i] interleaved triangle_strip
    int _diskNumVertices;
    glm::mat4 _diskTransform;
    
    GLuint _squareVAO;  // used for photos with photo shader
    GLuint _squareIBO;
    GLuint _squareVBO;
    
    GLuint _squareEdgeVAO;  // used for selected photo
    GLuint _squareEdgeIBO;
    
    GLuint _faceListVAO;  // used for drawing the list of faces through the color program
    
    std::string _image; // image resource name (into gGame._images) of the image to bind for the photo shader
    std::string _mask0, _mask1;  // image resource names (into gGame._images) of the mask images
};

struct SprayPaintArgs {
	SprayPaintArgs() {
		_erase = false;
		_brushSize = 18;
		_pressure = 23;
        
		_r = 1;
		_g = 0;
		_b = 0;
	}
    
	bool	_erase;
	int		_brushSize;
	int		_pressure; // added (or subtracted if erase is true) to alpha
	double	_r, _g, _b;
};

void IMG_Clear(ImageInfo & inImage);
int IMG_SprayPaint(ImageInfo & inImage, int inLastX, int inLastY, int inCurrX, int inCurrY, const SprayPaintArgs & inArgs);
    

void DrawFaceList(float inDropdownAnim);
void DrawToolList(float inRotation);

void DrawRing(who::Ring & inRing, bool inZoomedIn, const glm::mat4 & inMVPMat);
void MarkupMask(float inRotation);


extern GLData gGLData;



#endif // Renderer_h
