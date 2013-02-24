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
    GLuint program;
    GLint positionLoc, uvLoc;  // vertex attribute
    GLint colorLoc, mvpMatLoc, imageTexture, imageWeight;  // uniforms
};

struct PhotoProgram
// this glsl program is used to draw the photos on the rings
{
    GLuint program;
    GLint positionLoc, uvLoc;
    GLint mvpLoc, scaleLoc, imageTexLoc, imageAlphaLoc, maskTexLoc, maskWeightLoc;
};


class GLData
{
public:
    int Init();
    int DeInit();
    int RenderScene();
    
    ColorProgram colorProgram;
    PhotoProgram photoProgram;
    
    float viewMat[16];
    float projectionMat[16];
    float mvpMat[16];
    float normalMat[16];
    
    int viewport[4];
    
    GLuint diskVAO;  // run disk geometry through color program
    GLuint diskInnerEdgeVAO;  // to emphasize the inner edge of the ring
    GLuint diskOuterEdgeVAO;  // to emphasize the outer edge of the ring
    GLuint diskVBO;  // disk geometry; vert[i] normal[i] interleaved triangle_strip
    int diskNumVertices;
    float diskTransform[16];
    
    GLuint squareVAO;  // used for photos with photo shader
    GLuint squareIBO;
    GLuint squareVBO;
    
    GLuint squareEdgeVAO;  // used for selected photo
    GLuint squareEdgeIBO;
    
    GLuint faceListVAO;  // used for drawing the list of faces through the color program
    
    std::string image; // image resource name (into gGame.images) of the image to bind for the photo shader
    std::string mask0, mask1;  // image resource names (into gGame.images) of the mask images
    
    
};

struct SprayPaintArgs {
	SprayPaintArgs() {
		erase = false;
		brushSize = 18;
		pressure = 23;
        
		r = 1;
		g = 0;
		b = 0;
	}
    
	bool	erase;
	int		brushSize;
	int		pressure; // added (or subtracted if erase is true) to alpha
	double	r, g, b;
};

void IMG_Clear(ImageInfo & inImage);
int IMG_SprayPaint(ImageInfo & inImage, int inLastX, int inLastY, int inCurrX, int inCurrY, const SprayPaintArgs & inArgs);
    

void DrawFaceList(float inDropdownAnim);
void DrawToolList(float inRotation);

void DrawRing(who::Ring & inRing, bool inZoomedIn, float * inMVPMat);
void MarkupMask(float inRotation);


extern GLData gGLData;



#endif // Renderer_h
