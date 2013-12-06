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

std::string WhoParser::Word(const char * inStr, int & inOutPos, char inDelim)
{
    
    EatWhitespace(inStr, inOutPos);
    
    std::string str;
    
    char ch = inStr[inOutPos];
    bool quote = ch == '"';
    if( quote ) {
        inOutPos++;
        ch = inStr[inOutPos];
    }
    
    
    while( ch && (quote || (ch!=' ' && ch!='\t' && ch!='\r' && ch!='\n' && ch!=inDelim)) ) {
        inOutPos++;
        
        if( ch == '"' ) {
            break;
        }
        
        str += ch;
        ch = inStr[inOutPos];
    }
    
    return str;
    
}



bool WhoParser::KeyValue(const char * inKey, const char * inStr, int & inOutPos, std::string & outValue)
{
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

std::map<std::string, std::string> WhoParser::KeyValues(const char * inStr, int & inOutPos)
{
    int pos;
    
    std::map<std::string, std::string> keyValueMap;
    
    while( true )
    {
        pos = inOutPos;
        std::string key = Word(inStr, inOutPos, '=');
        if( key == "" )
            break;
        
        EatWhitespace(inStr, inOutPos);
        char eq = inStr[inOutPos++];
        if( eq != '=' )
            break;
        
        std::string value = Word(inStr, inOutPos);
        if( value == "" )
            break;
        
        keyValueMap[key] = value;
    }
    
    inOutPos = pos;
    
    return keyValueMap;
}
    
void WhoParser::AnimationCompleted(const char * inStr, int & inOutPos, AnimationCompletedCallback & outCompleted, std::string & outArgs)
{
    std::string completedStr;
    if( KeyValue("completed", inStr, inOutPos, completedStr) )
    {
        outCompleted = (AnimationCompletedCallback)gGame.animationVars[completedStr];
        
        KeyValue("args", inStr, inOutPos, outArgs);
    }
}
    
bool WhoParser::ZoomToRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "zoomToRing" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto ringIt = keyValues.find("ring");
    
        if( ringIt != keyValues.end() )
        {
            who::Ring * ring = gGame.GetRing(ringIt->second);
            if( ring != 0 )
                gGame.rings.currentRing = ring->name;
        }
        
        AnimationCompletedCallback completed = 0;
        std::string args;
        AnimationCompleted(inStr, inOutPos, completed, args);
        
        int ringZ = -gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        float aspect = gGame.camera.viewport[2] / float(gGame.camera.viewport[3]);
        
        float endZ;

        Camera::FlyToRing(ringZ, aspect, gGame.camera.fovXY, endZ);
        AnimationSystem::CreateFloatAnimation(gGame.camera.pos.x, 0.0f, 2.0f, InterpolationTypeSmooth, &gGame.camera.pos.x);
        AnimationSystem::CreateFloatAnimation(gGame.camera.pos.y, 0.0f, 2.0f, InterpolationTypeSmooth, &gGame.camera.pos.y);
        AnimationSystem::CreateFloatAnimation(gGame.camera.zoomed, 0.0f, 2.0f, InterpolationTypeLinear, &gGame.camera.zoomed);
        gGame.currentAnmID = AnimationSystem::CreateFloatAnimation(gGame.camera.pos.z, endZ, 2.0f, InterpolationTypeSmooth, &gGame.camera.pos.z,
                                                                    completed, args.c_str());
        
        gGame.zoomedToPhoto = false;
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::ZoomToPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "zoomToPhoto" )
    {
        
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto photoIt = keyValues.find("photo");
        
        if( photoIt != keyValues.end() )
        {
            char command[256];
            int commandPos = 0;
            sprintf(command, "setCurrentPhoto photo=%s", photoIt->second.c_str());
            PRS_Command(command, commandPos, inErrorStream);
            
        }
        
        AnimationCompletedCallback completed = 0;
        std::string args;
        AnimationCompleted(inStr, inOutPos, completed, args);
        
        int ringZ = -gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        float aspect = gGame.camera.viewport[2] / float(gGame.camera.viewport[3]);
        
        glm::vec3 corners[4];
        glm::vec3 endPos;
        
        ComputeTopPhotoCorners(gGame.rings.rings[gGame.rings.currentRing], corners);
        Camera::FlyToPhoto(corners, aspect, gGame.camera.fovXY, endPos);
        
        endPos[2] += ringZ;
        endPos[1] += (kR1+kR0)*0.5f;

        AnimationSystem::CreateFloatAnimation(gGame.camera.pos.x, endPos[0], 2, InterpolationTypeSmooth, &gGame.camera.pos.x);
        AnimationSystem::CreateFloatAnimation(gGame.camera.pos.y, endPos[1], 2, InterpolationTypeSmooth, &gGame.camera.pos.y);
        AnimationSystem::CreateFloatAnimation(gGame.camera.zoomed, 1.0f, 2.0f, InterpolationTypeLinear, &gGame.camera.zoomed);
        gGame.currentAnmID = AnimationSystem::CreateFloatAnimation(gGame.camera.pos.z, endPos[2], 2, InterpolationTypeSmooth, &gGame.camera.pos.z,
                                                                    completed, args.c_str());

        gGame.zoomedToPhoto = true;
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}

