// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)
//

#include "utilities.h"
#include "glm/glm.hpp"

void GEO_GenerateUnitSphere(std::vector<float> & vertices, std::vector<float> & normals) {
	const int Size = (int)((3.141592654 / .2 + 1)*(2*3.141592654 / .2 + 1)) * 6;
	vertices.resize(Size);
	normals.resize(Size);

	int i = 0;

	float radius = 1;
	for( float phi = 0.2f; phi <= 3.141592654f; phi += 0.2f ) {
		for( float theta = 0.0f; theta <= 2.0f*3.141592654f; theta += 0.2f ) {
			float px = radius * cosf(theta) * sinf(phi-0.2f);
			float py = radius * sinf(theta) * sinf(phi-0.2f);
			float pz = radius * cosf(phi-0.2f);
			float pmagnitude = sqrtf(px*px + py*py + pz*pz);
			
			normals[i] = px/pmagnitude;
			vertices[i++] = px;
			normals[i] = py/pmagnitude;
			vertices[i++] = py;
			normals[i] = pz/pmagnitude;
			vertices[i++] = pz;

            float x = radius * cosf(theta) * sinf(phi);
			float y = radius * sinf(theta) * sinf(phi);
			float z = radius * cosf(phi);
			float magnitude = sqrtf(x*x + y*y + z*z);

			normals[i] = x/magnitude;
			vertices[i++] = x;
			normals[i] = y/magnitude;
			vertices[i++] = y;
			normals[i] = z/magnitude;
			vertices[i++] = z;
		}
	}
	
}

void GEO_GenerateDisc(float inStartAngle, float inEndAngle, float inInnerRadius, float inOuterRadius, float inZ, int inSegments, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords, float * outBoundingCube)
// generate triangle strip for a partial disc.  first vertex is on outer radius
{
	outVertices.resize(inSegments*2 * 3);
	outNormals.resize(outVertices.size());
	outTexCoords.resize(inSegments*2 * 2);
	
	float * v = &outVertices[0];
	float * n = &outNormals[0];
	float * t = &outTexCoords[0];
	
	float angleDiff = -(inEndAngle-inStartAngle)*(3.141592654f/180) / (inSegments-1);
	float angle = -inStartAngle*(3.141592654f/180);

	float * cube = outBoundingCube;
	if( cube ) {
		cube[0] = 99999999.0f;
		cube[1] = cube[0];
		cube[2] = inZ;
		cube[3] = -cube[0];
		cube[4] = -cube[0];
		cube[5] = inZ;
	}

	for( int i=0; i<inSegments; i++ ) {
		float u = 1.0f - (i/(float)(inSegments-1));
		float c = cos(angle);
		float s = sin(angle);
		
		*v++ = inOuterRadius*c;
		*v++ = inOuterRadius*s;
		*v++ = inZ;

		*n++ = 0;
		*n++ = 0;
		*n++ = 1;

		*t++ = u;
		*t++ = 0;

		*v++ = inInnerRadius*c;
		*v++ = inInnerRadius*s;
		*v++ = inZ;
			
		*n++ = 0;
		*n++ = 0;
		*n++ = 1;

		*t++ = u;
		*t++ = 1;

		if( cube ) {
			cube[0] = glm::min(cube[0], glm::min(*(v-3), *(v-6)));
			cube[1] = glm::max(cube[1], glm::min(*(v-3), *(v-6)));
			cube[3] = glm::min(cube[3], glm::min(*(v-2), *(v-5)));
			cube[4] = glm::max(cube[4], glm::min(*(v-2), *(v-5)));
		}

		angle += angleDiff;
	}

}

void GEO_GenerateUnitCircle(int inSegments, std::vector<float> & outVertices) {
    outVertices.resize(inSegments*2);
    for( int i=0; i<inSegments; i++ ) {
        float angle = i/float(inSegments) * 3.141592654f;
        outVertices[i*2+0] = cos(angle);
        outVertices[i*2+1] = sin(angle);
    }
}


