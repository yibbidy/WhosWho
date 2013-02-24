//
//  WhosWho.h
//  WhoIsWho
//
//  Created by Justin Hutchison on 2/23/13.
//
//

#ifndef WhoIsWho_WhosWho_h
#define WhoIsWho_WhosWho_h

#include <string>
#include <vector>
#include <map>
#include "utilities.h"

namespace who
{
    // hm.. should these constants just be chilling out here?
    const float kR0 = 0.6f;  // inner ring radius
    const float kR1 = 1.0f;  // outer ring radius

    struct Photo
    {
        Photo() {
            currentMask = -1;
            MAT4_LoadIdentity(transform);
            index = -1;
        }
        
        std::string username;  // resource name of this image (Joe)
        std::string filename;  // name of image(image.jpg, image2.jpg)
        std::string ring;  // the ring this image lives on
        std::string type;  // face mask or photo(face, mask, photo)
        
        int index;  // index in parent ring.photos vector
        
        int currentMask;
        
        std::vector<std::string> maskImages;  // ordered set of imageDef resource// maskImage[1] = image mask1.png;
        std::vector<float> maskWeights;  // the alpha of the mask, should be same size as maskImages
        
        float transform[16];  // this transforms the unit square into on the XY plane into world space; it's algorithmetically computed when drawn
    };
    
    enum ERingType {
        eRingTypeTitle,
        eRingTypeEdit,
        eRingTypePlay,
        eRingTypeCreate,
        eRingTypeBrowseLocal,
        eRingTypeBrowseMore,
        eRingTypeBrowseMine,
        eRingTypeBrowseFriends
    };
    
    struct GameName {
        int imageI;  // index into gImages
        std::string name;
        bool isEditable;
    };
    
    struct Ring {
        Ring() {
            ringAlpha = 1;
            selectedPhoto = -1;
            currentPhoto = -1;
            ringType = ERingType(-1);
        }
        Ring(std::string inName, ERingType inRingType) {
            name = inName;
            ringAlpha = 1;
            selectedPhoto = -1;
            currentPhoto = -1;
            ringType = inRingType;
            
            stackingOrder = 0;
        }
        bool operator ==(const Ring & inRing) const {
            return name == inRing.name;
        }
        bool operator !=(const Ring & inRing) const {
            return !(*this == inRing);
        }
        std::string name;  // resource name
        int stackingOrder;  // 0 is the top most ring (the title ring), 1 is the ring beneath it, etc.
        
        int selectedPhoto;
        float currentPhoto;
        std::vector<std::string> photos;
        
        float ringAlpha;  // when new rings are created they fade in
        
        ERingType ringType;
        
        struct {  // used by localGame, remoteGame, userGame, friendGame
            
            // not implemented yet  std::vector<GameName> gameNames;
            std::vector<GameName> localGameNames;
            std::vector<GameName> remoteGameNames;
            
        } browseData;
        
        struct {
            int playImageI;
            int createImageI;
            int editImageI;
        } titleData;
        
        
        struct {
            int brushI;
            int eraserI;
            int scissorsI;
        } editData;
        
    };
    
    struct Rings {
        Rings() {
            
        }
        std::vector<std::string> stackingOrder;
        std::string currentRing;  // resource name into 'rings'
        std::map<std::string, Ring> rings;
    };
    
    
    struct DraggingFace {
        DraggingFace() {
            faceI = -1;
            x = 0;
            y = 0;
        }
        int faceI;
        int x, y;
    };
    

    struct Faces {
        std::vector<std::string> faceList;  // image resource names of the faces
        DraggingFace draggingFace;
    };
    
    struct Game
    // *** the main structure in this app ***
    // contains the current state of the game.
    // TODO should contain the camera
    {
        Game() {
            faceDropdownAnim = 0;
            zoomedToPhoto = false;
        }
        
        void Execute(std::string inCommand, int inNumPairs = 0, ...);
        
        Ring * GetRing(std::string inName);
        Ring * GetBackRing();
        Ring * GetCurrentRing();
        Photo * GetPhoto(std::string inName);
        
        
        Rings rings;  // this game shows a bunch of discs or rings with images on them.  this structure contains all the loaded rings
        std::vector<std::string> faceList;  // the game shows a list of faces along the bottom that the user drags onto a ring.  This is an ordered list of image resource names
        
        float faceDropdownAnim;
        std::map<std::string, ImageInfo> images;  // loaded images that the faceList and the rings use.  they can be looked up by a resource name
        
        std::map<std::string, Photo> photos;
        
        std::list<std::string> animations;  // the list of sequential animations
        std::map<std::string, void *> animationVars;  // animation variables - animation strings can reference these vars
        
        bool zoomedToPhoto;
        
    };
    
    float SmoothFn(float inT, float * inParams);
    float LinearFn(float inT, float * /*inParams*/);

    void ComputeTopPhotoCorners(who::Ring & inRing, float * outCorners);
}

// *** the main global in this app ***
extern who::Game gGame;

#endif
