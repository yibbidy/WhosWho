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
                gGame._rings._currentRing = ring->_name;
            }
        }
        
        int ringZ = -gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
        float aspect = gGame._camera._viewport[2] / float(gGame._camera._viewport[3]);
        
        float endZ;

        Camera::FlyToRing(ringZ, aspect, gGame._camera._fovXY, endZ);
        AnimationSystem::CreateFloatAnimation(gGame._camera._pos.x, 0.0f, 2.0f, InterpolationTypeSmooth, &gGame._camera._pos.x);
        AnimationSystem::CreateFloatAnimation(gGame._camera._pos.y, 0.0f, 2.0f, InterpolationTypeSmooth, &gGame._camera._pos.y);
        AnimationSystem::CreateFloatAnimation(gGame._camera._zoomed, 0.0f, 2.0f, InterpolationTypeLinear, &gGame._camera._zoomed);
        gGame._currentAnmID = AnimationSystem::CreateFloatAnimation(gGame._camera._pos.z, endZ, 2.0f, InterpolationTypeSmooth, &gGame._camera._pos.z);
        
        gGame._zoomedToPhoto = false;
        
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
        int ringZ = -gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
        float aspect = gGame._camera._viewport[2] / float(gGame._camera._viewport[3]);
        
        glm::vec3 corners[4];
        glm::vec3 endPos;
        
        ComputeTopPhotoCorners(gGame._rings._rings[gGame._rings._currentRing], corners);
        Camera::FlyToPhoto(corners, aspect, gGame._camera._fovXY, endPos);
        
        endPos[2] += ringZ;
        endPos[1] += (kR1+kR0)*0.5f;

        AnimationSystem::CreateFloatAnimation(gGame._camera._pos.x, endPos[0], 2, InterpolationTypeSmooth, &gGame._camera._pos.x);
        AnimationSystem::CreateFloatAnimation(gGame._camera._pos.y, endPos[1], 2, InterpolationTypeSmooth, &gGame._camera._pos.y);
        AnimationSystem::CreateFloatAnimation(gGame._camera._zoomed, 1.0f, 2.0f, InterpolationTypeLinear, &gGame._camera._zoomed);
        gGame._currentAnmID = AnimationSystem::CreateFloatAnimation(gGame._camera._pos.z, endPos[2], 2, InterpolationTypeSmooth, &gGame._camera._pos.z);

        gGame._zoomedToPhoto = true;
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}

bool WhoParser::IncrementCurrentRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "incrementCurrentRing" ) {
        
        
        int currentRing = gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
        currentRing = glm::min(currentRing+1, int(gGame._rings._rings.size())-1);
        gGame._rings._currentRing = gGame._rings._stackingOrder[currentRing];
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}
bool WhoParser::DecrementCurrentRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "decrementCurrentRing" ) {
        
        
        int currentRing = gGame._rings._rings[gGame._rings._currentRing]._stackingOrder;
        currentRing = glm::max(currentRing-1, 0);
        gGame._rings._currentRing = gGame._rings._stackingOrder[currentRing];
        
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
            
            who::Ring & ring = gGame._rings._rings[gGame._rings._currentRing];
            
            int startPhoto = ring._selectedPhoto;
            
            int indexDiff = photo->_index - ring._selectedPhoto;
            if( abs(indexDiff) > ring._photos.size()/2 ) {
                int sign = (indexDiff > 0) ? 1 : -1;
                startPhoto += sign*ring._photos.size();
            }
            
            ring._selectedPhoto = photo->_index;
            
            gGame._currentAnmID = AnimationSystem::CreateFloatAnimation(float(startPhoto), float(ring._selectedPhoto), 2.0f, InterpolationTypeSmooth, &ring._currentPhoto);
            
            return true;
        }
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::DecrementCurrentPhoto(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "decrementCurrentPhoto" ) {
        
        who::Ring & ring = gGame._rings._rings[gGame._rings._currentRing];
        int startPhoto;
        if( ring._selectedPhoto-1 < 0 ) {
            startPhoto = ring._currentPhoto + ring._photos.size();
            ring._selectedPhoto = ring._photos.size()-1;
        } else {
            startPhoto = ring._currentPhoto;
            ring._selectedPhoto--;
        }
        
        gGame._currentAnmID = AnimationSystem::CreateFloatAnimation(float(startPhoto), float(ring._selectedPhoto), 2, InterpolationTypeSmooth, &ring._currentPhoto);
        
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
        GL_LoadTextureFromText(text, gGame._images[name]);
        
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
        GL_LoadTextureFromFile(file.c_str(), gGame._images[file]);//.back());
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}


bool WhoParser::AddPhotoToRing(const char * inStr, int & inOutPos) {
    int pos = inOutPos;
    
    std::string name;
    std::string user;
    std::string type;
    std::string ringStr;
    
    if( Word(inStr, inOutPos) == "addPhotoToRing"
       && KeyValue("name", inStr, inOutPos, name)
       && KeyValue("user", inStr, inOutPos, user)
       && KeyValue("type", inStr, inOutPos, type)
       && KeyValue("ring", inStr, inOutPos, ringStr))
    {
        Ring * ring = gGame.GetRing(ringStr);
        Photo photo;
        photo._filename = name;
        photo._username = user;
        photo._type = type;
        photo._ring = ringStr;
        
        if (type == "mask") {
            ring->maskPhotos.push_back(name);
        }
        else {
            ring->_photos.push_back(name);
        }
        
        photo._index = ring->_photos.size()-1;
        gGame._photos[name] = photo;
        
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
        
        photo->_maskImages.push_back(image);
        photo->_maskWeights.push_back(1);
        
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
        
        newBackRing_beginCallback beginCallback = (newBackRing_beginCallback)gGame._animationVars[beginStr];
        
        void * args = 0;
        std::string argsStr;
        if( KeyValue("args", inStr, inOutPos, argsStr) ) {
            args = gGame._animationVars[argsStr];
        }
        if (!args) {
            args = StringToNSString(argsStr);
        }
        gGame._rings._rings[nameStr] = who::Ring(nameStr, who::eRingTypePlay);
        
        who::Ring & ring = gGame._rings._rings[nameStr];
        
        ring._stackingOrder = gGame._rings._stackingOrder.size();
        
        ring._currentPhoto = 0;
        ring._selectedPhoto = 0;
        
        gGame._rings._stackingOrder.push_back(nameStr);
        
        beginCallback(ring, args);
        
        AnimationSystem::CreateFloatAnimation(1e-7f, 1.0f, 2, InterpolationTypeSmooth, &ring._ringAlpha);
        
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