bool GEO_RayPlaneIntersection(const glm::vec3 & ptOnPlane, const glm::vec3 & planeNormal, const glm::vec3 & rayOrigin, const glm::vec3 & rayDir, float * optOutT, glm::vec3 & outIntersection) {
    glm::vec3 d = glm::normalize(rayDir);
    
	float den = glm::dot(planeNormal, d);
	if( den == 0 ) return false;

    glm::vec3 vec = rayOrigin - ptOnPlane;
    float num = -glm::dot(planeNormal, vec);
    
	float t = num / den;
	if( optOutT != 0 ) {
		*optOutT = t;
	}
	
    outIntersection = rayOrigin + d * t;
	
	return true;
}

bool GEO_RayTriangleIntersection(const glm::vec3 & inRayOrigin, const glm::vec3 & inRayDir, const glm::vec3 * inTriangleVertices, float * outT, glm::vec3 & outIntersection) {
    glm::vec3 xVec = glm::normalize(inTriangleVertices[2] - inTriangleVertices[1]);
    
    glm::vec3 yVec = inTriangleVertices[0] - inTriangleVertices[1];
    
    glm::vec3 zVec = glm::normalize(glm::cross(xVec, yVec));
	yVec = glm::cross(zVec, xVec);
    
	if( GEO_RayPlaneIntersection(inTriangleVertices[0], zVec, inRayOrigin, inRayDir, outT, outIntersection) ) {

        glm::vec3 vec, perp, vec2D;
        
		for( int i=0; i<3; i++ ) {
            vec = inTriangleVertices[(i+1)%3] - inTriangleVertices[i];
            
            perp = glm::vec3(-glm::dot(vec, yVec), glm::dot(vec, xVec), 0);
            
            vec = outIntersection - inTriangleVertices[i];
            vec2D = glm::vec3(glm::dot(vec, xVec), glm::dot(vec, yVec), 0);
            
            if( glm::dot(perp, vec2D) < 0 ) {
                return false;
            }

		}

		return true;
	}

	return false;
}

void GEO_MakePickRay(const glm::mat4x3 & inViewMat, const glm::mat4 & inProjectionMat, const glm::ivec4 & inViewport, const glm::vec3 & inViewPt3, glm::vec3 & outRayOrigin, glm::vec3 & outRayDir) {
	
    glm::mat4 vpInvMat = glm::inverse(inProjectionMat * glm::mat4(inViewMat));
	
    glm::vec4 ndc = glm::vec4(
		(2 * (inViewPt3[0] - inViewport[0]) / inViewport[2]) - 1,
		-((2 * (inViewPt3[1] - inViewport[1]) / inViewport[3]) - 1),
		(2 *  inViewPt3[2] ) - 1,
		1);

    glm::vec4 worldPt = vpInvMat * ndc;
    worldPt /= worldPt.w;
    
	if( inProjectionMat[3][3] == 0 ) { // if in a perspective view
        glm::mat4x3 viewInvMat = glm::affineInverse(inViewMat);
        outRayOrigin = viewInvMat[3];
        outRayDir = glm::normalize(glm::vec3(worldPt) - outRayOrigin);
	} else {										// if in an orthographic view
		outRayOrigin = glm::vec3(worldPt);
        outRayDir = glm::normalize(-inViewMat[2]);
	}

}

