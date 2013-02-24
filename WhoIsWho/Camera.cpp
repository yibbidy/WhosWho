// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#include "Camera.h"
#include "glm/glm.hpp"
#include "utilities.h"
#include "WhosWho.h"

// TODO this variable should be a member of gGame
Camera gCameraData;

void Camera::FlyToRing(float inRingZ, float inWindowAspect, float inFOVXRad, float inFOVYRad, float & outCamZ)
// Call this function to have to camera animate from where it currently is up -close to 'inRing'
{
	float radius = who::kR1;
	
	float halfFov;
	if( inWindowAspect < 1 ) {  // window is taller than it is wide
        halfFov = inFOVXRad * 0.5f;
	} else {
		halfFov = inFOVYRad * 0.5f;
	}
    
	float z = radius / tan(halfFov);
    
    outCamZ = inRingZ + z;
}

void Camera::FlyToPhoto(float * inCorners, float inWindowAspect, float inFOVXRad, float inFOVYRad, float * outPos)
// Call this function to have to camera animate from where it currently is up close to inImage
{
	
    float * p0 = inCorners+0;
	float * p1 = inCorners+3;
	float * p2 = inCorners+6;
	//float * p3 = inCorners+9;
	
	// p1 ----- p0
	// |        |
	// p3 ----- p2
	float dx = p0[0] - p1[0];
	float dy = p0[1] - p2[1];
	
	float camZ;
    
	float imageAspect = dx / dy;
	float windowAspect = inWindowAspect;
    
	if( imageAspect > windowAspect ) {
		// fit width
		camZ = dx*0.5f / tanf(inFOVXRad*0.5f);
		float yDist = 2*camZ * tanf(inFOVYRad*0.5f);
		if( yDist - dy < 0.02f ) {
			// leave space around the border so you can click the ring to go back
			dx += 0.02f - (yDist - dy);
			camZ = dx*0.5f / tanf(inFOVXRad*0.5f);
		}
	} else {
		camZ = dy*0.5f / tanf(inFOVYRad*0.5f);
		float xDist = 2*camZ * tanf(inFOVXRad*0.5f);
		if( xDist - dx < 0.02 ) {
			// leave space around the border so you can click the ring to go back
			dy += 0.02f - (xDist - dx);
			camZ = dy*0.5f / tanf(inFOVYRad*0.5f);
		}
	}
    
    VEC3_Average(p1, p2, outPos);
    outPos[2] += camZ;
}


void Camera::Setup(Camera & inCam, float inWindowAspect) {
    inCam.windowAspect = inWindowAspect;
    inCam.fovY = MTH_DegToRad(65.0f);
    inCam.halfNearPlaneHeight = 0.01f;
	inCam.nearPlaneDistance = inCam.halfNearPlaneHeight / tanf(inCam.fovY*0.5f);
	inCam.farPlaneDistance = 100;
	inCam.halfNearPlaneWidth = inCam.halfNearPlaneHeight * inCam.windowAspect;
	inCam.fovX = 2.0f * atanf(inCam.halfNearPlaneWidth / inCam.nearPlaneDistance);
	MAT4_MakeFrustum(-inCam.halfNearPlaneWidth, inCam.halfNearPlaneWidth, -inCam.halfNearPlaneHeight, inCam.halfNearPlaneHeight, inCam.nearPlaneDistance, inCam.farPlaneDistance, inCam.projectionMat);
    
}
