// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

// this file does parsing for the function gGame.Execute.  It also implements the useful high level functions.

#include "Parser.h"
#include "WhosWho.h"
#include "Renderer.h"
#include "Camera.h"
#include "Animation.h"
#include "glm/glm.hpp"
#include "utilities.h"

namespace who
{

    
    
void WhoParser::EatWhitespace(const char * inStr, int & inOutPos) {
    char ch = inStr[inOutPos];
    while( ch == ' ' || ch=='\t' || ch==0 || ch=='\n' ) {
        inOutPos++;
        ch = inStr[inOutPos];
    }
}

std::string WhoParser::Word(const char * inStr, int & inOutPos) {
    
    EatWhitespace(inStr, inOutPos);
    
    std::string str;
    
    char ch = inStr[inOutPos];
    bool quote = ch == '"';
    if( quote ) {
        inOutPos++;
        ch = inStr[inOutPos];
    }
    
    while( ch && (quote || (ch!=' ' && ch!='\t' && ch!='\r' && ch!='\n')) ) {
        inOutPos++;
        
        if( ch == '"' ) {
            break;
        }
        
        str += ch;
        ch = inStr[inOutPos];
    }
    
    return str;
    
}



bool WhoParser::KeyValue(const char * inKey, const char * inStr, int & inOutPos, std::string & outValue) {
    int pos = inOutPos;
    
    EatWhitespace(inStr, inOutPos);
    
    bool fail = false;
    
    int keyIndex = 0;
    
    char ch = inStr[inOutPos];
    while( ch!=' ' && ch!='\t' && ch!=0 && ch!='=' && ch!='\n' ) {
        int keyCh = inKey[keyIndex];
        
        keyIndex++;
        inOutPos++;
        
        if( keyCh == 0 ) {
            break;
        }
        if( keyCh != ch ) {
            fail = true;
            break;
        }
        
        ch = inStr[inOutPos];
        
    }
    
    EatWhitespace(inStr, inOutPos);
    
    if( inStr[inOutPos++] != '=' ) {
        fail = true;
    }
    
    if( !fail ) {
        outValue = Word(inStr, inOutPos);
        if( outValue == "" ) {
            fail = true;
        }
        
    }
    
    if( fail ) {
        inOutPos = pos;
    }
    
    return !fail;
    
}


bool WhoParser::ZoomToRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "zoomToRing" ) {
        
        std::string ringName;
        if( KeyValue("ring", inStr, inOutPos, ringName) ) {
            
            who::Ring * ring = gGame.GetRing(ringName);
            if( ring != 0 ) {
                gGame.rings.currentRing = ring->name;
            }
        }
        
        int ringZ = -gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        float aspect = gGLData.viewport[2] / float(gGLData.viewport[3]);
        
        float endZ;
        Camera::FlyToRing(ringZ, aspect, gCameraData.fovX, gCameraData.fovY, endZ);
        ANM_CreateFloatAnimation(gCameraData.camX, 0, 2, InterpolationTypeSmooth, &gCameraData.camX);
        ANM_CreateFloatAnimation(gCameraData.camY, 0, 2, InterpolationTypeSmooth, &gCameraData.camY);
        ANM_CreateFloatAnimation(gCameraData.zoomed, 0, 2, InterpolationTypeLinear, &gCameraData.zoomed);
        currentAnmID = ANM_CreateFloatAnimation(gCameraData.camZ, endZ, 2, InterpolationTypeSmooth, &gCameraData.camZ);
        
        gGame.zoomedToPhoto = false;
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::ZoomToPhoto(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "zoomToPhoto" ) {
        
        std::string photoName;
        if( KeyValue("photo", inStr, inOutPos, photoName) ) {
            char command[256];
            int commandPos = 0;
            sprintf(command, "setCurrentPhoto photo=%s", photoName.c_str());
            PRS_Command(command, commandPos);
            
        }
        int ringZ = -gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        float aspect = gGLData.viewport[2] / float(gGLData.viewport[3]);
        
        float corners[3*4];
        float endPos[3];
        
        ComputeTopPhotoCorners(gGame.rings.rings[gGame.rings.currentRing], corners);
        Camera::FlyToPhoto(corners, aspect, gCameraData.fovX, gCameraData.fovY, endPos);
        
        endPos[2] += ringZ;
        endPos[1] += (kR1+kR0)*0.5f;
        ANM_CreateFloatAnimation(gCameraData.camX, endPos[0], 2, InterpolationTypeSmooth, &gCameraData.camX);
        ANM_CreateFloatAnimation(gCameraData.camY, endPos[1], 2, InterpolationTypeSmooth, &gCameraData.camY);
        ANM_CreateFloatAnimation(gCameraData.zoomed, 1, 2, InterpolationTypeLinear, &gCameraData.zoomed);
        currentAnmID = ANM_CreateFloatAnimation(gCameraData.camZ, endPos[2], 2, InterpolationTypeSmooth, &gCameraData.camZ);
        
        gGame.zoomedToPhoto = true;
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}

bool WhoParser::IncrementCurrentRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "incrementCurrentRing" ) {
        
        
        int currentRing = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        currentRing = glm::min(currentRing+1, int(gGame.rings.rings.size())-1);
        gGame.rings.currentRing = gGame.rings.stackingOrder[currentRing];
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}
bool WhoParser::DecrementCurrentRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "decrementCurrentRing" ) {
        
        
        int currentRing = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        currentRing = glm::max(currentRing-1, 0);
        gGame.rings.currentRing = gGame.rings.stackingOrder[currentRing];
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}