bool GEO_LineLineIntersection(float * inP1, float * inV1, float * inP2, float * inV2, bool inSegmentIntersection, bool & outParallel, float & outT1, float & outT2, float * outIntersection)
//   Determine the intersection point of two line segments
//   Return FALSE if the lines don't intersect
// original code: http://paulbourke.net/geometry/lineline2d/
{
	outParallel = false;
	outT1 = 0;
	outT2 = 0;

	float * p1 = inP1;
	float * v1 = inV1;

	float * p2 = inP2;
	float * v2 = inV2;

	float dx = p1[0]-p2[0];
	float dy = p1[1]-p2[1];

	float denom  = v2[1] * v1[0] - v2[0] * v1[1];
	float numera = v2[0] * dy - v2[1] * dx;
	float numerb = v1[0] * dy - v1[1] * dx;

	float EPS = 1e-4f;

	// Are the line coincident?
	if (fabs(numera) < EPS && fabs(numerb) < EPS && fabs(denom) < EPS) {
		outIntersection[0] = (p1[0] + p2[0]) * 0.5f;
		outIntersection[1] = (p1[1] + p2[1]) * 0.5f;
		outParallel = true;
		return true;
	}

	// Are the line parallel
	if (fabs(denom) < EPS) {
		outIntersection[0] = 0;
		outIntersection[1] = 0;
		outParallel = true;
		return true;
	}

	// Is the intersection along the the segments
	outT1 = numera / denom;
	outT2 = numerb / denom;
	if( inSegmentIntersection && (outT1 < 0 || outT1 > 1 || outT2 < 0 || outT2 > 1) ) {
		outIntersection[0] = 0;
		outIntersection[1] = 0;
		return false;
	}

	outIntersection[0] = p1[0] + outT1 * inV1[0];
	outIntersection[1] = p1[1] + outT1 * inV1[1];

	return true;
}
int GEO_BestFitRectInRect(float * inFlexibleRect, float * inFixedRect, float * outBestFitRect) 
// rect format is x, y, w, h
{
	int errorCode = 0;

	float * r1 = inFlexibleRect;
	float * r2 = inFixedRect;
	float * r3 = outBestFitRect;

	if( r1[3] == 0 ) {
		errorCode = 1;
	} else if( r1[2] == 0 ) {
		errorCode = 2;
	} else if( r2[2] == 0 ) {
		errorCode = 3;
	} else if( r2[3] == 0 ) {
		errorCode = 4;
	} else {

		float aspect1 = r1[2] / (float)r1[3];

		float wRatio = r2[2] / (float)r1[2];
		float hRatio = r2[3] / (float)r1[3];

		if( wRatio < hRatio ) {
			r3[2] = r2[2];
			r3[3] = r2[2] / aspect1;
		} else {
			r3[3] = r2[3];
			r3[2] = r2[3] * aspect1;
		}

		float center[] = { r2[0]+0.5f*r2[2], r2[1]+0.5f*r2[3] };
		r3[0] = center[0] - r3[2]*0.5f;
		r3[1] = center[1] - r3[3]*0.5f;
	}

	return errorCode;
}

void GEO_GenerateUnitRectangle(std::vector<float> & outVertices, std::vector<float> & outTexCoords) {
	
	float v[] = { -1,-1,0, 1,-1,0, -1,1,0, 1,1,0 }; // triangle strip
	outVertices.resize(12);
	memcpy(&outVertices[0], v, sizeof(float)*12);

	float uv[] = { 0,0, 1,0, 0,1, 1,1 }; // triangle strip
	outTexCoords.resize(8);
	memcpy(&outTexCoords[0], uv, sizeof(float)*8);

}

void GEO_GenerateRectangle(float inWidth, float inHeight, std::vector<float> & outVertices, std::vector<float> & outNormals, std::vector<float> & outTexCoords) 
// this function generates vertex attributes of a ccw triangle strip that makes a rectangle, centered.
{
    const float w = inWidth/2;
    const float h = inHeight/2;
    
    float v[] = { -w,-h,0, w,-h,0, -w,h,0, w,h,0 }; // triangle strip
	outVertices.resize(12);
	memcpy(&outVertices[0], v, sizeof(float)*12);
    
    float n[] = { 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1 };
    outNormals.resize(12);
    memcpy(&outNormals[0], n, sizeof(float)*12);
    
	float uv[] = { 0,1, 1,1, 0,0, 1,0 }; // triangle strip
	outTexCoords.resize(8);
	memcpy(&outTexCoords[0], uv, sizeof(float)*8);

}



// ------------- Begin OS specific wrapper functions ------------------

int OS_GetCurrentMillisecond() {
	return 0;
}

bool OS_ReadBinaryFile(const std::string & inFilename, void * outStream, int inBytes) 
// outputs the content of a binary file to outStream.  returns true on success
{

    std::ifstream in(inFilename.c_str(), std::ios::binary);
	if( !in.is_open() ) return false;
		
	in.read((char *)outStream, inBytes);
	in.close();

	return true;
}

// initializes the imageinfo struct.   ownership of image is transferred to the imageInfo.
ImageInfo::ImageInfo(int width, int height, int bitDepth, int rowBytes, unsigned char * image) {
	this->texWidth = width;
	this->texHeight = height;
	this->bitDepth = bitDepth;
	this->rowBytes = rowBytes;
	this->image = image;
	texWidth = width; 
	texHeight = height;
}




