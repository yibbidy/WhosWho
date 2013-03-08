// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef JHUtilities_h
#define JHUtilities_h

#include <math.h>
#include <list>
#include <vector>
#include <algorithm>
#include <cstdarg>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <fstream>
#include "glm/glm.hpp"

#define for_i(size) for( size_t i=0; i<size; i++ )
#define for_j(size) for( size_t j=0; j<size; j++ )
#define for_k(size) for( size_t k=0; k<size; k++ )

void	GEO_GenerateUnitSphere(std::vector<float> & vertices, std::vector<float> & normals);
void    GEO_GenerateDisc(float inStartAngle, float inEndAngle, float inInnerRadius, float inOuterRadius, float inZ, int inSegments, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords, float * outBoundingCube);
void    GEO_GenerateUnitCircle(int inSegments, std::vector<float> & outVertices);
void    GEO_GenerateUnitRectangle(std::vector<float> & outVertices, std::vector<float> & outTexCoords);
void    GEO_GenerateRectangle(float inWidth, float inHeight, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords);
void	GEO_ExtractFrustumPoints(float * inMVPInvertMat, float outFrustumPoints[4*8]);
bool    GEO_RayPlaneIntersection(const glm::vec3 & ptOnPlane, const glm::vec3 & planeNormal, const glm::vec3 & rayOrigin, const glm::vec3 & rayDir, float * optOutT, glm::vec3 & outIntersection);
bool    GEO_RayTriangleIntersection(const glm::vec3 & inRayOrigin, const glm::vec3 & inRayDir, const glm::vec3 * inTriangleVertices, float * outT, glm::vec3 & outIntersection);
bool	GEO_LineLineIntersection(float * inP1, float * inV1, float * inP2, float * inV2, bool inSegmentIntersection, bool & outParallel, float & outT1, float & outT2, float * outIntersection);
int		GEO_BestFitRectInRect(float * inFlexibleRect, float * inFixedRect, float * outBestFitRect);
void GEO_MakePickRay(const glm::mat4x3 & inViewMat, const glm::mat4 & inProjectionMat, const glm::ivec4 & inViewport, const glm::vec3 & inViewPt3, glm::vec3 & outRayOrigin, glm::vec3 & outRayDir);

void    BarycentricTriangleInterpolation(float * inVertices, float * inP, int inNumAttributesPerVertex, float * inAttributes, float * outAttributes);

/* Basic information about an image */
struct ImageInfo {
	ImageInfo(int width, int height, int bitDepth, int rowBytes, unsigned char * image);
    ImageInfo() { }
    int bitDepth, rowBytes, texWidth, texHeight;
	unsigned char * image;
    
    int originalWidth, originalHeight;
    char originalFilename[256];
    
    GLuint texID;
};

int     GL_LoadTexture(const char * inFileName, GLuint & outTexID, ImageInfo & outImageInfo);


int OS_GetCurrentMillisecond();
bool OS_ReadBinaryFile(const std::string & inFilename, void * outStream, int inBytes);
bool OS_ReadImageFile(const std::string & inFilename, ImageInfo ** outImage);
bool OS_DeleteFile(const std::string & inFilename);
bool OS_DoesFileExist(const std::string & inFilename);
bool OS_SaveImageFile(const std::string & inFilename, ImageInfo & inImageInfo);

int GL_LoadTextureFromText(std::string inText/*const NSString *text*/,ImageInfo & outImageInfo );
int GL_LoadTextureFromFile(const char * inFileName, ImageInfo & outImageInfo);



// point transform - assuming the matrix has an implicit bottom row of (0, 0, 0, 1) and
// the point has an implicit w component of 1
template<typename T> glm::detail::tvec3<T> operator *(const glm::detail::tmat4x3<T> & inTransform, const glm::detail::tvec3<T> & inPt)
{
	return inTransform[3] + glm::detail::tvec3<T>(glm::detail::tmat3x3<T>(inTransform) * inPt);
}

// point transform - assuming the matrix has an implicit bottom row of (0, 0, 0, 1) and
// the point has an implicit w component of 1
template<typename T> glm::detail::tvec4<T> operator *(const glm::detail::tmat4x4<T> & inTransform, const glm::detail::tvec3<T> & inPt)
{
	return inTransform * glm::detail::tvec4<T>(inPt, 1);
}

