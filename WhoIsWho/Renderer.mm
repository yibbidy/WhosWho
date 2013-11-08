// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

// TODO this file should be the one that issues opengl calls
// functions related to drawing the scene are in here
// TODO change math to use glm

#include "Renderer.h"
#include "WhosWho.h"
#include "Camera.h"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_transform.hpp"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// TODO this class should be renamed Renderer
GLData gGLData;

int GLData::Init()
{
    int errorCode = 0;


    if( !errorCode ) {  // load the glsl photo program
        NSString * vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"vs"];
        NSString * fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"fs"];
        
        GLchar * vSource = (GLchar *)[[NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        GLchar * fSource = (GLchar *)[[NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        errorCode = GFX_LoadGLSLProgram(vSource, fSource, gGLData._photoProgram._program,
                                  eGLSLBindingAttribute, "inPosition", &gGLData._photoProgram._positionLoc,
                                  eGLSLBindingAttribute, "inUV", &gGLData._photoProgram._uvLoc,
                                  eGLSLBindingUniform, "kMVPMat", &gGLData._photoProgram._mvpLoc,
                                  eGLSLBindingUniform, "kScale", &gGLData._photoProgram._scaleLoc,
                                  eGLSLBindingUniform, "kImageTex", &gGLData._photoProgram._imageTexLoc,
                                  eGLSLBindingUniform, "kImageAlpha", &gGLData._photoProgram._imageAlphaLoc,
                                  eGLSLBindingUniform, "kMaskTex", &gGLData._photoProgram._maskTexLoc,
                                  eGLSLBindingUniform, "kMaskWeight", &gGLData._photoProgram._maskWeightLoc,
                                  eGLSLBindingEnd);
    }

    if( !errorCode ) {  // load the color glsl program
        NSString * vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"uniformColor" ofType:@"vs"];
        NSString * fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"uniformColor" ofType:@"fs"];
        
        GLchar * vSource = (GLchar *)[[NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        GLchar * fSource = (GLchar *)[[NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        errorCode = GFX_LoadGLSLProgram(vSource, fSource, gGLData._colorProgram._program,
                                  eGLSLBindingAttribute, "inPosition", &gGLData._colorProgram._positionLoc,
                                  eGLSLBindingAttribute, "inUV", &gGLData._colorProgram._uvLoc,
                                  eGLSLBindingUniform, "kMVPMat", &gGLData._colorProgram._mvpMatLoc,
                                  eGLSLBindingUniform, "kColor", &gGLData._colorProgram._colorLoc,
                                  eGLSLBindingUniform, "kImageTexture", &gGLData._colorProgram._imageTexture,
                                  eGLSLBindingUniform, "kImageWeight", &gGLData._colorProgram._imageWeight,
                                  eGLSLBindingEnd);
    }

    if( !errorCode ) {  // generate vbos and vaos
        
        // generate the vbo and vao for disk
        glGenVertexArraysOES(1, &gGLData._diskVAO);
        glBindVertexArrayOES(gGLData._diskVAO);
        
        glGenBuffers(1, &gGLData._diskVBO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData._diskVBO);
        std::vector<float> verts, normals, texCoords;
        GEO_GenerateDisc(-90, 270, who::kR0, who::kR1, 0, 64, verts, normals, texCoords, 0);
        gGLData._diskNumVertices = verts.size()/3;
        unsigned int size = verts.size()*sizeof(float);
        glBufferData(GL_ARRAY_BUFFER, size, &verts[0], GL_STATIC_DRAW);
        glEnableVertexAttribArray(gGLData._colorProgram._positionLoc);
        glVertexAttribPointer(gGLData._colorProgram._positionLoc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
        
        
        glGenVertexArraysOES(1, &gGLData._diskInnerEdgeVAO);
        glBindVertexArrayOES(gGLData._diskInnerEdgeVAO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData._diskVBO);
        glEnableVertexAttribArray(gGLData._colorProgram._positionLoc);
        glVertexAttribPointer(gGLData._colorProgram._positionLoc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), BUFFER_OFFSET(0));
        
        glGenVertexArraysOES(1, &gGLData._diskOuterEdgeVAO);
        glBindVertexArrayOES(gGLData._diskOuterEdgeVAO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData._diskVBO);
        glEnableVertexAttribArray(gGLData._colorProgram._positionLoc);
        glVertexAttribPointer(gGLData._colorProgram._positionLoc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), BUFFER_OFFSET(3*sizeof(float)));
        
        
        glGenVertexArraysOES(1, &gGLData._squareVAO);
        glBindVertexArrayOES(gGLData._squareVAO);
        GEO_GenerateRectangle(1, 1, verts, normals, texCoords);
        glGenBuffers(1, &gGLData._squareVBO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData._squareVBO);
        glBufferData(GL_ARRAY_BUFFER, verts.size()*sizeof(float)+texCoords.size()*sizeof(float), 0, GL_STATIC_DRAW);
        
        glBufferSubData(GL_ARRAY_BUFFER, 0, verts.size()*sizeof(float), &verts[0]);
        glBufferSubData(GL_ARRAY_BUFFER, verts.size()*sizeof(float), texCoords.size()*sizeof(float), &texCoords[0]);
        
        glGenBuffers(1, &gGLData._squareIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gGLData._squareIBO);
        int indices[] = { 0, 1, 2, 3 };
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4*sizeof(int), indices, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(gGLData._photoProgram._positionLoc);
        glVertexAttribPointer(gGLData._photoProgram._positionLoc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(gGLData._photoProgram._uvLoc);
        glVertexAttribPointer(gGLData._photoProgram._uvLoc, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(verts.size()*sizeof(float)));
        
        
        glGenVertexArraysOES(1, &gGLData._squareEdgeVAO);
        glBindVertexArrayOES(gGLData._squareEdgeVAO);
        glGenBuffers(1, &gGLData._squareEdgeIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gGLData._squareEdgeIBO);
        int indices2[] = { 0, 1, 3, 2 };
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*4, &indices2[0], GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData._squareVBO);
        glEnableVertexAttribArray(gGLData._colorProgram._positionLoc);
        glVertexAttribPointer(gGLData._colorProgram._positionLoc, 3, GL_FLOAT, GL_FALSE, 0, 0);
        
        
        glGenVertexArraysOES(1, &gGLData._faceListVAO);
        glBindVertexArrayOES(gGLData._faceListVAO);
        
        glBindBuffer(GL_ARRAY_BUFFER, gGLData._squareVBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gGLData._squareIBO);
        
        glEnableVertexAttribArray(gGLData._colorProgram._positionLoc);
        glVertexAttribPointer(gGLData._colorProgram._positionLoc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(gGLData._colorProgram._uvLoc);
        glVertexAttribPointer(gGLData._colorProgram._uvLoc, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(verts.size()*sizeof(float)));
        
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
    }
    
    return errorCode;
}

int GLData::DeInit()
{
    int errorCode = 0;
    
    // deallocate vbos, vaos, programs
    glDeleteBuffers(1, &gGLData._diskVBO);
    glDeleteVertexArraysOES(1, &gGLData._diskVAO);

    glDeleteBuffers(1, &gGLData._squareVBO);
    glDeleteVertexArraysOES(1, &gGLData._squareVAO);

    glDeleteProgram(gGLData._photoProgram._program);
    glDeleteProgram(gGLData._colorProgram._program);
    
    return errorCode;
}


void sDrawDrawer(float inDropdownAnim)
{
    
    // draw face list
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(gGLData._colorProgram._program);
    glBindVertexArrayOES(gGLData._squareVAO);
    glUniform4f(gGLData._colorProgram._colorLoc, 0, 0, 1, 1);
    glUniform1f(gGLData._colorProgram._imageWeight, 0);
    glUniform1i(gGLData._colorProgram._imageTexture, 0);
    glActiveTexture(GL_TEXTURE0);
    
    float height = 0.07f;
    float width = 0.1f;
    
    int currentRingZ = gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
    
    glm::vec3 corners[4];
    ComputeTopPhotoCorners(gGame._rings._rings[gGame._rings._currentRing], corners);
    float top = (who::kR1+who::kR0)*0.5f + corners[2].y;
    width = corners[0].x - corners[1].x;
    float dy = height * glm::abs(glm::sin(inDropdownAnim));
    glm::mat4 mat = glm::scale(glm::translate(gGame._camera._vpMat, glm::vec3(0, top-dy*0.5f, -currentRingZ+0.001f)),
                               glm::vec3(width, dy, 1));
    glUniform4f(gGLData._colorProgram._colorLoc, 0.8f, 0.8f, 0.8f, 0.5f);
    glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    int numItems = int(gGame._drawers[gGame._currentDrawer]._photos.size());
    
    int xSpacing = 0;
    float centerX = -width*0.5f + height*0.5f;
    float xInc = height + xSpacing;
    
    centerX += xSpacing;
    if( width / height >= numItems )
        // simple layout of faces
    {
        xInc = width / numItems;
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
    }
    else
        // shrink face images down to fit them all
    {
        xInc = width / numItems;
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
        height = xInc;
        dy = height * glm::abs(glm::sin(inDropdownAnim));
        
    }
    
    for_i( numItems ) {
        mat = glm::scale(glm::translate(gGame._camera._vpMat, glm::vec3(centerX, top-dy*0.5f, -currentRingZ+0.01f)),
                         glm::vec3(height, dy, 1));
        glUniform4f(gGLData._colorProgram._colorLoc, 0.8f, 0.8f, 0.8f, 1);
        glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
        glBindTexture(GL_TEXTURE_2D, gGame._images[gGame._drawers[gGame._currentDrawer]._photos[i]].texID);
        glUniform1f(gGLData._colorProgram._imageWeight, 1);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        centerX += xInc;
    }
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    
}

int GLData::RenderScene()
{
    int errorCode = 0;
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glm::mat4 mat = gGame._camera._vpMat;
    
    int currentRingZ = gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
    
    size_t startRingI = size_t(glm::max(currentRingZ-2, 0));
    size_t endRingI = gGame._rings._rings.size();
    
    if( gGame._camera._zoomed == 1 ) {
        startRingI = currentRingZ;
        endRingI = startRingI+1;
    }
    
    for( size_t i=startRingI; i < endRingI; i++ ) {
        
        who::Ring & ring = gGame._rings._rings[gGame._rings._stackingOrder[i]];
        
        glm::mat4 mvMat = glm::translate(mat, glm::vec3(0.0f, 0.0f, -float(i)));
        
        DrawRing(ring, gGame._camera._zoomed==1, mvMat);

        if( gGame._currentDrawer != "" && gGame._drawerDropAnim>0 )
        {
            sDrawDrawer(gGame._drawerDropAnim);
        }

        
    }
    
    return errorCode;
}

void DrawToolList(float inRotation) {
    
    float _rotation = inRotation;
    
    // draw tools
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(gGLData._colorProgram._program);
    glBindVertexArrayOES(gGLData._squareVAO);
    glUniform4f(gGLData._colorProgram._colorLoc, 1, 1, 1, 0.3f);
    glUniform1f(gGLData._colorProgram._imageWeight, 0);
    glUniform1i(gGLData._colorProgram._imageTexture, 0);
    glActiveTexture(GL_TEXTURE0);
    
    float height = 0.04f;
    float width = 0.1f;
    
    int currentRingZ = gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
    
    who::Ring & editRing = gGame._rings._rings[gGame._rings._currentRing];
    glm::vec3 corners[4];
    ComputeTopPhotoCorners(editRing, corners);
    float top = (who::kR0+who::kR1)*0.5f + corners[0].y + height;
    width = corners[0].x - corners[1].x;
    float dy = height * fabs(sinf(4*_rotation));
    glm::mat4 mat = glm::scale(glm::translate(mat, glm::vec3(0, top-dy*0.5f, -currentRingZ+0.01f)),
                               glm::vec3(width, dy, 1));
    glUniform4f(gGLData._colorProgram._colorLoc, 0.8f, 0.8f, 0.8f, 0.5f);
    glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    int numItems = int(gGame._faceList.size());
    
    float xSpacing = 0.01;
    float centerX = -width*0.5f + height*0.5f;
    float xInc = height + xSpacing;
    
    centerX += xSpacing;
    if( width / height >= numItems ) {  // simple placement
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
    } else {  // shrink images down
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
        height = xInc;
        dy = height * fabs(sinf(4*_rotation));
        
    }
    
    std::string faceList[] = {
        "brush",
        "eraser",
        "scissors"
    };
    
    for_i( numItems ) {
        mat = glm::scale(glm::translate(gGame._camera._vpMat, glm::vec3(centerX, top-dy*0.5f, -currentRingZ+0.01f)),
                         glm::vec3(height, dy, 1));
        glUniform4f(gGLData._colorProgram._colorLoc, 0.8f, 0.8f, 0.8f, 1);
        glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
        glBindTexture(GL_TEXTURE_2D, gGame._images[faceList[i]].texID);
        glUniform1f(gGLData._colorProgram._imageWeight, 1);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        centerX += xInc;
    }
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    
}


void IMG_Clear(ImageInfo & inImage) {
    memset(inImage.image, 0, inImage.texHeight*inImage.rowBytes);
    
    glBindTexture(GL_TEXTURE_2D, inImage.texID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, inImage.texWidth, inImage.texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, inImage.image);
}

int IMG_SprayPaint(ImageInfo & inImage, int inLastX, int inLastY, int inCurrX, int inCurrY, const SprayPaintArgs & inArgs) {
    int errorCode = 0;
    
	ImageInfo * imageInfo = &inImage;
    
	bool inErase = inArgs._erase;
	unsigned char red = inArgs._r * 255;
	unsigned char green = inArgs._g * 255;
	unsigned char blue = inArgs._b * 255;
    
	int brushSize = inArgs._brushSize;
	int halfBrushSize = brushSize/2;
	//int alphaInc = inArgs.pressure;
	//halfBrushSize = 17;
    
	int w = imageInfo->texWidth;
	int h = imageInfo->texHeight;
    
	double dx = inCurrX - inLastX;
	double dy = inCurrY - inLastY;
    
	int steps = 0;
    
	//static double t = 100;
    
    
	double xInc = 0;
	double yInc = 0;
	if( fabs(dx) > fabs(dy) ) {
		steps = fabs(dx);
		xInc = (dx > 0) ? 1 : -1;
		yInc = fabs(dy / dx);
		yInc *= (dy > 0) ? 1 : -1;
	} else {
		steps = fabs(dy);
		yInc = (dy > 0) ? 1 : -1;
		xInc = fabs(dx / dy);
		xInc *= (dx > 0) ? 1 : -1;
	}
    
    glBindTexture(GL_TEXTURE_2D, inImage.texID);
	
	double currY = inLastY;
	double currX = inLastX;
    
	int B = imageInfo->bitDepth/8;
    
	static unsigned char * block = 0; // cache
	static int blockBrushSize = 18;
	static int blockBpp = 4;
	if( !block || blockBrushSize!=brushSize || blockBpp != B ) {
		blockBrushSize = brushSize;
		blockBpp = B;
		if( block ) {
			delete [] block;
		}
		block = new unsigned char[blockBpp * blockBrushSize * blockBrushSize];
	}
    
	for( int step=0; step<steps; step++ ) {
        
		currY += yInc;
		currX += xInc;
        
		int xx = (int)currX;
		int yy = (int)currY;
        
		
		memset(block, 0, 4*brushSize*brushSize);
		
		for( int y = -halfBrushSize; y<brushSize-halfBrushSize; y++ ) {
			if( yy+y>=imageInfo->texHeight || yy+y<0 ) continue;
            
			for( int x = -halfBrushSize; x<brushSize-halfBrushSize; x++ ) {
				if( xx+x >= imageInfo->texWidth || xx+x < 0 ) continue;
                
				double alphaFactor = (halfBrushSize - glm::min(double(halfBrushSize), glm::sqrt((double)y*y + x*x))) / halfBrushSize;
				alphaFactor = pow(alphaFactor, 1.7);
                
				unsigned char alphaInc = (unsigned char)glm::max(0.0, glm::min(255.0, alphaFactor * inArgs._pressure));
                
				int index1 = ((y+halfBrushSize)*brushSize + (x+halfBrushSize))*B;
				int index2 = ((yy+y)*w + xx+x)*B;
                
				if( inErase ) {
					int alpha = imageInfo->image[index2+3];
					alpha = glm::max(0, int(alpha-(alphaInc*0.5)));
					imageInfo->image[index2+3] = (unsigned char)alpha;
                    
				} else {
					imageInfo->image[index2+0] = red;
					imageInfo->image[index2+1] = green;
					imageInfo->image[index2+2] = blue;
                    
					unsigned char alpha = imageInfo->image[index2+3];
					alpha = (unsigned char)glm::min(255, int(alpha)+alphaInc);
					
					imageInfo->image[index2+3] = alpha;
					
				}
                
				block[index1+0] = imageInfo->image[index2+0];
				block[index1+1] = imageInfo->image[index2+1];
				block[index1+2] = imageInfo->image[index2+2];
				block[index1+3] = imageInfo->image[index2+3];
                
			}
		}
        
		int xSize = brushSize;
		int xOffset = xx-halfBrushSize;
        if( xOffset > w ) {
            continue;
        }
		unsigned char * blockStart = &block[0];
		if( xOffset < 0 ) {
			xSize = brushSize + xOffset;
			blockStart += -xOffset * blockBpp;
			xOffset = 0;
		}
		int rOffset = xx+halfBrushSize;
		if( rOffset >= w ) {
			xSize = brushSize - (rOffset-w) - 1;
		}
		
		int ySize = brushSize;
		int yOffset = yy-halfBrushSize;
        if( yOffset > h ) {
            continue;
        }
		if( yOffset < 0 ) {
			ySize = brushSize + yOffset;
			blockStart += -yOffset*blockBrushSize * blockBpp;
			yOffset = 0;
		}
		int bOffset = yy+halfBrushSize;
		if( bOffset >= h ) {
			ySize = brushSize - (bOffset-h) - 1;
		}
        
		glTexSubImage2D(GL_TEXTURE_2D, 0, xOffset, yOffset, xSize, ySize, GL_RGBA, GL_UNSIGNED_BYTE, blockStart);
	}
    
    
	return errorCode;
}




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
        typedef std::pair<char *, int *> GLSLIdentifier;
        
        std::vector<GLSLIdentifier> uniforms;
        std::vector<GLSLIdentifier> attribs;
        
        va_list args;
        va_start(args, outProgram);
        
        EGLSLBinding bindingType;
        while( (bindingType = va_arg(args, EGLSLBinding)) != eGLSLBindingEnd && !errorCode )
            // extract the vertex attrib and uniform names so we can get their id later
        {
            
            std::vector<GLSLIdentifier> & array = (bindingType==eGLSLBindingAttribute) ? attribs : uniforms;
            
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
#if 0 //lamda function 
#include <functional>

class A
{
public:
    void f()
    {
        
    }
    
private:
    int i;
};

class B
{
public:
    void abc()
    {
        A a;
        
        std::function<void()> callback = std::bind(&A::f, a);
        f2(callback);
        
         
        // do stuff
    }
};

void f2(std::function<void()> callback)
{
    callback();
}

void f1()
{
    auto abc = 5;
    
    A a;
    
   // std::function<void()> callback = std::bind(&A::f, a);
    
    A b;
    
    std::function<void()> callback = std::bind(&A::f, a);
   
    
    f2(std::bind(&A::f, a));
    
    int jj;
    f2( []() -> void
       {
           int j = 2;
           j++;
       }
       );
    
    
}
#endif 
void DrawFaceList(who::Ring & inRing, const glm::mat4 & inMVPMat, float w2, float h2, float radius)
{
    
    for( int i=0; i<inRing.facePhotos.size(); i++ ) {
        
        float t ;//= (i-inRing._currentPhoto)/float(halfNumImages);
        float halfStep;// = 0.5f/halfNumImages;
        
        
        who::Photo * photo = gGame.GetPhoto(inRing.facePhotos[i]);
        ImageInfo & image = gGame._images[photo->_filename];
        float aspect = image.originalWidth / float(image.originalHeight);
        float w, h;
        float length = .03f;
        // compute world space width and height based on image's aspect ratio
        if( aspect > 1 ) {
            w = length;
            h = length / aspect;
        } else {
            w = length * aspect;
            h = length;
        }
        
        // build the matrix that transforms normalzied image corners to world space
        //float radius = 0.8f;
        //glm::mat4 mat = glm::mat4(glm::scale(glm::translate(glm::mat4(1),
        //                                                    glm::vec3(0, radius+h, 0.02f)),
        //                                     glm::vec3(w, h, 1)));
        
        glm::mat4 mat = glm::translate(glm::mat4(1), glm::vec3(0, radius + h2/2 + h/2, 0.010001f));
        mat = glm::scale(mat, glm::vec3(w, h, 1));
        
        
        

        /*float mat[16];
         MAT4_MakeScale(w, h, 1, mat);
         MAT4_PreTranslate(0, radius, 0.01f, mat);
         MAT4_PreRotate(0, 0, 1, -angle, mat);
         */
        //MAT4_Equate(mat, photo->_transform);
        photo->_transform = glm::mat4x3(mat);
        
        //MAT4_Multiply(inMVPMat, mat, mat);
        mat = inMVPMat * mat;
        
        float fl[16];
        memcpy(fl, &mat[0][0], 16*sizeof(float));
        
        glUniformMatrix4fv(gGLData._photoProgram._mvpLoc, 1, GL_FALSE, &mat[0][0]);
        glUniform1f(gGLData._photoProgram._scaleLoc, 1);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, image.texID);
        glActiveTexture(GL_TEXTURE1);
        
        if( photo->_maskImages.size() > 0 ) {
            glBindTexture(GL_TEXTURE_2D, gGame._images[photo->_maskImages[0]].texID);
        }
        glActiveTexture(GL_TEXTURE2);
        if( photo->_maskImages.size() > 1 ) {
            glBindTexture(GL_TEXTURE_2D, gGame._images[photo->_maskImages[1]].texID);
        }
        float maskWeights[2];
        memset(maskWeights, 0, 2*sizeof(float));
        
        for_i( photo->_maskWeights.size() ) {
            maskWeights[i] = photo->_maskWeights[i];
        }
      
        glUniform1fv(gGLData._photoProgram._maskWeightLoc, 2, maskWeights);
        
        
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
    }
}
void DrawRing(who::Ring & inRing, bool inZoomedIn, const glm::mat4 & inMVPMat) {
    
 //   f1();
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);//(GL_BLEND);
    
    // Draw the ring (a disc)
    glUseProgram(gGLData._colorProgram._program);
    
    glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &inMVPMat[0][0]);
    glUniform4f(gGLData._colorProgram._colorLoc, 0.2f, 0.3f, 1, inRing._ringAlpha);//0.8f);
    glUniform1f(gGLData._colorProgram._imageWeight, 0);
    glUniform1i(gGLData._colorProgram._imageTexture, 0);
    glBindVertexArrayOES(gGLData._diskVAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, gGLData._diskNumVertices);  // draw blue ring
    
    glm::mat4 mat = glm::translate(inMVPMat, glm::vec3(0, 0, 0.001f));
    glUseProgram(gGLData._colorProgram._program);
    glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
    glUniform4f(gGLData._colorProgram._colorLoc, 0, 0, 0, 1);
        //glUniform4f(gGLData.colorProgram.colorLoc, 0, 0, 0, inRing._ringAlpha);
    glBindVertexArrayOES(gGLData._diskInnerEdgeVAO);
    glLineWidth(4.0f);
    glDrawArrays(GL_LINE_STRIP, 0, gGLData._diskNumVertices/2);  // black outer edge
    
    glBindVertexArrayOES(gGLData._diskOuterEdgeVAO);
    double percentage = gGame._totalPhotosToDownload>0?(float)(inRing._photos.size()-gGame._currentNumOfPhotos)/(float)gGame._totalPhotosToDownload:1.0;
        
    static float lineWidth = 4;
    glLineWidth(lineWidth);
    glDrawArrays(GL_LINE_STRIP, 0, int(percentage * gGLData._diskNumVertices/2));  // inerr edge

    glLineWidth(4);  // restore line width
    
    ///// draw progress ring and draw cancel image (green X)
    if (percentage > 0.0f && percentage < 1.0f && inRing._ringType == who::eRingTypePlay && inRing._name=="playRing" ) {
        
        float x = glm::cos(-kPi/2 + 2*kPi*percentage) * who::kR0;
        float y = -glm::sin(-kPi/2 + 2*kPi*percentage) * who::kR0;

        ImageInfo cancelImage =  gGame._images[cancelString];
        
        glUseProgram(gGLData._colorProgram._program);
        glBindVertexArrayOES(gGLData._squareVAO);
        glUniform1f(gGLData._colorProgram._imageWeight, 1);
        glUniform1i(gGLData._colorProgram._imageTexture, 0);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, cancelImage.texID);
        //float ratio = gGame.cancelImage.originalHeight/gGame.cancelImage.originalWidth;
        
        mat = glm::mat4(glm::scale(glm::translate(glm::mat4(1),glm::vec3(x, y, 0.01f)),glm::vec3(0.1, 0.1, 1)));
        gGame._photos[cancelString]._transform = glm::mat4x3(mat);
        
        mat = inMVPMat * mat;
    
        glUniform4f(gGLData._colorProgram._colorLoc, 1.0f, 1.0f, 1.0f, 0.5f);
        glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    ///////////////////////////////////////////
    // draw the images on the ring (a bunch of rects in a circle pattern)
    glUseProgram(gGLData._photoProgram._program);
    glBindVertexArrayOES(gGLData._squareVAO);
    
    glUniform1i(gGLData._photoProgram._imageTexLoc, 0);
    glUniform1f(gGLData._photoProgram._imageAlphaLoc, inRing._ringAlpha);
    
   
    glActiveTexture(GL_TEXTURE0);
    // glBindTexture(GL_TEXTURE_2D, gGame._images[0].texID);
#if 0
    int masks[] = { 1, 2 };
    glUniform1iv(gGLData.photoProgram.maskTexLoc, 2, masks);
#endif
    
    
    int numImages = int(inRing._photos.size());
    float halfNumImages = numImages * 0.5f;
    float w0 = glm::atan((who::kR1-who::kR0)/(who::kR1+who::kR0));  // end angle for 0th photo
    
    float p = glm::log(w0/kPi) / glm::log(0.5f/halfNumImages);  // of f(x) = pi x^p
    float radius = (who::kR0+who::kR1) * 0.5f;
    
    float (* spacingFn)(float, float *);
    
    if( numImages * w0 <= kPi ) {
        spacingFn = who::LinearFn;
    } else {  // space images out using t^p
        spacingFn = who::SmoothFn;
    }
    
    int startImageI = 0;
    int endImageI = numImages;
    
    if( inZoomedIn )
        // improve rendering performance by reducing the number of photos drawn when zoomed up close
    {
        if( inRing._selectedPhoto != -1 &&  inRing._selectedPhoto == inRing._currentPhoto ) {
            startImageI = inRing._selectedPhoto;
            endImageI = startImageI+1;
        } else {
            if( inRing._selectedPhoto < inRing._currentPhoto ) {  // if ring is rotating counter clockwise
                startImageI = inRing._selectedPhoto;
            } else {
                startImageI = inRing._selectedPhoto-1;
                if( startImageI < 0 ) {
                    startImageI = numImages + startImageI;
                }
            }
            endImageI = startImageI + 2;
        }
    }
    startImageI  = glm::max(0, startImageI);
    for( int imageI=startImageI; imageI<endImageI; imageI++ ) {
        int i = imageI%numImages;
        
        float t = (i-inRing._currentPhoto)/float(halfNumImages);
        float halfStep = 0.5f/halfNumImages;
        
        float angle0 = kPi * spacingFn(t-halfStep, &p);
        float angle1 = kPi * spacingFn(t+halfStep, &p);
        float angle = (angle0 + angle1) * 0.5f;
        float dAngle = (angle1 - angle0) * 0.5f;
        angle0 = angle - glm::min(w0, dAngle);
        angle1 = angle + glm::min(w0, dAngle);
        
        glm::vec2 p0 = glm::vec2(radius*glm::cos(angle0), radius*glm::sin(angle0));  // top right point in world space
        glm::vec2 p1 = glm::vec2(radius*glm::cos(angle1), radius*glm::sin(angle1));  // top left point in world space
        float length = glm::distance(p0, p1) / glm::sqrt(2.0f);  // diagonal length of the image square
       //  length = .1f;
        
        
        who::Photo * photo = gGame.GetPhoto(inRing._photos[i]);
        ImageInfo & image = gGame._images[photo->_filename];
        float aspect = image.originalWidth / float(image.originalHeight);
        float w, h;
        // compute world space width and height based on image's aspect ratio
        if( aspect > 1 ) {
            w = length;
            h = length / aspect;
        } else {
            w = length * aspect;
            h = length;
        }
        
        // build the matrix that transforms normalzied image corners to world space
        glm::mat4 mat = glm::mat4(glm::scale(glm::translate(glm::rotate(glm::mat4(1), -glm::degrees(angle), glm::vec3(0, 0, 1)),
                                    glm::vec3(0, radius, 0.01f)),
                                   glm::vec3(w, h, 1)));
        
        
        /*float mat[16];
        MAT4_MakeScale(w, h, 1, mat);
        MAT4_PreTranslate(0, radius, 0.01f, mat);
        MAT4_PreRotate(0, 0, 1, -angle, mat);
        */
        //MAT4_Equate(mat, photo->_transform);
        photo->_transform = glm::mat4x3(mat);
        
        //MAT4_Multiply(inMVPMat, mat, mat);
        mat = inMVPMat * mat;
        float fl[16];
        memcpy(fl, &mat[0][0], 16*sizeof(float));
    
        
        glUniformMatrix4fv(gGLData._photoProgram._mvpLoc, 1, GL_FALSE, &mat[0][0]);
        glUniform1f(gGLData._photoProgram._scaleLoc, 1);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, image.texID);
        glActiveTexture(GL_TEXTURE1);
        
        if( photo->_maskImages.size() > 0 ) {
            glBindTexture(GL_TEXTURE_2D, gGame._images[photo->_maskImages[0]].texID);
        }
        glActiveTexture(GL_TEXTURE2);
        if( photo->_maskImages.size() > 1 ) {
            glBindTexture(GL_TEXTURE_2D, gGame._images[photo->_maskImages[1]].texID);
        }
        float maskWeights[2];
        memset(maskWeights, 0, 2*sizeof(float));
        
        for_i( photo->_maskWeights.size() ) {
            maskWeights[i] = photo->_maskWeights[i];
        }
        
        glUniform1fv(gGLData._photoProgram._maskWeightLoc, 2, maskWeights);
        
        
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
        
        if( i == (inRing._selectedPhoto%inRing._photos.size()) )
            // the selected photo has a red box around it
        {
            glUseProgram(gGLData._colorProgram._program);
            glBindVertexArrayOES(gGLData._squareEdgeVAO);
            glUniformMatrix4fv(gGLData._colorProgram._mvpMatLoc, 1, GL_FALSE, &mat[0][0]);
            glUniform4f(gGLData._colorProgram._colorLoc, 1, 0, 0, inRing._ringAlpha);
            glDrawElements(GL_LINE_LOOP, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
            
            glUseProgram(gGLData._photoProgram._program);
            glBindVertexArrayOES(gGLData._squareVAO);
        }
        
        if (inZoomedIn) {
            DrawFaceList(inRing, inMVPMat, w, h, radius);
        }
        
    }
   
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glLineWidth(1.0f);
    
    glBindVertexArrayOES(0);
    
}

void MarkupMask(float inRotation) {
    // this function puts randomly placed dots on the mask
    static float lastP[] = {
        0, 0,
        0, 0 };
    
    float currP[] = {
        700 + 2*150*cosf(inRotation), 720 - 150*sinf(2*inRotation),
        100 + 2*50*cosf(inRotation), 150 - 50*sinf(2*inRotation) };
    
    if( lastP[0] == 0 ) {
        memcpy(lastP, currP, 4*sizeof(float));
    }
    
    SprayPaintArgs spa;
    spa._r = 1;
    spa._g = 0;
    spa._b = 0;
    spa._pressure = 20;
    spa._brushSize = 40;
    //spa.erase = true;
    IMG_SprayPaint(gGame._images[gGLData._mask0], lastP[0], lastP[1], currP[0], currP[1], spa);
    spa._r = 0;
    spa._g = 1;
    spa._b = 0;
    spa._pressure = 35;
    spa._brushSize = 10;
    //spa.erase = true;
    IMG_SprayPaint(gGame._images[gGLData._mask1], lastP[2], lastP[3], currP[2], currP[3], spa);
    
    memcpy(lastP, currP, 4*sizeof(float));
}


