// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Camera_h
#define Camera_h

#include "glm/glm.hpp"

class Camera
{
public:
    
    Camera() {
        _zoomed = 0;
        _pos = glm::vec3(0, 0, 10);
    }
    
    // TODO these 2 functions should be members of gGame
    static void FlyToRing(float inRingZ, float inWindowAspect, const glm::vec2 & inFovXY, float & outCamZ);
    static void FlyToPhoto(const glm::vec3 * inCorners, float inWindowAspect, const glm::vec2 & inFovXY, glm::vec3 & outPos);

    
    Camera(const glm::vec3 & inPos, const glm::vec3 & inLookAt, const glm::vec3 & inUp, float inFovY,
           const glm::vec2 inNearFarDist, const glm::ivec4 & inViewport, const glm::ivec2 & inWindowSize);

    glm::vec3 _pos, _lookAt, _up;
    
    glm::vec2 _fovXY;
    glm::vec2 _nearFarDist;
    
    glm::ivec4 _viewport;
    float _viewportAspect;
    
    glm::ivec2 _windowSize;
    float _windowAspect;
        
    glm::mat4x3 _viewMat;  // world to eye
    glm::mat4x3 _viewInvMat;
    
    glm::mat4 _projectionMat;  // eye to clip
    glm::mat4 _projectionInvMat;
    
    glm::mat4 _viewportMat;  // ndc to viewport
    glm::mat4 _viewportInvMat;
    
    glm::mat4 _vpMat;  // world to clip
    glm::mat4 _vpMatInv;
    
    glm::mat4 _vpvMat;  // world to window
    glm::mat4 _vpvInvMat;  // window to world
    
    // TODO move to gGame
    float _zoomed;  // 1 when up close to a ring, 0 when further back, and inbetween
};

#endif // Camera_h
