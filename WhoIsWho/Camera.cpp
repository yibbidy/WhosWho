// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#include "Camera.h"
#include "glm/glm.hpp"
#include "glm/gtc/matrix_inverse.hpp"
#include "glm/gtc/matrix_transform.hpp"

#include "utilities.h"
#include "WhosWho.h"

// TODO this variable should be a member of gGame
Camera gCameraData;

// TODO rename this function
void Camera::FlyToRing(float inRingZ, float inWindowAspect, const glm::vec2 & inFovXY, float & outCamZ)
// Call this function to have to camera animate from where it currently is up -close to 'inRing'
{
	float radius = who::kR1;
	
	float halfFov;
	if( inWindowAspect < 1 ) {  // window is taller than it is wide
        halfFov = inFovXY[0] * 0.5f;
	} else {
		halfFov = inFovXY[1] * 0.5f;
	}
    
	float z = radius / glm::tan(glm::radians(halfFov));
    
    outCamZ = inRingZ + z;
}

void Camera::FlyToPhoto(const glm::vec3 * inCorners, float inWindowAspect, const glm::vec2 & inFovXY, glm::vec3 & outPos)
// Call this function to have to camera animate from where it currently is up close to inImage
{
	
    const glm::vec3 & p0 = inCorners[0];
    const glm::vec3 & p1 = inCorners[1];
    const glm::vec3 & p2 = inCorners[2];
    
	
	// p1 ----- p0
	// |        |
	// p3 ----- p2
	float dx = p0.x - p1.x;
	float dy = p0.y - p2.y;
	
	float camZ;
    
	float imageAspect = dx / dy;
	float windowAspect = inWindowAspect;
    
    float fovX = glm::radians(inFovXY[0]);
    float fovY = glm::radians(inFovXY[1]);
    
	if( imageAspect > windowAspect ) {
		// fit width
		camZ = dx*0.5f / glm::tan(fovX*0.5f);
		float yDist = 2*camZ * glm::tan(fovY*0.5f);
		if( yDist - dy < 0.02f ) {
			// leave space around the border so you can click the ring to go back
			dx += 0.02f - (yDist - dy);
			camZ = dx*0.5f / glm::tan(fovX*0.5f);
		}
	} else {
		camZ = dy*0.5f / glm::tan(fovY*0.5f);
		float xDist = 2*camZ * glm::tan(fovX*0.5f);
		if( xDist - dx < 0.02 ) {
			// leave space around the border so you can click the ring to go back
			dy += 0.02f - (xDist - dx);
			camZ = dy*0.5f / glm::tan(fovY*0.5f);
		}
	}
    
    outPos = (p1 + p2) * 0.5f;
    outPos[2] += camZ;
}


Camera::Camera(const glm::vec3 & inPos, const glm::vec3 & inLookAt, const glm::vec3 & inUp, float inFovY,
                   const glm::vec2 inNearFarDist, const glm::ivec4 & inViewport, const glm::ivec2 & inWindowSize)
{
    _pos = inPos;
    _lookAt = inLookAt;
    _up = inUp;
    _fovXY[1] = inFovY;
    
    _viewport = inViewport;
    _viewportAspect = inViewport[2] / float(inViewport[3]);
    
    _windowSize = inWindowSize;
    _windowAspect = _windowSize[0] / float(_windowSize[1]);
    
    _nearFarDist = inNearFarDist;
    
    
    _viewMat = glm::mat4x3(glm::lookAt(inPos, inLookAt, inUp));
    _viewInvMat = glm::affineInverse(_viewMat);
    
    float halfNearPlaneHeight = _nearFarDist[0] * glm::tan(glm::radians(_fovXY[1])*0.5f);
    float halfNearPlaneWidth = halfNearPlaneHeight * _viewportAspect;
	_fovXY[0] = glm::degrees(2.0f * glm::atan(halfNearPlaneWidth / _nearFarDist[0]));
	
    _projectionMat = glm::perspective(inFovY, _viewportAspect, _nearFarDist[0], inNearFarDist[1]);
    _projectionInvMat = glm::inverse(_projectionMat);
    
    _vpMat = _projectionMat * _viewportMat;
    _vpMatInv = glm::inverse(_vpMat);
    
    _viewportMat = glm::viewportMatrix<float>(_viewport);
    _viewportInvMat = glm::affineInverse(_viewportMat);
    
    
    
    
    
    /*windowAspect = inWindowAspect;
    fovY = MTH_DegToRad(65.0f);
    halfNearPlaneHeight = 0.01f;
	nearPlaneDistance = halfNearPlaneHeight / tanf(fovY*0.5f);
	farPlaneDistance = 100;
	halfNearPlaneWidth = halfNearPlaneHeight * windowAspect;
	fovX = 2.0f * atanf(halfNearPlaneWidth / nearPlaneDistance);
	MAT4_MakeFrustum(-halfNearPlaneWidth, halfNearPlaneWidth, -halfNearPlaneHeight, halfNearPlaneHeight, nearPlaneDistance, farPlaneDistance, projectionMat);
    */
}
