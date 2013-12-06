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
#include <iostream>
#include "utilities.h"
#include "Camera.h"

namespace who
{
    // hm.. should these constants just be chilling out here?
    const float kR0 = 0.6f;  // inner ring radius
    const float kR1 = 1.0f;  // outer ring radius
    const float kDepthOffset = 0.0001f;
    
    struct Photo
    {
        Photo() {
            _currentMask = -1;
            transform = glm::mat4x3(1);
            index = -1;
        }
        
        std::string username;  // resource name of this image (Joe)
        std::string filename;  // name of image(image.jpg, image2.jpg)
        std::string ring;  // the ring this image lives on
        std::string type;  // face mask or photo(face, mask, photo)
        
        int index;  // index in parent ring.photos vector
        
        int _currentMask;
        
        std::vector<std::string> _maskImages;  // ordered set of imageDef resource// maskImage[1] = image mask1.png;
        std::vector<float> _maskWeights;  // the alpha of the mask, should be same size as maskImages
        
        glm::mat4x3 transform;  // this transforms the unit square into on the XY plane into world space; it's algorithmetically computed when drawn
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
        int imageI;  // index into gGame.phoos
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
        std::vector<std::string> maskPhotos;
        std::vector<std::string> facePhotos;
        float ringAlpha;  // when new rings are created they fade in
        
        ERingType ringType;
        
        struct {  // used by localGame, remoteGame, userGame, friendGame
            
            // not implemented yet  std::vector<GameName> gameNames;
            std::vector<GameName> _localGameNames;
            std::vector<GameName> remoteGameNames;
            
        } _browseData;
        
        struct {
            int _playImageI;
            int _createImageI;
            int _editImageI;
        } _titleData;
        
        
        struct {
            int _brushI;
            int eraserI;
            int _scissorsI;
        } _editData;
        
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
            _faceI = -1;
            _x = 0;
            _y = 0;
        }
        int _faceI;
        int _x, _y;
    };
    

    struct Faces {
        std::vector<std::string> faceList;  // image resource names of the faces
        DraggingFace _draggingFace;
    };
    
    struct Drawer
    {
        std::string name;
        std::vector<std::string> photos;
    };
    
    struct Game
    // *** the main structure in this app ***
    // contains the current state of the game.
    // TODO should contain the camera
    {
        Game() : errorStream(std::cout)
        {
            faceDropdownAnim = 0;
            zoomedToPhoto = false;
            currentAnmID = 0;
            
            currentDrawer = "";
            drawerDropAnim = 0;
            totalPhotosToDownload=-1;
            currentNumOfPhotos = 0; 
        }
        
        void Execute(std::string inCommand, int inNumPairs = 0, ...);
        void ExecuteImmediately(std::string inCommand, int inNumPairs = 0, ...);
        
        Ring * GetRing(std::string inName);
        Ring * GetBackRing();
        Ring * GetCurrentRing();
        Photo * GetPhoto(std::string inName);
        
        std::ostream & errorStream;
        
        Rings rings;  // this game shows a bunch of discs or rings with images on them.  this structure contains all the loaded rings
        std::vector<std::string> faceList;  // the game shows a list of faces along the bottom that the user drags onto a ring.  This is an ordered list of image resource names
        
        float faceDropdownAnim;
        std::map<std::string, ImageInfo> images;  // loaded images that the faceList and the rings use.  they can be looked up by a resource name
        
        std::map<std::string, Photo> photos;
        
        std::list<std::string> animations;  // the list of sequential animations
        std::map<std::string, void *> animationVars;  // animation variables - animation strings can reference these vars
        
        std::map<std::string, Drawer> drawers;
        std::string currentDrawer;  // == "" for no drawer
        float drawerDropAnim;
        
        bool zoomedToPhoto;
        int currentAnmID;
        
        Camera camera;
        Photo  cancelImagePhoto;
        int totalPhotosToDownload;
        int currentNumOfPhotos;
    };
    
    float SmoothFn(float inT, float * inParams);
    float LinearFn(float inT, float * /*inParams*/);

    void ComputeTopPhotoCorners(who::Ring & inRing, glm::vec3 * outCorners);
}

// *** the main global in this app ***
extern who::Game gGame;

#endif
