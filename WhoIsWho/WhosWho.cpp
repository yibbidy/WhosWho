// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#include "WhosWho.h"
#include "glm/glm.hpp"

// *** the main global in this app ***
who::Game gGame;

namespace who
{
    
    Ring * Game::GetRing(std::string inName)
    // returns the ring whose resource name is 'inName' or 0 if such a name doesn't exist.
    {
        std::map<std::string, Ring>::iterator it = gGame.rings.rings.find(inName);
        if( it == gGame.rings.rings.end() ) {
            return 0;
        } else {
            return &it->second;
        }
    }
    
    Ring * Game::GetBackRing()
    // returns the back ring, aka the bottom ring or 0 if there is no back ring.
    {
        if( gGame.rings.stackingOrder.empty() ) {
            return 0;
        } else {
            return GetRing(gGame.rings.stackingOrder.back());
        }
    }
    
    Ring * Game::GetCurrentRing()
    // returns the back ring, aka the bottom ring or 0 if there is no back ring.
    {
        return GetRing(gGame.rings.currentRing);
    }
    
    Photo * Game::GetPhoto(std::string inPhoto) {
        std::map<std::string, Photo>::iterator it = photos.find(inPhoto);
        if( it == photos.end() ) {
            return 0;
        }
        
        return &it->second;
    }
    
    void Game::Execute(std::string inCommand, int inNumPairs, ...) {
        gGame.animations.push_back(inCommand);
        
        va_list args;
        va_start(args, inNumPairs);
        
        for_i( inNumPairs ) {
            std::string key = (std::string)va_arg(args, char *);
            void * value = (void *)va_arg(args, void *);
            gGame.animationVars[key] = value;
        }
        va_end(args);
        
    }
    

    
    float SmoothFn(float inT, float * inParams)
    // This is the exponential function pi*T^inP in the range
    // 0 to 1.  It's mirrored horizontally in the range 1 to 2
    // and the range 0 to 2 is repeated ad infinitum.
    {
        float sign = (inT>=0) ? 1 : -1;
        inT = fabs(inT);
        
        if( inT > 2 ) {
            return sign * (2 + pow(inT-2, inParams[0]));
        } else if( inT > 1 ) {
            return sign * (2 - powf(2-inT, inParams[0]));
        } else {
            return sign * (powf(inT, inParams[0]));
        }
    }
    
    
    float LinearFn(float inT, float * /*inParams*/)
    // This is the linear function inT in the range
    // 0 to 1.  It's mirrored horizontally in the range 1 to 2
    // and the range 0 to 2 is repeated ad infinitum.
    {
        float sign = (inT>=0) ? 1 : -1;
        inT = fabs(inT);
        
        if( inT > 2 ) {
            return sign * (2 + (inT-2));
        } else if( inT > 1 ) {
            return sign * (2 - (2-inT));
        } else {
            return sign * (inT);
        }
    }
    
    void ComputeTopPhotoCorners(who::Ring & inRing, float * outCorners) {
        float kPi = 3.141592654f;
        
        int numImages = int(inRing.photos.size());
        float halfNumImages = numImages * 0.5f;
        float w0 = atanf((kR1-kR0)/(kR1+kR0));  // end angle for 0th photo
        
        float p = logf(w0/kPi) / logf(0.5f/halfNumImages);  // of f(x) = pi x^p
        float radius = (kR0+kR1) * 0.5f;
        
        float (* spacingFn)(float, float *);
        
        if( numImages * w0 <= kPi ) {
            spacingFn = LinearFn;
        } else {  // space images out using t^p
            spacingFn = SmoothFn;
        }
        
        
        float t = 0;
        float halfStep = 0.5f/halfNumImages;
        
        float angle0 = kPi * spacingFn(t-halfStep, &p);
        float angle1 = kPi * spacingFn(t+halfStep, &p);
        float angle = (angle0 + angle1) * 0.5f;
        float dAngle = (angle1 - angle0) * 0.5f;
        angle0 = angle - glm::min(w0, dAngle);
        angle1 = angle + glm::min(w0, dAngle);
        
        float p0[] = { radius*cosf(angle0), radius*sinf(angle0) };
        float p1[] = { radius*cosf(angle1), radius*sinf(angle1) };
        float length = VEC2_Distance(p0, p1) / sqrtf(2.0);
        
        who::Photo & photo = gGame.photos[inRing.photos[inRing.selectedPhoto]];
        ImageInfo & image = gGame.images[photo.filename];
        float aspect = fabsf(image.originalHeight) > 0 ? (image.originalWidth / float(image.originalHeight)) : 1.0f;
        float w, h;
        if( aspect > 1 ) {
            w = length;
            h = length / aspect;
        } else {
            w = length * aspect;
            h = length;
        }
        
        w *= 0.5f;
        h *= 0.5f;
        float z = 0.01f;
        
        float corners[] = {
            w, h, z,
            -w, h, z,
            w, -h, z,
            -w, -h, z 
        };
        
        memcpy(outCorners, corners, sizeof(float)*12);
        
    }
}
