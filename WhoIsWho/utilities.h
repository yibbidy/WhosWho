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

#define for_i(size) for( size_t i=0; i<size; i++ )
#define for_j(size) for( size_t j=0; j<size; j++ )
#define for_k(size) for( size_t k=0; k<size; k++ )

float	MTH_Round(float value);
float	MTH_Sign(float inValue);
void	VEC2_Set(float inX, float inY, float * outV);
void	VEC2_Equate(float * inV, float * outV);
void	VEC2_Perpendicular(float * inV, float * outV);
float	VEC2_Dot(float * inV1, float * inV2);
float	VEC2_MagnitudeSq(float * inV);
float	VEC2_Magnitude(float * inV);
void	VEC2_Add(float * inV1, float * inV2, float * outV);
void	VEC2_Subtract(float * inV1, float * inV2, float * outV);
void	VEC2_Multiply(float * inV1, float inFactor, float * outV);
float	VEC2_Distance(float * inV0, float * inV1);
void	VEC3_Set(float x, float y, float z, float * outVec);
void	VEC3_Equate(float * vec3, float * output_vec3);
void	VEC3_Interpolate(float * inV1, float * inV2, float inT, float * outV);
void	VEC4_Equate(float * inVec4, float * outVec4);
void	VEC3_Negate(float * vec3);
void	VEC3_Negate(float * vec3, float * outV);
float	VEC3_Dot(float * first_vec3, float * second_vec3);
float	VEC3_Magnitude(float * vec3);
float	VEC3_Magnitude_Sq(float * vec3);
float	VEC3_DistanceBetween(float * inV1, float * inV2);
float	VEC3_DistanceBetween_Sq(float * inV1, float * inV2);
void	VEC3_Normalize(float * vec3, float * normalized_vec3);
void	VEC3_Normalize(float * vec3);
void	VEC3_Cross(float * a_vec3, float * b_vec3, float * crossed_vec3);
void	VEC3_Difference(float * a_vec3, float * b_vec3, float * difference_vec3);
void	VEC3_Swap(float * a_vec3, float * b_vec3);
void	VEC3_Add(float * first_vec3, float * second_vec3, float * output_vec3);
void	VEC3_Subtract(float * first_vec3, float * second_vec3, float * output_vec3);
void	VEC3_Multiply(float * first_vec3, float * second_vec3, float * output_vec3);
void	VEC3_Multiply(float * vec3, float scalar, float * output_vec3);
void	VEC3_Divide(float * inVec3, float scalar, float * outVec);
float	VEC3_AngleBetween(float * first_vec3, float * second_vec3);
void	VEC3_Average(float * inV1, float * inV2, float * outAverage);
void	VEC3_MAT4_Multiply(float * row_vec3, float * mat4, float * column_vec3);
void	VEC3_Mix(float * inV0, float * inV1, float inT, float * outV);
void	VEC4_Set(float x, float y, float z, float w, float * outVec);
void	VEC4_Multiply(float * inVec4, float scalar, float * outVec);
void	VEC4_Divide(float * inVec4, float scalar, float * outVec);
void	VEC4_MAT4_Multiply(float * inV, float * inM, float * outV);
void	MAT4_ExtractCol3(float * mat4, int col, float * vec3);
void	MAT4_ExtractRow3(float * mat4, int row, float * vec3);
void	MAT4_SetUpper3x3(float * outMat, float * inR0, float * inR1, float * inR2);
void	MAT4_SetUpper3x3Rowwise(float * outMat, float * inR0, float * inR1, float * inR2);
void	MAT4_SetCol3(int col, float * vec3, float * mat4);
void	MAT4_LoadIdentity(float * mat4);
void	MAT4_VEC3_Multiply(float * mat4, float * column_vec3, float * row_vec3);
void	MAT4_VEC4_MatrixVectorMultiply(float * mat4, float * column_vec4, float * out_vec4);
void	MAT4_VEC4_InverseMatrixVectorMultiply(float * mat4, float * column_vec4, float * out_vec4);
void	MAT4_Multiply(float * first_mat4, float * second_mat4, float * output_mat4);
void	MAT4_TransposeUpper3(float * mat4, float * transpose_mat4);
void	MAT4_SetEqual(float * mat4, float * output_mat4);
void	MAT4_InvertQuick(float * inMat, float * outMat);
void	MAT4_MakeZRotation(float deg, float * zRotation_mat4);
void	MAT4_MakeXRotation(float deg, float * xRotation_mat4);
void    MAT4_MakeYRotation(float deg, float * xRotation_mat4);
void    MAT4_MakeArbitraryRotation(float inAxisX, float inAxisY, float inAxisZ, float inAngleRad, float * rotation_mat4);
void    MAT4_PostRotate(float inAxisX, float inAxisY, float inAxisZ, float inAngleRad, float * inOutMat);
void    MAT4_PreRotate(float inAxisX, float inAxisY, float inAxisZ, float inAngleRad, float * inOutMat);
void    MAT4_MakeTranslation(float inX, float inY, float inZ, float * outMat);
void    MAT4_PostTranslate(float inX, float inY, float inZ, float * inOutMat);
void    MAT4_PreTranslate(float inX, float inY, float inZ, float * inOutMat);
void    MAT4_MakeScale(float inScaleX, float inScaleY, float inScaleZ, float * outMat);
void    MAT4_PreScale(float inScaleX, float inScaleY, float inScaleZ, float * inOutMat);
void    MAT4_PostScale(float inScaleX, float inScaleY, float inScaleZ, float * inOutMat);
void	MAT4_MakePerspective(float fovy_rad, float aspect, float zNear, float zFar, float * mat4);
void	MAT4_MakeInversePerspective(float fovy_rad, float aspect, float zNear, float zFar, float * mat4);
void	MAT4_MakeOrtho(float left, float right, float bottom, float top, float near, float far, float * mat4);
void	MAT4_MakeFrustum(float left, float right, float bottom, float top, float zNear, float zFar, float * mat4);
void	MAT4_Translate(float inX, float inY, float inZ, float * inOutMat4);
void    MAT4_Transpose(float * inOutMat);
void	MAT4_MakeOrtho(float left, float right, float bottom, float top, float zNear, float zFar, float * mat4);
void	MAT4_Equate(float * inMat, float * outMat);
bool	MAT4_Equal(float * inMat0, float * inMat1);
void	MAT4_LookAt(float eyeX, float eyeY, float eyeZ, float centerX, float centerY, float centerZ, float upX, float upY, float upZ, float * viewMatrix);
void	MAT4_VEC4_Multiply(float * mat4, float * column_vec4, float * row_vec4);
bool	MAT4_Invert(const float * mat4, float * out4);
void	MAT4_Transpose(float * mat4, float * out4);
void	MAT4_ExtractUpper3x3(float * inMat4, float * outMat3);