bool WhoParser::IncrementCurrentRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "incrementCurrentRing" )
    {
        int currentRing = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        currentRing = glm::min(currentRing+1, int(gGame.rings.rings.size())-1);
        gGame.rings.currentRing = gGame.rings.stackingOrder[currentRing];
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}
    
bool WhoParser::DecrementCurrentRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "decrementCurrentRing" )
    {
        int currentRing = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
        currentRing = glm::max(currentRing-1, 0);
        gGame.rings.currentRing = gGame.rings.stackingOrder[currentRing];
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}
    
    
bool WhoParser::DisplayControlsForRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "DisplayControlsForRing" )
    {
        PopulateControlsForRing();
        
        return true;
    }
    
    inOutPos = pos;
    return false;
    
}
bool WhoParser::SetCurrentPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "setCurrentPhoto" ) {
        
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto photoIt = keyValues.find("photo");
        
        if( photoIt != keyValues.end() )
        {
            who::Photo * photo = gGame.GetPhoto(photoIt->second);
            
            who::Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            
            int startPhoto = ring.selectedPhoto;
            
            int indexDiff = photo->index - ring.selectedPhoto;
            if( abs(indexDiff) > ring.photos.size()/2 ) {
                int sign = (indexDiff > 0) ? 1 : -1;
                startPhoto += sign*ring.photos.size();
            }
            
            ring.selectedPhoto = photo->index;
            
            gGame.currentAnmID = AnimationSystem::CreateFloatAnimation(float(startPhoto), float(ring.selectedPhoto), 2.0f, InterpolationTypeSmooth, &ring.currentPhoto);
            
            return true;
        }
    
        inErrorStream << "error with:  " << inStr << "\n";
        if( photoIt == keyValues.end() )
            inErrorStream << "\trequired photo=<string>\n";

    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::DecrementCurrentPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
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
        
        gGame.currentAnmID = AnimationSystem::CreateFloatAnimation(float(startPhoto), float(ring.selectedPhoto), 2, InterpolationTypeSmooth, &ring.currentPhoto);
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::AddImageFromText(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "addImageFromText" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto nameIt = keyValues.find("name");
        auto textIt = keyValues.find("text");
        
        if( nameIt != keyValues.end() && textIt != keyValues.end() )
        {
            GL_LoadTextureFromText(textIt->second, gGame.images[nameIt->second]);
            return true;
        }
        
        
        inErrorStream << "error with:  " << inStr << "\n";
        if( nameIt == keyValues.end() )
            inErrorStream << "\tname=<sring> required\n";
        if( textIt != keyValues.end() )
            inErrorStream << "\ttext=<string> required\n";
    }
    
    inOutPos = pos;
    return false;
}
    
bool WhoParser::AddImageFromTextAndImage(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "addImageFromTextAndImage" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto nameIt = keyValues.find("name");
        auto textIt = keyValues.find("text");
        auto imageFileIt = keyValues.find("imageFile");
    
        if( nameIt!=keyValues.end() && textIt!=keyValues.end() && imageFileIt!=keyValues.end() )
        {
            GL_LoadTextureFromTextAndImage(textIt->second, imageFileIt->second, gGame.images[nameIt->second]);
            return true;
        }
       
        inErrorStream << "error with:  " << inStr << "\n";
        if( nameIt == keyValues.end() )
            inErrorStream << "\trequired name=<string>\n";
        if( textIt == keyValues.end() )
           inErrorStream << "\trequired test=<string>\n";
        if( imageFileIt == keyValues.end() )
           inErrorStream << "\trequired imageFile=<string>\n";
           
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::AddImageFromFile(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "addImageFromFile" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto fileIt = keyValues.find("file");
        
        if( fileIt!=keyValues.end() )
        {
            ImageInfo image;
            GL_LoadTextureFromFile(fileIt->second.c_str(), image);//.back());
       
            gGame.images[fileIt->second] = image;
        
            return true;
        }
        
        inErrorStream << "error with:  " << inStr << "\n";
        if( fileIt == keyValues.end() )
            inErrorStream << "\trequired file=<string>\n";
        
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::AddPhotoToRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "addPhotoToRing" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto nameIt = keyValues.find("name");
        auto userIt = keyValues.find("user");
        auto typeIt = keyValues.find("type");
        auto ringIt = keyValues.find("ring");
        
        if( nameIt!=keyValues.end() && userIt!=keyValues.end()
            && typeIt!=keyValues.end() && ringIt!=keyValues.end() )
        {
            std::string & name = nameIt->second;
            std::string & type = typeIt->second;
            
            Ring * ring = gGame.GetRing(ringIt->second);
            Photo photo;
            photo.filename = name;
            photo.username = userIt->second;
            photo.type = type;
            photo.ring = ringIt->second;
            ImageInfo imageInfo = gGame.images[name];
            
            if ( imageInfo.image)
            {
                if (type == "mask")
                    ring->maskPhotos.push_back(name);
                else if (type=="face")
                    ring->facePhotos.push_back(name);
                else
                    ring->photos.push_back(name);
                
                photo.index = ring->photos.size()-1;
                gGame.photos[name] = photo;
            }
            return true;
        }
        
        inErrorStream << "error with:  " << inStr << "\n";
        if( nameIt == keyValues.end() )
            inErrorStream << "\trequired name=<string>\n";
        if( userIt == keyValues.end() )
            inErrorStream << "\trequired user=<string>\n";
        if( typeIt == keyValues.end() )
            inErrorStream << "\trequired type=<string>\n";
        if( ringIt == keyValues.end() )
            inErrorStream << "\trequired ring=<string>\n";
    }
    inOutPos = pos;
    return false;
}