bool WhoParser::SetCurrentPhoto(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "setCurrentPhoto" ) {
        
        std::string value;
        if( KeyValue("photo", inStr, inOutPos, value) ) {
            
            who::Photo * photo = gGame.GetPhoto(value);
            
            who::Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            
            int startPhoto = ring.selectedPhoto;
            
            int indexDiff = photo->index - ring.selectedPhoto;
            if( abs(indexDiff) > ring.photos.size()/2 ) {
                int sign = (indexDiff > 0) ? 1 : -1;
                startPhoto += sign*ring.photos.size();
            }
            
            ring.selectedPhoto = photo->index;
            
            currentAnmID = ANM_CreateFloatAnimation(startPhoto, ring.selectedPhoto, 2, InterpolationTypeSmooth, &ring.currentPhoto);
            
            return true;
        }
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::DecrementCurrentPhoto(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "decrementCurrentPhoto" ) {
        
        who::Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
        int startPhoto;
        if( ring.selectedPhoto-1 < 0 ) {
            startPhoto = ring.currentPhoto + ring.photos.size();
            ring.selectedPhoto = ring.photos.size()-1;
        } else {
            startPhoto = ring.currentPhoto;
            ring.selectedPhoto--;
        }
        
        currentAnmID = ANM_CreateFloatAnimation(startPhoto, ring.selectedPhoto, 2, InterpolationTypeSmooth, &ring.currentPhoto);
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::AddImageFromText(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    std::string name;
    std::string text;
    if( Word(inStr, inOutPos) == "addImageFromText"
       && KeyValue("name", inStr, inOutPos, name)
       && KeyValue("text", inStr, inOutPos, text) )
    {
        GL_LoadTextureFromText(text, gGame.images[name]);
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}


bool WhoParser::AddImageFromFile(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    std::string name;
    std::string file;
    if( Word(inStr, inOutPos) == "addImageFromFile"
       && KeyValue("name", inStr, inOutPos, name)
       && KeyValue("file", inStr, inOutPos, file) )
    {
        GL_LoadTextureFromFile(file.c_str(), gGame.images[file]);//.back());
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}


bool WhoParser::AddPhotoToRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    std::string name;
    std::string image;
    std::string ringStr;
    
    if( Word(inStr, inOutPos) == "addPhotoToRing"
       && KeyValue("name", inStr, inOutPos, name)
       && KeyValue("image", inStr, inOutPos, image)
       && KeyValue("ring", inStr, inOutPos, ringStr))
    {
        who::Ring * ring = gGame.GetRing(ringStr);
        ring->photos.push_back(name);
        
        who::Photo photo;
        photo.filename = name;
        // photo.image = image;
        photo.ring = ringStr;
        photo.index = ring->photos.size()-1;
        gGame.photos[name] = photo;
        
        return true;
    }
    inOutPos = pos;
    return false;
}

bool WhoParser::AddMaskToPhoto(const char * inStr, int & inOutPos) {
    
    int pos = inOutPos;
    
    std::string name;
    std::string image;
    std::string photoStr;
    
    if( Word(inStr, inOutPos) == "addMaskToPhoto"
       && KeyValue("name", inStr, inOutPos, name)
       && KeyValue("image", inStr, inOutPos, image)
       && KeyValue("photo", inStr, inOutPos, photoStr) )
    {
        who::Photo * photo = gGame.GetPhoto(photoStr);
        
        photo->maskImages.push_back(image);
        photo->maskWeights.push_back(1);
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::NewBackRing(const char * inStr, int & inOutPos) {
    typedef void (* newBackRing_beginCallback)(who::Ring & inRing, void * inArgs);
    
    int pos = inOutPos;
    
    std::string nameStr;
    std::string beginStr;
    
    
    if( Word(inStr, inOutPos) == "newBackRing"
       && KeyValue("name", inStr, inOutPos, nameStr)
       && KeyValue("begin", inStr, inOutPos, beginStr) )
    {
        
        newBackRing_beginCallback beginCallback = (newBackRing_beginCallback)gGame.animationVars[beginStr];
        
        void * args = 0;
        std::string argsStr;
        if( KeyValue("args", inStr, inOutPos, argsStr) ) {
            args = gGame.animationVars[argsStr];
        }
        
        gGame.rings.rings[nameStr] = who::Ring(nameStr, who::eRingTypePlay);
        
        who::Ring & ring = gGame.rings.rings[nameStr];
        
        ring.stackingOrder = gGame.rings.stackingOrder.size();
        
        ring.currentPhoto = 0;
        ring.selectedPhoto = 0;
        
        gGame.rings.stackingOrder.push_back(nameStr);
        
        beginCallback(ring, args);
        
        ANM_CreateFloatAnimation(1e-7, 1, 2, InterpolationTypeSmooth, &ring.ringAlpha);
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}

bool WhoParser::PRS_Command(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( ZoomToRing(inStr, inOutPos) ) {
        
    } else if( ZoomToPhoto(inStr, inOutPos) ) {
        
    } else if( IncrementCurrentRing(inStr, inOutPos) ) {
        
    } else if( DecrementCurrentRing(inStr, inOutPos) ) {
        
    } else if( SetCurrentPhoto(inStr, inOutPos) ) {
        
    } else if( DecrementCurrentPhoto(inStr, inOutPos) ) {
        
    } else if( NewBackRing(inStr, inOutPos) ) {
        
    } else if( AddImageFromFile(inStr, inOutPos) ) {
        
    } else if( AddImageFromText(inStr, inOutPos) ) {
        
    } else if( AddPhotoToRing(inStr, inOutPos) ) {
        
    } else if( AddMaskToPhoto(inStr, inOutPos) ) {
        
        
    } else {
        inOutPos = pos;
        return false;
    }
    
    return true;
}      

}