float	MTH_GetFraction(float inF);
float	MTH_DegToRad(float deg);
float	MTH_RadToDeg(float rad);
float   MTH_RandomFloat(float inMin, float inMax);
float   MTH_RandomInt(int inMin, int inMax);

// quaternion functions
void	QT_Equate(float * inQ, float * outQ);
void	QT_Set(float inX, float inY, float inZ, float inW, float * outQ);
void	QT_MAT4_MakeQuaternion(float * inMat, float * outQ);
void	QT_MAT4_MakeMatrix(float * inQ, float * outMat);
void	QT_SLERP(float * inQ0, float * inQ1, float inT, float * outQ);
void	QT_GetAxisAngle(float * inQ, float * outAxis, float outAngle /*rad*/);

 
void	FPSCAM_MoveForward(float amount, bool fixedZ, float * inOutCameraMat);
void	FPSCAM_MoveUp(float amount, bool fixedZ, float * inOutViewMat);
void	FPSCAM_StrafeRight(float amount, float * inOutCameraMat);
void	FPSCAM_LookRight(float amount_deg, bool inFixedUp, float * inOutCameraMat);
void	FPSCAM_LookUp(float amount_deg, float * inOutCameraMat);
void	FPSCAM_RollRight(float inAmountDeg, float * inOutViewMat);

void	GEO_GenerateUnitSphere(std::vector<float> & vertices, std::vector<float> & normals);
void    GEO_GenerateDisc(float inStartAngle, float inEndAngle, float inInnerRadius, float inOuterRadius, float inZ, int inSegments, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords, float * outBoundingCube);
void    GEO_GenerateUnitCircle(int inSegments, std::vector<float> & outVertices);
void    GEO_GenerateUnitRectangle(std::vector<float> & outVertices, std::vector<float> & outTexCoords);
void    GEO_GenerateRectangle(float inWidth, float inHeight, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords);
void	GEO_ExtractFrustumPoints(float * inMVPInvertMat, float outFrustumPoints[4*8]);
bool	GEO_RayPlaneIntersection(float * ptOnPlane, float * planeNormal, float * rayOrigin, float * rayDir, float * optOutT, float * outIntersection);
bool	GEO_RayTriangleIntersection(float * inRayOrigin, float * inRayDir, float * inTriangleVertices, float * outT, float * outIntersection);
bool	GEO_LineLineIntersection(float * inP1, float * inV1, float * inP2, float * inV2, bool inSegmentIntersection, bool & outParallel, float & outT1, float & outT2, float * outIntersection);
int		GEO_BestFitRectInRect(float * inFlexibleRect, float * inFixedRect, float * outBestFitRect);
void    GEO_MakePickRay(float * inViewMat, float * inProjectionMat, int * inViewport, float * inViewPt3, float * outRayOrigin, float * outRayDir);

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

void    GL_WindowPtToWorld(float * inWindowPt, float * inModelviewMat, float * inProjectionMat, int * inViewport, float * outWorldPt);
int     GL_LoadTexture(const char * inFileName, GLuint & outTexID, ImageInfo & outImageInfo);


int OS_GetCurrentMillisecond();
bool OS_ReadBinaryFile(const std::string & inFilename, void * outStream, int inBytes);
bool OS_ReadImageFile(const std::string & inFilename, ImageInfo ** outImage);
bool OS_DeleteFile(const std::string & inFilename);
bool OS_DoesFileExist(const std::string & inFilename);
bool OS_SaveImageFile(const std::string & inFilename, ImageInfo & inImageInfo);

float GetTick();

enum InterpolationType {
	InterpolationTypeLinear,
	InterpolationTypeSmooth,
	InterpolationTypeSqrt
};

enum AnimationType {
	AnimationTypeFloat
};

struct Animation {
	AnimationType animationType;
    
	float * animationFloat;
	float startValue;
	float endValue;
    
	int startTick;
	float duration;
	InterpolationType interpolation;
	int animationID;
};

bool ANM_UpdateAnimations(float inTick);
int ANM_CreateFloatAnimation(float inStartValue, float inEndValue, float inDuration, 
                                     InterpolationType inInterpolationType, float * inOutVariable);
bool ANM_IsRunning(int inAnimationID);
bool ANM_StopFloatAnimation(int inAnimationID);
#endif