bool WhoParser::AddMaskToPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "addMaskToPhoto" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto imageIt = keyValues.find("image");
        auto photoIt = keyValues.find("photo");
        
        if( imageIt!=keyValues.end() && photoIt!=keyValues.end() )
        {
            who::Photo * photo = gGame.GetPhoto(photoIt->second);
        
            photo->_maskImages.push_back(imageIt->second);
            photo->_maskWeights.push_back(1);
        
            return true;
        }
       
    
        inErrorStream << "error with:  " << inStr << "\n";
        if( imageIt == keyValues.end() )
            inErrorStream << "\trequired image=<string>\n";
        if( photoIt == keyValues.end() )
            inErrorStream << "\trequired photo=<string>\n";

    }
    
    inOutPos = pos;
    return false;
}
bool WhoParser::NewBackRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    typedef void (* newBackRing_beginCallback)(who::Ring & inRing, void * inArgs);
    
    int pos = inOutPos;
    
    
    if( Word(inStr, inOutPos) == "newBackRing" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto nameIt = keyValues.find("name");
        auto beginIt = keyValues.find("begin");
        
        if( nameIt != keyValues.end() && beginIt != keyValues.end() )
        {
            std::string & name = nameIt->second;
            newBackRing_beginCallback beginCallback = (newBackRing_beginCallback)gGame.animationVars[beginIt->second];
            
            void * args = 0;
            auto argsIt = keyValues.find("args");
            if( argsIt != keyValues.end() )
                args = gGame.animationVars[argsIt->second];
            
            if (!args)
                args = StringToNSString(argsIt->second);
            
            gGame.rings.rings[name] = who::Ring(name, who::eRingTypePlay);
            
            who::Ring & ring = gGame.rings.rings[name];
            
            ring.stackingOrder = gGame.rings.stackingOrder.size();
            
            ring.currentPhoto = 0;
            ring.selectedPhoto = 0;
            
            gGame.rings.stackingOrder.push_back(name);
            
            beginCallback(ring, args);
            
            AnimationSystem::CreateFloatAnimation(1e-7f, 1.0f, 2, InterpolationTypeSmooth, &ring.ringAlpha);
            
            return true;
        }
       
        inErrorStream << "error with:  " << inStr << "\n";
        if( nameIt == keyValues.end() )
            inErrorStream << "\trequired name=<string>\n";
        if( beginIt == keyValues.end() )
            inErrorStream << "\trequired begin=<string>\n";

    }
    
    inOutPos = pos;
    return false;
    
}
    
bool WhoParser::DeleteRingsAfter(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
           
    if( Word(inStr, inOutPos) == "deleteRingsAfter" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto ringIt = keyValues.find("ring");
    
        if( ringIt != keyValues.end() )
        {
            std::string keepRing = ringIt->second;
            
            int keepRingI = 0;
            for( keepRingI=0; keepRingI<gGame.rings.stackingOrder.size(); keepRingI++ )
                if( gGame.rings.stackingOrder[keepRingI] == keepRing )
                    break;
            
            keepRingI++;
            if( keepRingI < gGame.rings.stackingOrder.size() )
            {
                while( gGame.rings.stackingOrder.back() != keepRing )
                {
                    gGame.rings.rings.erase(gGame.rings.stackingOrder.back());
                    gGame.rings.stackingOrder.pop_back();
                }
            }
           
            return true;
        }
        
        
        inErrorStream << "error with:  " << inStr << "\n";
        if( ringIt == keyValues.end() )
            inErrorStream << "\trequired ring=<string>\n";
    }
    
    inOutPos = pos;
    return false;
}
    
