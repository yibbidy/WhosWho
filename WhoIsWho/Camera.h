// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef __WhoIsWho__Camera__
#define __WhoIsWho__Camera__


struct Camera {
    Camera() {
        zoomed = 0;
        camX = 0;
        camY = 0;
        camZ = 10;
    }
    
    // TODO these 2 functions should be members of gGame
    static void FlyToRing(float inRingZ, float inWindowAspect, float inFOVXRad, float inFOVYRad, float & outCamZ);
    static void FlyToPhoto(float * inCorners, float inWindowAspect, float inFOVXRad, float inFOVYRad, float * outPos);
    
    // TODO this function should not be static
    static void Setup(Camera & inCam, float inWindowAspect);
    
    
    float camX, camY, camZ;
    float windowAspect;
    float nearPlaneDistance;
    float farPlaneDistance;
    float halfNearPlaneWidth;
    float halfNearPlaneHeight;
    float fovX;  // radians
    float fovY;
    
    float zoomed;  // 1 when up close to a ring, 0 when further back, and inbetween
    
    // TODO projection matrix should be a glm::dmat4
    float projectionMat[16];
};

// TODO gCameraData should be part of gGame
extern Camera gCameraData;


#endif /* defined(__WhoIsWho__Camera__) */