template<typename T> glm::detail::tmat4x3<T> operator *(const glm::detail::tmat4x3<T> & inMat1, const glm::detail::tmat4x3<T> & inMat2)
{
	glm::detail::tmat4x4<T> mat1(
                                 inMat1[0][0], inMat1[0][1], inMat1[0][2], 0,
                                 inMat1[1][0], inMat1[1][1], inMat1[1][2], 0,
                                 inMat1[2][0], inMat1[2][1], inMat1[2][2], 0,
                                 inMat1[3][0], inMat1[3][1], inMat1[3][2], 1);
	glm::detail::tmat4x4<T> mat2(
                                 inMat2[0][0], inMat2[0][1], inMat2[0][2], 0,
                                 inMat2[1][0], inMat2[1][1], inMat2[1][2], 0,
                                 inMat2[2][0], inMat2[2][1], inMat2[2][2], 0,
                                 inMat2[3][0], inMat2[3][1], inMat2[3][2], 1);
	
	glm::detail::tmat4x4<T> result = mat1 * mat2;
	
	return glm::detail::tmat4x3<T>(
                                   result[0][0], result[0][1], result[0][2],
                                   result[1][0], result[1][1], result[1][2],
                                   result[2][0], result[2][1], result[2][2],
                                   result[3][0], result[3][1], result[3][2]);
}

template<typename T> glm::detail::tmat4x4<T> operator *(const glm::detail::tmat4x4<T> & inMat1, const glm::detail::tmat4x3<T> & inMat2)
{
	glm::detail::tmat4x4<T> mat2(
                                 inMat2[0][0], inMat2[0][1], inMat2[0][2], 0,
                                 inMat2[1][0], inMat2[1][1], inMat2[1][2], 0,
                                 inMat2[2][0], inMat2[2][1], inMat2[2][2], 0,
                                 inMat2[3][0], inMat2[3][1], inMat2[3][2], 1);
	
	return inMat1 * mat2;
}

// vector transform - assuming the matrix has an implicit bottom row of (0, 0, 0, 1) and
// the point has an implicit w component of 0
template<typename T> glm::detail::tvec3<T> operator ^(const glm::detail::tmat4x3<T> & inMat, const glm::detail::tvec3<T> & inVec)
{
	return glm::detail::tvec3<T>(glm::detail::tmat3x3<T>(inMat) * inVec);
}

// vector transform - assuming the matrix has an implicit bottom row of (0, 0, 0, 1) and
// the point has an implicit w component of 0
template<typename T> glm::detail::tvec3<T> operator ^(const glm::detail::tmat4x4<T> & inMat, const glm::detail::tvec3<T> & inVec)
{
	return glm::detail::tvec3<T>(glm::detail::tmat3x3<T>(inMat) * inVec);
}

namespace glm {
	// fast inverse for an affine matrix - assuming this 4x3 matrix is 4x4 with an implicit bottom row (0, 0, 0, 1)
	template<typename T> detail::tmat4x3<T> affineInverse(const detail::tmat4x3<T> & inMat)
	{
		detail::tmat3x3<T> transpose = glm::transpose(glm::detail::tmat3x3<T>(inMat));
		
		return detail::tmat4x3<T>(transpose[0], transpose[1], transpose[2], transpose * -inMat[3]);
	}
    
	template<typename T> detail::tmat4x4<T> viewportMatrix(const glm::ivec4 & inViewport)
	{
		detail::tmat4x4<T> viewportMat = glm::detail::tmat4x4<T>(T(1));
		T halfWidth = inViewport[2] / 2.0;
		T halfHeight = inViewport[3] / 2.0;
		viewportMat[0][0] = halfWidth;
		viewportMat[1][1] = halfHeight;
		viewportMat[3][0] = halfWidth + inViewport[0];
		viewportMat[3][1] = halfHeight + inViewport[1];
        
		return viewportMat;
	}
    
	template<typename T> detail::tmat4x4<T> viewportMatrixInverse(const glm::ivec4 & inViewport)
	{
		detail::tmat4x4<T> viewportMatInv = glm::detail::tmat4x4<T>(T(1));
		T widthInv = 2.0 / inViewport[2];
		T heightInv = 2.0 / inViewport[3];
		viewportMatInv[0][0] = widthInv;
		viewportMatInv[1][1] = heightInv;
		viewportMatInv[3][0] = -widthInv - inViewport[0];
		viewportMatInv[3][1] = -heightInv - inViewport[1];
        
		return viewportMatInv;
	}
    
    
}

std::string ReadWord(std::string & line, int & pos);
std::string ReadQuotedString(std::string & line, int & pos, bool * outIsEmptyString = 0);
#endif

