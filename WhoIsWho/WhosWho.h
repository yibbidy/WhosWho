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
#include "Camera.h"

namespace who
{
    // hm.. should these constants just be chilling out here?
    const float kR0 = 0.6f;  // inner ring radius
    const float kR1 = 1.0f;  // outer ring radius

    struct Photo
    {
        Photo() {
            _currentMask = -1;
            _transform = glm::mat4x3(1);
            _index = -1;
        }
        
        std::string _username;  // resource name of this image (Joe)
        std::string _filename;  // name of image(image.jpg, image2.jpg)
        std::string _ring;  // the ring this image lives on
        std::string _type;  // face mask or photo(face, mask, photo)
        
        int _index;  // index in parent ring._photos vector
        
        int _currentMask;
        
        std::vector<std::string> _maskImages;  // ordered set of imageDef resource// maskImage[1] = image mask1.png;
        std::vector<float> _maskWeights;  // the alpha of the mask, should be same size as maskImages
        
        glm::mat4x3 _transform;  // this transforms the unit square into on the XY plane into world space; it's algorithmetically computed when drawn
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
        int _imageI;  // index into gGame._phoos
        std::string _name;
        bool _isEditable;
    };
    
    struct Ring {
        Ring() {
            _ringAlpha = 1;
            _selectedPhoto = -1;
            _currentPhoto = -1;
            _ringType = ERingType(-1);
        }
        Ring(std::string inName, ERingType inRingType) {
            _name = inName;
            _ringAlpha = 1;
            _selectedPhoto = -1;
            _currentPhoto = -1;
            _ringType = inRingType;
            
            _stackingOrder = 0;
        }
        bool operator ==(const Ring & inRing) const {
            return _name == inRing._name;
        }
        bool operator !=(const Ring & inRing) const {
            return !(*this == inRing);
        }
        std::string _name;  // resource name
        int _stackingOrder;  // 0 is the top most ring (the title ring), 1 is the ring beneath it, etc.
        
        int _selectedPhoto;
        float _currentPhoto;
        std::vector<std::string> _photos;
        std::vector<std::string> maskPhotos;
        float _ringAlpha;  // when new rings are created they fade in
        
        ERingType _ringType;
        
        struct {  // used by localGame, remoteGame, userGame, friendGame
            
            // not implemented yet  std::vector<GameName> gameNames;
            std::vector<GameName> _localGameNames;
            std::vector<GameName> _remoteGameNames;
            
        } _browseData;
        
        struct {
            int _playImageI;
            int _createImageI;
            int _editImageI;
        } _titleData;
        
        
        struct {
            int _brushI;
            int _eraserI;
            int _scissorsI;
        } _editData;
        
    };
    
    struct Rings {
        Rings() {
            
        }
        std::vector<std::string> _stackingOrder;
        std::string _currentRing;  // resource name into 'rings'
        std::map<std::string, Ring> _rings;
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
        std::vector<std::string> _faceList;  // image resource names of the faces
        DraggingFace _draggingFace;
    };
    
    struct Drawer
    {
        std::string _name;
        std::vector<std::string> _photos;
    };
    
    struct Game
    // *** the main structure in this app ***
    // contains the current state of the game.
    // TODO should contain the camera
    {
        Game() {
            _faceDropdownAnim = 0;
            _zoomedToPhoto = false;
            _currentAnmID = 0;
            
            _currentDrawer = "";
            _drawerDropAnim = 0;
            _totalPhotosToDownload=-1;
            _photosDownloaded = 0;
        }
        
        void Execute(std::string inCommand, int inNumPairs = 0, ...);
        
        Ring * GetRing(std::string inName);
        Ring * GetBackRing();
        Ring * GetCurrentRing();
        Photo * GetPhoto(std::string inName);
        
        
        Rings _rings;  // this game shows a bunch of discs or rings with images on them.  this structure contains all the loaded rings
        std::vector<std::string> _faceList;  // the game shows a list of faces along the bottom that the user drags onto a ring.  This is an ordered list of image resource names
        
        float _faceDropdownAnim;
        std::map<std::string, ImageInfo> _images;  // loaded images that the faceList and the rings use.  they can be looked up by a resource name
        
        std::map<std::string, Photo> _photos;
        
        std::list<std::string> _animations;  // the list of sequential animations
        std::map<std::string, void *> _animationVars;  // animation variables - animation strings can reference these vars
        
        std::map<std::string, Drawer> _drawers;
        std::string _currentDrawer;  // == "" for no drawer
        float _drawerDropAnim;
        
        bool _zoomedToPhoto;
        int _currentAnmID;
        
        Camera _camera;
        ImageInfo  cancelImage;
        int _totalPhotosToDownload;
        int _photosDownloaded;
    };
    
    float SmoothFn(float inT, float * inParams);
    float LinearFn(float inT, float * /*inParams*/);

    void ComputeTopPhotoCorners(who::Ring & inRing, glm::vec3 * outCorners);
}

// *** the main global in this app ***
extern who::Game gGame;

#endif
