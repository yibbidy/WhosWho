// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Camera_h
#define Camera_h

#include "glm/glm.hpp"

class Camera
{
public:
    
    Camera() {
        zoomed = 0;
        pos = glm::vec3(0, 0, 10);
    }
    
    // TODO these 2 functions should be members of gGame
    static void FlyToRing(float inRingZ, float inWindowAspect, const glm::vec2 & inFovXY, float & outCamZ);
    static void FlyToPhoto(const glm::vec3 * inCorners, float inWindowAspect, const glm::vec2 & inFovXY, glm::vec3 & outPos);

    
    Camera(const glm::vec3 & inPos, const glm::vec3 & inLookAt, const glm::vec3 & inUp, float inFovY,
           const glm::vec2 inNearFarDist, const glm::ivec4 & inViewport, const glm::ivec2 & inWindowSize);

    glm::vec3 pos, lookAt, up;
    
    glm::vec2 fovXY;
    glm::vec2 _nearFarDist;
    
    glm::ivec4 viewport;
    float viewportAspect;
    
    glm::ivec2 _windowSize;
    float _windowAspect;
        
    glm::mat4x3 viewMat;  // world to eye
    glm::mat4x3 _viewInvMat;
    
    glm::mat4 projMat;  // eye to clip
    glm::mat4 _projectionInvMat;
    
    glm::mat4 viewportMat;  // ndc to viewport
    glm::mat4 viewportInvMat;
    
    glm::mat4 vpMat;  // world to clip
    glm::mat4 vpMatInv;
    
    glm::mat4 vpvMat;  // world to window
    glm::mat4 _vpvInvMat;  // window to world
    
    // TODO move to gGame
    float zoomed;  // 1 when up close to a ring, 0 when further back, and inbetween
};

#endif // Camera_h