bool WhoParser::NewDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    typedef void (* newDrawer_populateCallback)(who::Drawer & inOutDrawer, void * inArgs);
    
    if( Word(inStr, inOutPos) == "newDrawer" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto nameIt = keyValues.find("name");
        auto populateIt = keyValues.find("populate");
        
        if( nameIt != keyValues.end() && populateIt != keyValues.end() )
        {
            newDrawer_populateCallback populateCallback = (newDrawer_populateCallback)gGame.animationVars[populateIt->second];
            
            who::Drawer & newDrawer = gGame.drawers[nameIt->second];
            newDrawer.name = nameIt->second;
            
            populateCallback(newDrawer, 0);
            
            return true;
        }
        
        inErrorStream << "error with:  " << inStr << "\n";
        if( nameIt == keyValues.end() )
            inErrorStream << "\trequired name=<string>\n";
        if( populateIt == keyValues.end() )
            inErrorStream << "\trequired populate=<callback>\n";
        
    }
    
    inOutPos = pos;
    return false;
        
}
    
    
bool WhoParser::AddPhotoToDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "addPhotoToDrawer" )
    {
        std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
        auto drawerIt = keyValues.find("drawer");
        auto photoIt = keyValues.find("photo");
        
        if( drawerIt != keyValues.end() && photoIt != keyValues.end() )
        {
            who::Drawer & drawer = gGame.drawers[drawerIt->second];
            drawer.photos.push_back(photoIt->second);
            
            return true;
        }
        
        inErrorStream << "error with:  " << inStr << "\n";
        if( drawerIt == keyValues.end() )
            inErrorStream << "\trequired drawer=<string>\n";
        if( photoIt == keyValues.end() )
            inErrorStream << "\trequired photo=<string>\n";
       
    }
    
    inOutPos = pos;
    return false;
    
}

    
bool WhoParser::ShowDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
   if( Word(inStr, inOutPos) == "showDrawer" )
   {
       std::map<std::string, std::string> keyValues = KeyValues(inStr, inOutPos);
       auto drawerIt = keyValues.find("drawer");
       auto locationIt = keyValues.find("location");
       
  
       if( drawerIt != keyValues.end() && locationIt != keyValues.end() )
       {
           if( locationIt->second == "bottom" )
               gGame.currentDrawer = drawerIt->second;
            
           if( gGame.drawerDropAnim < 1.0 )
               AnimationSystem::CreateFloatAnimation(1e-7f, 1.0f, 2, InterpolationTypeSmooth, &gGame.drawerDropAnim);

           return true;
       }
       
       inErrorStream << "error with:  " << inStr << "\n";
       if( drawerIt == keyValues.end() )
           inErrorStream << "\trequired drawer=<string>\n";
       if( locationIt == keyValues.end() )
           inErrorStream << "\trequired location=(top|bottom)\n";
       
    }
    
    inOutPos = pos;
    return false;
}
    
    
bool WhoParser::HideDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream)
{
    int pos = inOutPos;
    
    if( Word(inStr, inOutPos) == "hideDrawer" )
    {
        AnimationSystem::CreateFloatAnimation(gGame.drawerDropAnim, 0.0f, 2, InterpolationTypeSmooth, &gGame.drawerDropAnim);
        return true;
    }
    
    inOutPos = pos;
    return false;
}
    
bool WhoParser::PRS_Command(const char * inStr, int & inOutPos, std::ostream & inErrorStream) {
    int pos = inOutPos;
    
    typedef bool (* ParseFunc)(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static ParseFunc parseFuncs[] =
    {
        ZoomToRing, ZoomToPhoto, IncrementCurrentRing, DecrementCurrentRing,
        SetCurrentPhoto, DecrementCurrentPhoto, NewBackRing, DeleteRingsAfter,
        DisplayControlsForRing, AddImageFromFile, AddImageFromText, AddImageFromTextAndImage,
        AddPhotoToRing, AddMaskToPhoto, NewDrawer, AddPhotoToDrawer,
        ShowDrawer, HideDrawer
    };
    
    bool success = false;
    
    size_t numFuncs = sizeof(parseFuncs) / sizeof(ParseFunc);
    for( size_t i=0; i<numFuncs && !success; i++ )
        success = parseFuncs[i](inStr, inOutPos, inErrorStream);
    

    if( !success )
        inOutPos = pos;
        
    return success;}      

}
