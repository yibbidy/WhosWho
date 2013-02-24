// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)
//  Justin Hutchison (yibbidy@gmail.com)

// The code in here draws a some rings that each contain a number of images in a circle path.
// The setup for the app is in setupGL().  The code to draw is in drawInRect().  The code to
// update aniation is in update().
//
// gGame is the main variable in this program.  gGame.images is a list of all the loaded image files.
// gGame.faceList contains indices into the image list of the faces.
//
// gGame.rings contains a vector of Ring structures.  Each
// Ring structure contains a vector of images (indices into gGame.images).
//
// gGame.images is another main variable which contains all the texture images.  Images in the ring
// structure reference into array by offset.
//
// To load an image do this:
// gGame.images.push_back(ImageInfo());
// GL_LoadTexture("filename.png", gGame.images.back());
// 
// To make and put a photo on a ring do this:
// Photo myPhoto;
// myPhoto.imageI = photoImageOffset;  // offset in gGame.images
// myRing.push_back(myPhoto);
//
// To make a new ring do this:
// Ring myRing;
// gGame.rings.rings.push_back(ring);
//
// To add a mask to a photo do this:
// myPhoto.maskImages.push_back(maskImageOffset);  // offset in gGame.images
// myPhoto.maskWeights.push_back(1.0f);  // this means the mask is opaque
//

#import "TViewController.h"
#include "gfx.h"
#include "utilities.h"
#import "Registration.h"
#import "FriendsListController.h"
#import "CreateNewAccount.h"
#import "glUtilities.h"
#import "ZipArchive/ZipArchive.h"
#include <map>
#include <fstream>
#include "glm/glm.hpp"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))
static const int kButtonWidth = 24;
static const int kButtonHeight = 21;
static const int kButtonOffsetX = 3;
static const int kGameNameTextEditHeight =20;
static const int kGameNameTextEditHeightBig =40;
static const int kButtonWidthBig = 34;
static const int kButtonHeightBig = 31;


struct ColorProgram {
    GLuint program;
    GLint positionLoc, uvLoc;  // vertex attribute
    GLint colorLoc, mvpMatLoc, imageTexture, imageWeight;  // uniforms
};
struct PhotoProgram
// this glsl program is used to draw the photos on the rings
{
    GLuint program;
    GLint positionLoc, uvLoc;
    GLint mvpLoc, scaleLoc, imageTexLoc, imageAlphaLoc, maskTexLoc, maskWeightLoc;
};


struct GLData {
    ColorProgram colorProgram;
    PhotoProgram photoProgram;
    
    float viewMat[16];
    float projectionMat[16];
    float mvpMat[16];
    float normalMat[16];
    
    int viewport[4];
    
    GLuint diskVAO;  // run disk geometry through color program
    GLuint diskInnerEdgeVAO;  // to emphasize the inner edge of the ring
    GLuint diskOuterEdgeVAO;  // to emphasize the outer edge of the ring
    GLuint diskVBO;  // disk geometry; vert[i] normal[i] interleaved triangle_strip
    int diskNumVertices;
    float diskTransform[16];
    
    GLuint squareVAO;  // used for photos with photo shader
    GLuint squareIBO;
    GLuint squareVBO;
    
    GLuint squareEdgeVAO;  // used for selected photo
    GLuint squareEdgeIBO;
    
    GLuint faceListVAO;  // used for drawing the list of faces through the color program
    
    std::string image; // image resource name (into gGame.images) of the image to bind for the photo shader
    std::string mask0, mask1;  // image resource names (into gGame.images) of the mask images
    
    
} gGLData;

const float kR0 = 0.6f;
const float kR1 = 1.0f;
const int kNone = -1;



struct SprayPaintArgs {
	SprayPaintArgs() {
		erase = false;
		brushSize = 18;
		pressure = 23;
        
		r = 1;
		g = 0;
		b = 0;
	}
    
	bool	erase;
	int		brushSize;
	int		pressure; // added (or subtracted if erase is true) to alpha
	double	r, g, b;
};

static void IMG_Clear(ImageInfo & inImage) {
    memset(inImage.image, 0, inImage.texHeight*inImage.rowBytes);
    
    glBindTexture(GL_TEXTURE_2D, inImage.texID);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, inImage.texWidth, inImage.texHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, inImage.image);
}

static int IMG_SprayPaint(ImageInfo & inImage, int inLastX, int inLastY, int inCurrX, int inCurrY, const SprayPaintArgs & inArgs) {
    int errorCode = 0;
    
	ImageInfo * imageInfo = &inImage;
    
	bool inErase = inArgs.erase;
	unsigned char red = inArgs.r * 255;
	unsigned char green = inArgs.g * 255;
	unsigned char blue = inArgs.b * 255;
    
	int brushSize = inArgs.brushSize;
	int halfBrushSize = brushSize/2;
	//int alphaInc = inArgs.pressure;
	//halfBrushSize = 17;
    
	int w = imageInfo->texWidth;
	int h = imageInfo->texHeight;
    
	double dx = inCurrX - inLastX;
	double dy = inCurrY - inLastY;
    
	int steps = 0;
    
	//static double t = 100;
    
    
	double xInc = 0;
	double yInc = 0;
	if( fabs(dx) > fabs(dy) ) {
		steps = fabs(dx);
		xInc = (dx > 0) ? 1 : -1;
		yInc = fabs(dy / dx);
		yInc *= (dy > 0) ? 1 : -1;
	} else {
		steps = fabs(dy);
		yInc = (dy > 0) ? 1 : -1;
		xInc = fabs(dx / dy);
		xInc *= (dx > 0) ? 1 : -1;
	}
    
    glBindTexture(GL_TEXTURE_2D, inImage.texID);
	
	double currY = inLastY;
	double currX = inLastX;
    
	int B = imageInfo->bitDepth/8;
    
	static unsigned char * block = 0; // cache
	static int blockBrushSize = 18;
	static int blockBpp = 4;
	if( !block || blockBrushSize!=brushSize || blockBpp != B ) {
		blockBrushSize = brushSize;
		blockBpp = B;
		if( block ) {
			delete [] block;
		}
		block = new unsigned char[blockBpp * blockBrushSize * blockBrushSize];
	}
    
	for( int step=0; step<steps; step++ ) {
        
		currY += yInc;
		currX += xInc;
        
		int xx = (int)currX;
		int yy = (int)currY;
        
		
		memset(block, 0, 4*brushSize*brushSize);
		
		for( int y = -halfBrushSize; y<brushSize-halfBrushSize; y++ ) {
			if( yy+y>=imageInfo->texHeight || yy+y<0 ) continue;
            
			for( int x = -halfBrushSize; x<brushSize-halfBrushSize; x++ ) {
				if( xx+x >= imageInfo->texWidth || xx+x < 0 ) continue;
                
				double alphaFactor = (halfBrushSize - glm::min(double(halfBrushSize), glm::sqrt((double)y*y + x*x))) / halfBrushSize;
				alphaFactor = pow(alphaFactor, 1.7);
                
				unsigned char alphaInc = (unsigned char)glm::max(0.0, glm::min(255.0, alphaFactor * inArgs.pressure));
                
				int index1 = ((y+halfBrushSize)*brushSize + (x+halfBrushSize))*B;
				int index2 = ((yy+y)*w + xx+x)*B;
                
				if( inErase ) {
					int alpha = imageInfo->image[index2+3];
					alpha = glm::max(0, int(alpha-(alphaInc*0.5)));
					imageInfo->image[index2+3] = (unsigned char)alpha;
                    
				} else {
					imageInfo->image[index2+0] = red;
					imageInfo->image[index2+1] = green;
					imageInfo->image[index2+2] = blue;
                    
					unsigned char alpha = imageInfo->image[index2+3];
					alpha = (unsigned char)glm::min(255, int(alpha)+alphaInc);
					
					imageInfo->image[index2+3] = alpha;
					
				}
                
				block[index1+0] = imageInfo->image[index2+0];
				block[index1+1] = imageInfo->image[index2+1];
				block[index1+2] = imageInfo->image[index2+2];
				block[index1+3] = imageInfo->image[index2+3];
                
			}
		}
        
		int xSize = brushSize;
		int xOffset = xx-halfBrushSize;
        if( xOffset > w ) {
            continue;
        }
		unsigned char * blockStart = &block[0];
		if( xOffset < 0 ) {
			xSize = brushSize + xOffset;
			blockStart += -xOffset * blockBpp;
			xOffset = 0;
		}
		int rOffset = xx+halfBrushSize;
		if( rOffset >= w ) {
			xSize = brushSize - (rOffset-w) - 1;
		}
		
		int ySize = brushSize;
		int yOffset = yy-halfBrushSize;
        if( yOffset > h ) {
            continue;
        }
		if( yOffset < 0 ) {
			ySize = brushSize + yOffset;
			blockStart += -yOffset*blockBrushSize * blockBpp;
			yOffset = 0;
		}
		int bOffset = yy+halfBrushSize;
		if( bOffset >= h ) {
			ySize = brushSize - (bOffset-h) - 1;
		}
        
		glTexSubImage2D(GL_TEXTURE_2D, 0, xOffset, yOffset, xSize, ySize, GL_RGBA, GL_UNSIGNED_BYTE, blockStart);
	}
    
    
	return errorCode;
}

struct Photo {
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
    NSString *name;
    BOOL isEditable;
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
        faceI = kNone;
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
    std::map<std::string, void *> animationVars;  // animation variables - animation std::strings can reference these vars
    
    bool zoomedToPhoto;
    
};

Game gGame; // *** the main global in this app ***


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
static void PopulateLocalGameNamesRing(Ring & inRing, void *) {
    GameName thisGame;
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:@"WhoIsWho"];
	
	NSString* fullExtension = [NSString stringWithFormat:@".%@",  @"who"];
	
	for (NSString* eachGameFolder in [fileManager subpathsOfDirectoryAtPath: gameFolderPath error:nil]){
		//check if it's our custom documemnt
		NSString *eachGameFolderFull = [gameFolderPath stringByAppendingPathComponent:eachGameFolder];
        // NSLog(eachGameFolderFull);
        
		NSString* fileName;
        std::string commandString;
        
		for ( fileName in [fileManager subpathsOfDirectoryAtPath: eachGameFolderFull error:nil]){
            //   NSLog(fileName);
			if ( [fileName rangeOfString: fullExtension ].location != NSNotFound  ) {
				//NSLog(eachGameFolderFull);
				//NSString *gameGameWithFullPath = [eachGameFolderFull stringByAppendingPathComponent:fileName];
				//[self.gamesWithFullPathArray addObject:gameGameWithFullPath];
				fileName = [fileName stringByDeletingPathExtension];
                
				thisGame.name =  fileName;
				thisGame.isEditable = true;
                thisGame.imageI = gGame.images.size();
                
                std::string nameString = fileName.UTF8String;
                //gGame.images.push_back(ImageInfo());
                //   GL_LoadTextureFromText(fileName,  gGame.images[fileName.UTF8String]);//.back());
                // gGame.animations.push_back("addImageFromText name=create text=Create");
                //  gGame.animations.push_back("addImageFromText name= namestd::string text=fileName);
                
                // name=\"002 face 001\" file=\"002 face 001.png\"
                
                //  Photo photo;
                //  photo.name = fileName.UTF8String;
                //     ring.photos.push_back(photo);
                //  ring.browseData.localGameNames.push_back(thisGame);
                
                std::string commandString = "addImageFromText name=";
                commandString += nameString;
                commandString += " text=";
                commandString +=NSStringToString(fileName);
                
                gGame.animations.push_back(commandString);
                
                std::string commandString2 = "addPhotoToRing name=";
                commandString2 += nameString;
                commandString2 +=" image=";
                commandString2 +=nameString;
                commandString2 +=" ring=";
                
                gGame.animations.push_back(commandString2 + inRing.name);
                
			}
		}
	}
}
static void displayAllLocalGameNames()
{
    // Add one more ring
    
    //   if( WHO_GetRing("local") != gNullRing ) {
    //     return;
    // }
    //gGame.rings.rings.push_back(Ring(eRingTypeBrowseLocal));
    // Ring & ring = WHO_NewBackRing("local", eRingTypeBrowseLocal);
    
	GameName thisGame;
	
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:@"WhoIsWho"];
	
	NSString* fullExtension = [NSString stringWithFormat:@".%@",  @"who"];
	
	for (NSString* eachGameFolder in [fileManager subpathsOfDirectoryAtPath: gameFolderPath error:nil]){
		//check if it's our custom documemnt
		NSString *eachGameFolderFull = [gameFolderPath stringByAppendingPathComponent:eachGameFolder];
        // NSLog(eachGameFolderFull);
        
		NSString* fileName;
		for ( fileName in [fileManager subpathsOfDirectoryAtPath: eachGameFolderFull error:nil]){
            //   NSLog(fileName);
			if ( [fileName rangeOfString: fullExtension ].location != NSNotFound  ) {
				//NSLog(eachGameFolderFull);
				//NSString *gameGameWithFullPath = [eachGameFolderFull stringByAppendingPathComponent:fileName];
				//[self.gamesWithFullPathArray addObject:gameGameWithFullPath];
				fileName = [fileName stringByDeletingPathExtension];
                
				thisGame.name =  fileName;
				thisGame.isEditable = true;
                thisGame.imageI = gGame.images.size();
                
                
                //gGame.images.push_back(ImageInfo());
                //   GL_LoadTextureFromText(fileName,  gGame.images[fileName.UTF8String]);//.back());
                // gGame.animations.push_back("addImageFromText name=create text=Create");
                gGame.animations.push_back("addImageFromText name=fileName.UTF8String text=fileName");
                
                //  gGame.animations.push_back(std::string("addPhotoToRing name=fileName.UTF8String image=fileName.UTF8String ring=") + inRing.name);
                
                
                Photo photo;
                photo.filename = fileName.UTF8String;
                //     ring.photos.push_back(photo);
                //  ring.browseData.localGameNames.push_back(thisGame);
			}
		}
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
void PopulateTitleRing(Ring & inRing, void *)
// This function is the callback target to populate the title ring with items
{
    
    gGame.animations.push_back("addImageFromText name=play text=Play");
    gGame.animations.push_back("addImageFromText name=edit text=Edit");
    gGame.animations.push_back("addImageFromText name=create text=Create");
    
    gGame.animations.push_back(std::string("addPhotoToRing name=play image=play ring=") + inRing.name);
    gGame.animations.push_back(std::string("addPhotoToRing name=edit image=edit ring=") + inRing.name);
    gGame.animations.push_back(std::string("addPhotoToRing name=create image=create ring=") + inRing.name);
}
void PopulatePlayRing(Ring & inRing, void *)
// this function is the callback target to populate the play ring
{
#if 0 
    open game.txt
    read first line<#float inT#>, <#float *#>)
    if first line is "face"
        raed filename read username
        ggme.execuge"addPhoto filename username face";
    else if first line is mask
        read filename then read username
        ggame.execute"addphot ofilename username mask"
    else if line is Photo
        read photofilename
        "addphoto filename=photofilename"
        loop read maskfilename
            "add mask to photo photofilename+photofilename maskfilename=maskfilename"
        
        
        
        
#endif
        
    gGame.Execute("addImageFromFile name=joe file=001.jpg");
    gGame.Execute("addImageFromFile name=\"002 face 001\" file=\"002 face 001.png\"");
    gGame.Execute("addImageFromFile name=\"002 face 001\" file=\"002 face 002.png\"");
    
    gGame.Execute("addImageFromFile name=002 file=002.jpg");
    gGame.Execute("addImageFromFile name=003 file=003.jpg");
    gGame.Execute("addImageFromFile name=004 file=004.jpg");
    gGame.Execute("addImageFromFile name=005 file=005.jpg");
    gGame.Execute("addImageFromFile name=006 file=006.jpg");
    gGame.Execute("addImageFromFile name=007 file=007.jpg");
    gGame.Execute("addImageFromFile name=008 file=008.jpg");
    
    std::string ring = inRing.name;
    gGame.Execute(std::string("addPhotoToRing name=001.jpg image=001 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=001.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=001.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=002.jpg image=002 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=002.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=002.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=003.jpg image=003 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=003.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=003.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=004.jpg image=004 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=004.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=004.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=005.jpg image=005 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=005.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=005.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=006.jpg image=006 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=006.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=006.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=007.jpg image=007 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=007.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=007.jpg");
    
    gGame.Execute(std::string("addPhotoToRing name=008.jpg image=008 ring=") + ring);
    gGame.Execute("addMaskToPhoto name=mask001 image=\"002 face 001.png\" photo=008.jpg");
    gGame.Execute("addMaskToPhoto name=mask002 image=\"002 face 002.png\" photo=008.jpg");
    
}
void WHO_InitApp()
// This function allocates static opengl resources (shader programs, vertex arrays, texture images) for the game
// and creates the first ring - the Title ring.
{
    int err = 0;
    
    if( !err ) {  // load the glsl photo program
        NSString * vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"vs"];
        NSString * fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"photo" ofType:@"fs"];
        
        GLchar * vSource = (GLchar *)[[NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        GLchar * fSource = (GLchar *)[[NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        err = GFX_LoadGLSLProgram(vSource, fSource, gGLData.photoProgram.program,
                                  eGLSLBindingAttribute, "inPosition", &gGLData.photoProgram.positionLoc,
                                  eGLSLBindingAttribute, "inUV", &gGLData.photoProgram.uvLoc,
                                  eGLSLBindingUniform, "kMVPMat", &gGLData.photoProgram.mvpLoc,
                                  eGLSLBindingUniform, "kScale", &gGLData.photoProgram.scaleLoc,
                                  eGLSLBindingUniform, "kImageTex", &gGLData.photoProgram.imageTexLoc,
                                  eGLSLBindingUniform, "kImageAlpha", &gGLData.photoProgram.imageAlphaLoc,
                                  eGLSLBindingUniform, "kMaskTex", &gGLData.photoProgram.maskTexLoc,
                                  eGLSLBindingUniform, "kMaskWeight", &gGLData.photoProgram.maskWeightLoc,
                                  eGLSLBindingEnd);
    }
    
    if( !err ) {  // load the color glsl program
        NSString * vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"uniformColor" ofType:@"vs"];
        NSString * fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"uniformColor" ofType:@"fs"];
        
        GLchar * vSource = (GLchar *)[[NSString stringWithContentsOfFile:vertShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        GLchar * fSource = (GLchar *)[[NSString stringWithContentsOfFile:fragShaderPathname encoding:NSUTF8StringEncoding error:nil] UTF8String];
        
        err = GFX_LoadGLSLProgram(vSource, fSource, gGLData.colorProgram.program,
                                  eGLSLBindingAttribute, "inPosition", &gGLData.colorProgram.positionLoc,
                                  eGLSLBindingAttribute, "inUV", &gGLData.colorProgram.uvLoc,
                                  eGLSLBindingUniform, "kMVPMat", &gGLData.colorProgram.mvpMatLoc,
                                  eGLSLBindingUniform, "kColor", &gGLData.colorProgram.colorLoc,
                                  eGLSLBindingUniform, "kImageTexture", &gGLData.colorProgram.imageTexture,
                                  eGLSLBindingUniform, "kImageWeight", &gGLData.colorProgram.imageWeight,
                                  eGLSLBindingEnd);
    }
    
    if( !err ) {  // generate vbos and vaos
        
        // generate the vbo and vao for disk
        glGenVertexArraysOES(1, &gGLData.diskVAO);
        glBindVertexArrayOES(gGLData.diskVAO);
        
        glGenBuffers(1, &gGLData.diskVBO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData.diskVBO);
        std::vector<float> verts, normals, texCoords;
        GEO_GenerateDisc(0, 360, kR0, kR1, 0, 64, verts, normals, texCoords, 0);
        gGLData.diskNumVertices = verts.size()/3;
        unsigned int size = verts.size()*sizeof(float);
        glBufferData(GL_ARRAY_BUFFER, size, &verts[0], GL_STATIC_DRAW);
        glEnableVertexAttribArray(gGLData.colorProgram.positionLoc);
        glVertexAttribPointer(gGLData.colorProgram.positionLoc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
        
        
        glGenVertexArraysOES(1, &gGLData.diskInnerEdgeVAO);
        glBindVertexArrayOES(gGLData.diskInnerEdgeVAO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData.diskVBO);
        glEnableVertexAttribArray(gGLData.colorProgram.positionLoc);
        glVertexAttribPointer(gGLData.colorProgram.positionLoc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), BUFFER_OFFSET(0));
        
        glGenVertexArraysOES(1, &gGLData.diskOuterEdgeVAO);
        glBindVertexArrayOES(gGLData.diskOuterEdgeVAO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData.diskVBO);
        glEnableVertexAttribArray(gGLData.colorProgram.positionLoc);
        glVertexAttribPointer(gGLData.colorProgram.positionLoc, 3, GL_FLOAT, GL_FALSE, 6*sizeof(float), BUFFER_OFFSET(3*sizeof(float)));
        
        
        glGenVertexArraysOES(1, &gGLData.squareVAO);
        glBindVertexArrayOES(gGLData.squareVAO);
        GEO_GenerateRectangle(1, 1, verts, normals, texCoords);
        glGenBuffers(1, &gGLData.squareVBO);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData.squareVBO);
        glBufferData(GL_ARRAY_BUFFER, verts.size()*sizeof(float)+texCoords.size()*sizeof(float), 0, GL_STATIC_DRAW);
        
        glBufferSubData(GL_ARRAY_BUFFER, 0, verts.size()*sizeof(float), &verts[0]);
        glBufferSubData(GL_ARRAY_BUFFER, verts.size()*sizeof(float), texCoords.size()*sizeof(float), &texCoords[0]);
        
        glGenBuffers(1, &gGLData.squareIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gGLData.squareIBO);
        int indices[] = { 0, 1, 2, 3 };
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, 4*sizeof(int), indices, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(gGLData.photoProgram.positionLoc);
        glVertexAttribPointer(gGLData.photoProgram.positionLoc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(gGLData.photoProgram.uvLoc);
        glVertexAttribPointer(gGLData.photoProgram.uvLoc, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(verts.size()*sizeof(float)));
        
        
        glGenVertexArraysOES(1, &gGLData.squareEdgeVAO);
        glBindVertexArrayOES(gGLData.squareEdgeVAO);
        glGenBuffers(1, &gGLData.squareEdgeIBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gGLData.squareEdgeIBO);
        int indices2[] = { 0, 1, 3, 2 };
        glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(int)*4, &indices2[0], GL_STATIC_DRAW);
        glBindBuffer(GL_ARRAY_BUFFER, gGLData.squareVBO);
        glEnableVertexAttribArray(gGLData.colorProgram.positionLoc);
        glVertexAttribPointer(gGLData.colorProgram.positionLoc, 3, GL_FLOAT, GL_FALSE, 0, 0);
        
        
        glGenVertexArraysOES(1, &gGLData.faceListVAO);
        glBindVertexArrayOES(gGLData.faceListVAO);
        
        glBindBuffer(GL_ARRAY_BUFFER, gGLData.squareVBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, gGLData.squareIBO);
        
        glEnableVertexAttribArray(gGLData.colorProgram.positionLoc);
        glVertexAttribPointer(gGLData.colorProgram.positionLoc, 3, GL_FLOAT, GL_FALSE, 3*sizeof(float), BUFFER_OFFSET(0));
        glEnableVertexAttribArray(gGLData.colorProgram.uvLoc);
        glVertexAttribPointer(gGLData.colorProgram.uvLoc, 2, GL_FLOAT, GL_FALSE, 2*sizeof(float), BUFFER_OFFSET(verts.size()*sizeof(float)));
        
        glBindVertexArrayOES(0);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        
    }
    
    if( !err )
        // create and show the Title ring
    {
        gGame.Execute("newBackRing name=title begin=PopulateTitleRing", 1, "PopulateTitleRing", PopulateTitleRing);
        gGame.Execute("zoomToRing ring=title");
        gGame.rings.currentRing = "title";
    }
    
    glEnable(GL_DEPTH_TEST);
    
}

@interface TViewController(){
    
}
@property (assign) Photo *currentLoadedGame;
@end

@implementation TViewController
@synthesize popoverController;
@synthesize context = _context;
@synthesize effect = _effect;

-( void) uploadGame: (NSString *)usernameString passwd: passwordString
{
	if ( !putController )
		putController = [[PutController alloc]init]; 
    
    NSString *newFileName  = @"game1"; //[NSString std::stringWithUTF8String: curPhotoName.c_str()];	
 //   [self saveGame:newFileName];
   // NSString *gameDataFolderPath = (NSString *)getGameDataFolderPath();
    NSString *gameDataFolderPath = (NSString *)getGameDataFolderPath(newFileName); 
    newFileName =  [gameDataFolderPath stringByAppendingPathComponent: @"game1.who"]; 
    NSLog(newFileName);
    
	[putController setPutFileName:newFileName]; 
	[putController startCreate: usernameString];
}



-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    gameNavigationBar.topItem.title = @"todayGame"; 
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
     
    [self setupGL];
    
    //listController = [[ListController alloc] init]; 
    
    if ( 0){//listController ) {
      //  listController.renderView = self; 
		[listController startList]; 
    }

    gameName = nil;
    deleteGameButton = nil;
    loadGameButton = nil;
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
	pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&drawingLock, &attr);
    
}

- (void)viewDidUnload
{    
    gameDoneButton = nil;
    gameNavigationBar = nil;
    [super viewDidUnload];
    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
	self.context = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc. that aren't in use.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}



-(void) displayAllRemoteGameNames
{
    if( gGame.GetRing("browseMore") != 0 ) {
        return;
    }
    
    //gGame.rings.rings.push_back(Ring(eRingTypeBrowseMore));
  //  Ring & ring = WHO_NewBackRing("browseMore", eRingTypeBrowseMore);
    
    // First get all the games from server  
	NSString *fileName; 
	GameName thisGame;
    
	for ( int i = 0; i < [listController.listGameNames count]; i++){
		
		fileName = [listController.listGameNames objectAtIndex:i];
		//NSString *ext = [fileName pathExtension]; 
		if ( [[fileName pathExtension] caseInsensitiveCompare:@"who"] == NSOrderedSame) {
			fileName = [fileName stringByDeletingPathExtension];
			thisGame.name =  fileName;
			thisGame.isEditable = true;
            thisGame.imageI = gGame.images.size();
            
           
            //gGame.images.push_back(ImageInfo());
        //    GL_LoadTextureFromText(fileName,  gGame.images[fileName.UTF8String]);//.back()); 
            
            Photo photo;
            photo.filename = fileName.UTF8String;
            //photo.imageI = thisGame.imageI;
        //    ring.photos.push_back(photo); 
        //    ring.browseData.remoteGameNames.push_back(thisGame); 
           
		}
	}
    
    //gCurrentPattern = 0; 
    
    //gGame.rings.currentRing = gGame.rings.rings.size()-1;

}

-(void) createGameNameEditBox:(CGRect)textEditRect fontSize:(CGFloat)fontSize
{
    gameName = [[UITextField alloc] initWithFrame:textEditRect];
    gameName.delegate = self;
    gameName.font = [UIFont systemFontOfSize:fontSize];
    
    [gameName setBackgroundColor:[UIColor whiteColor]];
    gameName.text = StringToNSString(_currentLoadedGame->filename);
    
    gameName.adjustsFontSizeToFitWidth = YES;
    gameName.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [gameName setEnabled: YES];
    
    gameName.borderStyle = UITextBorderStyleRoundedRect;
    
    gameName.textAlignment = UITextAlignmentCenter;
    [self.view addSubview:gameName];

}
- (IBAction) requestToLoadGame:(id) sender
{
    gGame.Execute("newBackRing name=local begin=PopulatePlayRing", 1, "PopulatePlayRing", PopulatePlayRing);
    gGame.Execute("zoomToRing ring=ring2");
    
    deleteGameButton.hidden = YES;
    loadGameButton.hidden = YES;
    gameName.hidden = YES;
    
    if (_currentLoadedGame) {
        
        Ring * hitRing = gGame.GetCurrentRing();
        
       	float z = -hitRing->stackingOrder;
        float cornerPt[] = {-.5, .5, z,1};
        float cornerPt2[] = {.5, .5, z,1};
        
        MAT4_VEC4_Multiply(_currentLoadedGame->transform, cornerPt, cornerPt);
        MAT4_VEC4_Multiply(_currentLoadedGame->transform, cornerPt2, cornerPt2);
        MAT4_VEC4_Multiply(gGLData.mvpMat, cornerPt,cornerPt);
        MAT4_VEC4_Multiply(gGLData.mvpMat, cornerPt2,cornerPt2);
        int viewportWidth = gGLData.viewport[2];
        int viewportHeight = gGLData.viewport[3];
        
        cornerPt[0] /= cornerPt[3];
        cornerPt[1] /= cornerPt[3];
        cornerPt[2] /= cornerPt[3];
        
        cornerPt2[0] /= cornerPt2[3];
        cornerPt2[1] /= cornerPt2[3];
        cornerPt2[2] /= cornerPt2[3];
        
        //  VEC3_Set(-.23, .39, .98, cornerPt);
        cornerPt[0] = 0.5*viewportWidth*(cornerPt[0]+1.0);
        cornerPt[1] = viewportHeight- 0.5*viewportHeight*(cornerPt[1]+1.0);
        
        cornerPt2[0] = 0.5*viewportWidth*(cornerPt2[0]+1.0);
        cornerPt2[1] = viewportHeight- 0.5*viewportHeight*(cornerPt2[1]+1.0);
        
        float textWidth = cornerPt2[0]-cornerPt[0];
        float textStartX = cornerPt[0] - 0.5*textWidth;
        
        float offsetY = 20;
        CGRect textEditRect = CGRectMake(textStartX, offsetY, textWidth+100, kGameNameTextEditHeightBig);
        [self createGameNameEditBox:textEditRect fontSize:26];
        
        // add a save game button on the left
        CGRect buttonRect = CGRectMake(textEditRect.origin.x -kButtonWidthBig-kButtonOffsetX,offsetY, kButtonWidthBig, kButtonHeightBig);
        saveGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        UIImage *uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Save" ofType:@"png"]];
        
        [saveGameButton setImage:uiImage forState:UIControlStateNormal];
        [saveGameButton setBackgroundColor:nil];
        [saveGameButton setBackgroundImage:nil forState:UIControlStateNormal];
        
        saveGameButton.frame = buttonRect;
        [saveGameButton addTarget:self action:@selector(requestToSaveGame:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:saveGameButton];
        
        //Add a upload button on the right
       buttonRect = CGRectMake(textEditRect.origin.x+textEditRect.size.width+kButtonOffsetX,offsetY, kButtonWidthBig, kButtonHeightBig);
        uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"go_up" ofType:@"png"]];
        
        [uploadButton setImage:uiImage forState:UIControlStateNormal];
        [uploadButton setBackgroundColor:nil];
        [uploadButton setBackgroundImage:nil forState:UIControlStateNormal];
        
        uploadButton.frame = buttonRect;
        [uploadButton addTarget:self action:@selector(requestToUploadGame:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:uploadButton];
    }
}
-(void ) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch  locationInView:self.view];
    
    float viewPt[3];
    viewPt[0] = float(touchPoint.x);
    viewPt[1] = float(touchPoint.y);
    viewPt[2] = 0;  // on near clip plane
    
    float rayOrigin[3];
    float rayDir[3];
    
    GEO_MakePickRay(gGLData.viewMat, gGLData.projectionMat, gGLData.viewport, viewPt, rayOrigin, rayDir);
    
    Ring * hitRing = 0;
    Ring * currentRing = gGame.GetCurrentRing();
    
    float intersectPt[3];
    
    if( gGame.zoomedToPhoto ) {
        hitRing = currentRing;
    }
    else
    {
        
        
        for( int i=glm::max(0, currentRing->stackingOrder-1); i<gGame.rings.stackingOrder.size() && hitRing==0; i++ ) {
            Ring * ring = gGame.GetRing(gGame.rings.stackingOrder[i]);
            
            float ptOnPlane[3] = { 0, 0, -float(i) };
            float planeNormal[3] = { 0, 0, 1 };
            
            if( GEO_RayPlaneIntersection(ptOnPlane, planeNormal, rayOrigin, rayDir, 0, intersectPt) ) {
                float dist = VEC3_DistanceBetween(intersectPt, ptOnPlane);
                if( dist >= kR0 && dist <= kR1 ) {
                    hitRing = ring;
                }
            }
            
        }
    }
    
    Photo * hitPhoto = 0;
    
    if( gGame.GetCurrentRing() == hitRing ) {
        for( size_t i=0; i<hitRing->photos.size() & hitPhoto==0; i++ ) {
            Photo * photo = gGame.GetPhoto(hitRing->photos[i]);
            
            float z = -hitRing->stackingOrder;
            
            float photoVerts[] = {
                -0.5, -0.5, z,
                0.5, -0.5, z,
                -0.5, 0.5, z,
                0.5, 0.5, z,
            };
            
            MAT4_VEC3_Multiply(photo->transform, photoVerts+0, photoVerts+0);
            MAT4_VEC3_Multiply(photo->transform, photoVerts+3, photoVerts+3);
            MAT4_VEC3_Multiply(photo->transform, photoVerts+6, photoVerts+6);
            MAT4_VEC3_Multiply(photo->transform, photoVerts+9, photoVerts+9);
            
            if( GEO_RayTriangleIntersection(rayOrigin, rayDir, photoVerts+0, 0, intersectPt) ||
               GEO_RayTriangleIntersection(rayOrigin, rayDir, photoVerts+3, 0, intersectPt) ) {
                hitPhoto = photo;
            }
        }
    }
    
   char command[256];
    
    if( hitPhoto )
    {
        //_currentHitPhoto = hitPhoto;
    	if( hitPhoto->filename=="game2") {
            _currentLoadedGame = hitPhoto;
			//  WHO_Execute("newBackRing name=ring2 begin=PopulatePlayRing", 1, "PopulatePlayRing", PopulatePlayRing);
			//WHO_Execute("zoomToRing ring=ring2");
			
			float z = -hitRing->stackingOrder;
			float cornerPt[] = {-.5, -.5, z,1};
			float cornerPt2[] = {.5, -.5, z,1};
			
			MAT4_VEC4_Multiply(hitPhoto->transform, cornerPt, cornerPt);
			MAT4_VEC4_Multiply(hitPhoto->transform, cornerPt2, cornerPt2);
			MAT4_VEC4_Multiply(gGLData.mvpMat, cornerPt,cornerPt);
			MAT4_VEC4_Multiply(gGLData.mvpMat, cornerPt2,cornerPt2);
			int viewportWidth = gGLData.viewport[2];
			int viewportHeight = gGLData.viewport[3];
			
			cornerPt[0] /= cornerPt[3];
			cornerPt[1] /= cornerPt[3];
			cornerPt[2] /= cornerPt[3];
			
			cornerPt2[0] /= cornerPt2[3];
			cornerPt2[1] /= cornerPt2[3];
			cornerPt2[2] /= cornerPt2[3];
			
			//  VEC3_Set(-.23, .39, .98, cornerPt);
			cornerPt[0] = 0.5*viewportWidth*(cornerPt[0]+1.0);
			cornerPt[1] = viewportHeight- 0.5*viewportHeight*(cornerPt[1]+1.0);
			
			cornerPt2[0] = 0.5*viewportWidth*(cornerPt2[0]+1.0);
			cornerPt2[1] = viewportHeight- 0.5*viewportHeight*(cornerPt2[1]+1.0);
			
			// Add a delete button right below
			CGRect buttonRect = CGRectMake(cornerPt[0], cornerPt[1], kButtonWidth, kButtonHeight);
			deleteGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			
			UIImage *uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"list_remove" ofType:@"png"]];
			
			[deleteGameButton setImage:uiImage forState:UIControlStateNormal];
			[deleteGameButton setBackgroundColor:nil];
			[deleteGameButton setBackgroundImage:nil forState:UIControlStateNormal];
			
			deleteGameButton.frame = buttonRect;
			[self.view addSubview:deleteGameButton];
			
			//Add a load button
			buttonRect = CGRectMake(cornerPt[0]+kButtonWidth+kButtonOffsetX, cornerPt[1], kButtonWidth, kButtonHeight);
			loadGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
			
			uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"load2" ofType:@"png"]];
			
			[loadGameButton setImage:uiImage forState:UIControlStateNormal];
			[loadGameButton setBackgroundColor:[UIColor clearColor]];
			[loadGameButton setBackgroundImage:nil forState:UIControlStateNormal];
			loadGameButton.frame = buttonRect;
			[loadGameButton addTarget:self action:@selector(requestToLoadGame:) forControlEvents:UIControlEventTouchUpInside];
			
			[self.view addSubview:loadGameButton];
			
			//Add a text edit box for game name
			float textWidth = cornerPt2[0]-cornerPt[0];
			gameName = [[UITextField alloc] initWithFrame:CGRectMake(cornerPt[0], cornerPt[1]-kGameNameTextEditHeight, textWidth, kGameNameTextEditHeight)];
			gameName.delegate = self;
			gameName.font = [UIFont systemFontOfSize:12.0];
			
			[gameName setBackgroundColor:[UIColor whiteColor]];
			gameName.text = StringToNSString(hitPhoto->filename);
			
			gameName.adjustsFontSizeToFitWidth = YES;
			gameName.autocorrectionType = UITextAutocorrectionTypeNo;
			
			[gameName setEnabled: YES];
			
			gameName.borderStyle = UITextBorderStyleRoundedRect;
			
			gameName.textAlignment = UITextAlignmentCenter;
			[self.view addSubview:gameName];
    	}
    	else if( hitPhoto->filename == "play" ) {
            gGame.Execute("deleteBackRing"); 
            
            gGame.Execute("setCurrentPhoto photo=play");
            gGame.Execute("newBackRing name=ring1 begin=PopulateLocalGameNamesRing", 1, "PopulateLocalGameNamesRing", PopulateLocalGameNamesRing);
            gGame.Execute("zoomToRing ring=ring1");
            
        } else if( hitRing != 0 ) {
            
            if( gGame.zoomedToPhoto ) {
                gGame.Execute("zoomToRing");
                
            } else {
                sprintf(command, "zoomToPhoto photo=%s", hitPhoto->filename.c_str());
                gGame.Execute(command);
            }
        }
    } else if( hitRing ) {
        sprintf(command, "zoomToRing ring=%s", hitRing->name.c_str());
        gGame.Execute(command);
    }
}
- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    WHO_InitApp();
}


- (void)loadMenuRing
{
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // deallocate vbos, vaos, programs
    glDeleteBuffers(1, &gGLData.diskVBO);
    glDeleteVertexArraysOES(1, &gGLData.diskVAO);
    
    glDeleteBuffers(1, &gGLData.squareVBO);
    glDeleteVertexArraysOES(1, &gGLData.squareVAO);
    
    glDeleteProgram(gGLData.photoProgram.program);
    glDeleteProgram(gGLData.colorProgram.program);
}

static float SmoothFn(float inT, float * inParams) 
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


static float LinearFn(float inT, float * /*inParams*/) 
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

static void ComputeTopPhotoCorners(Ring & inRing, float * outCorners) {
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
    
    Photo & photo = gGame.photos[inRing.photos[inRing.selectedPhoto]];
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
#if 0
void ComputeTopPhotoCorners(int inRingI, float * outCorners) {
    float kPi = 3.141592654f;
    
    Ring & ring = gGame.rings.rings[inRingI];
    Photo & photo = ring.photos[ring.selectedPhoto];
    
    float length = (kR1-kR0)*0.5f * cosf(kPi*0.25f);
    float w, h;
    if( photo.aspect > 1 ) {
        w = length;
        h = length / photo.aspect;
    } else {
        w = length * photo.aspect;
        h = length;
    }
    float z = 0.01f;
    
    float corners[] = { 
        w, h, z,
        -w, h, z,
        w, -h, z,
        -w, -h, z };
    
    memcpy(outCorners, corners, 12*sizeof(float));
}
#endif

static void DrawRing(Ring & inRing, bool inZoomedIn, float * inMVPMat) {     
    
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);//(GL_BLEND);
    
    // Draw the ring (a disc)
    glUseProgram(gGLData.colorProgram.program);
    
    glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, inMVPMat);
    glUniform4f(gGLData.colorProgram.colorLoc, 0.2f, 0.3f, 1, inRing.ringAlpha);//0.8f);
    glUniform1f(gGLData.colorProgram.imageWeight, 0);
    glUniform1i(gGLData.colorProgram.imageTexture, 0);
    glBindVertexArrayOES(gGLData.diskVAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, gGLData.diskNumVertices);
    
    float mat[16];
    MAT4_Equate(inMVPMat, mat);
    MAT4_PostTranslate(0, 0, 0.001f, mat);
    glUseProgram(gGLData.colorProgram.program);
    glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, mat);
    glUniform4f(gGLData.colorProgram.colorLoc, 0, 0, 0, inRing.ringAlpha);
    glBindVertexArrayOES(gGLData.diskInnerEdgeVAO);
    glLineWidth(4.0f);
    glDrawArrays(GL_LINE_STRIP, 0, gGLData.diskNumVertices/2);
    
    glBindVertexArrayOES(gGLData.diskOuterEdgeVAO);
    glDrawArrays(GL_LINE_STRIP, 0, gGLData.diskNumVertices/2);
  
    // draw the images on the ring (a bunch of rects in a circle pattern)
    glUseProgram(gGLData.photoProgram.program);
    glBindVertexArrayOES(gGLData.squareVAO);
    
    glUniform1i(gGLData.photoProgram.imageTexLoc, 0);
    glUniform1f(gGLData.photoProgram.imageAlphaLoc, inRing.ringAlpha);
    glActiveTexture(GL_TEXTURE0);
  // glBindTexture(GL_TEXTURE_2D, gGame.images[0].texID);
#if 0 
    int masks[] = { 1, 2 };
     glUniform1iv(gGLData.photoProgram.maskTexLoc, 2, masks);
#endif 
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
    
    int startImageI = 0;
    int endImageI = numImages;
    
    if( inZoomedIn ) 
    // improve rendering performance by reducing the number of photos drawn when zoomed up close
    {
        if( inRing.selectedPhoto != kNone &&  inRing.selectedPhoto == inRing.currentPhoto ) {
            startImageI = inRing.selectedPhoto;
            endImageI = startImageI+1;
        } else {
            if( inRing.selectedPhoto < inRing.currentPhoto ) {  // if ring is rotating counter clockwise
                startImageI = inRing.selectedPhoto;
            } else {
                startImageI = inRing.selectedPhoto-1;
                if( startImageI < 0 ) {
                    startImageI = numImages + startImageI;
                }
            }
            endImageI = startImageI + 2;
        }
    }
    startImageI  = glm::max(0, startImageI); 
    for( int imageI=startImageI; imageI<endImageI; imageI++ ) {
        int i = imageI%numImages;
        
        float t = (i-inRing.currentPhoto)/float(halfNumImages);
        float halfStep = 0.5f/halfNumImages;
        
        float angle0 = kPi * spacingFn(t-halfStep, &p);
        float angle1 = kPi * spacingFn(t+halfStep, &p);
        float angle = (angle0 + angle1) * 0.5f;
        float dAngle = (angle1 - angle0) * 0.5f;
        angle0 = angle - glm::min(w0, dAngle);
        angle1 = angle + glm::min(w0, dAngle);
        
        float p0[] = { radius*cosf(angle0), radius*sinf(angle0) };  // top right point in world space
        float p1[] = { radius*cosf(angle1), radius*sinf(angle1) };  // top left point in world space
        float length = VEC2_Distance(p0, p1) / sqrtf(2.0);  // diagonal length of the image square
        
        Photo * photo = gGame.GetPhoto(inRing.photos[i]);
        ImageInfo & image = gGame.images[photo->filename];
        float aspect = image.originalWidth / float(image.originalHeight);
        float w, h;
        // compute world space width and height based on image's aspect ratio
        if( aspect > 1 ) {
            w = length;
            h = length / aspect;
        } else {
            w = length * aspect;
            h = length;
        }
        
        // build the matrix that transforms normalzied image corners to world space
        float mat[16];
        MAT4_MakeScale(w, h, 1, mat);
        MAT4_PreTranslate(0, radius, 0.01f, mat);
        MAT4_PreRotate(0, 0, 1, -angle, mat);
        MAT4_Equate(mat, photo->transform);
        
        MAT4_Multiply(inMVPMat, mat, mat);
        
        glUniformMatrix4fv(gGLData.photoProgram.mvpLoc, 1, GL_FALSE, mat);
        glUniform1f(gGLData.photoProgram.scaleLoc, 1);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, image.texID);
        glActiveTexture(GL_TEXTURE1);
        
        if( photo->maskImages.size() > 0 ) {
            glBindTexture(GL_TEXTURE_2D, gGame.images[photo->maskImages[0]].texID);
        }
        glActiveTexture(GL_TEXTURE2);
        if( photo->maskImages.size() > 1 ) {
            glBindTexture(GL_TEXTURE_2D, gGame.images[photo->maskImages[1]].texID);
        }
        float maskWeights[2];
        memset(maskWeights, 0, 2*sizeof(float));
        
        for_i( photo->maskWeights.size() ) {
            maskWeights[i] = photo->maskWeights[i];
        }
        
        glUniform1fv(gGLData.photoProgram.maskWeightLoc, 2, maskWeights);
        
        
        glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
        
        if( i == (inRing.selectedPhoto%inRing.photos.size()) )
        // the selected photo has a red box around it
        {
            glUseProgram(gGLData.colorProgram.program);
            glBindVertexArrayOES(gGLData.squareEdgeVAO);
            glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, mat);
            glUniform4f(gGLData.colorProgram.colorLoc, 1, 0, 0, inRing.ringAlpha);
            glDrawElements(GL_LINE_LOOP, 4, GL_UNSIGNED_INT, BUFFER_OFFSET(0));
            
            glUseProgram(gGLData.photoProgram.program);
            glBindVertexArrayOES(gGLData.squareVAO);
        }
    }

    glBindTexture(GL_TEXTURE_2D, 0);
    
    glLineWidth(1.0f);
    
    glBindVertexArrayOES(0);
}

static void MarkupMask(float inRotation) {
    // this function puts randomly placed dots on the mask
    static float lastP[] = { 
        0, 0,
        0, 0 };
    
    float currP[] = {
        700 + 2*150*cosf(inRotation), 720 - 150*sinf(2*inRotation),
        100 + 2*50*cosf(inRotation), 150 - 50*sin(2*inRotation) };
    
    if( lastP[0] == 0 ) {
        memcpy(lastP, currP, 4*sizeof(float));
    }
    
    SprayPaintArgs spa;
    spa.r = 1;
    spa.g = 0;
    spa.b = 0;
    spa.pressure = 20;
    spa.brushSize = 40;
    //spa.erase = true;
    IMG_SprayPaint(gGame.images[gGLData.mask0], lastP[0], lastP[1], currP[0], currP[1], spa);
    spa.r = 0;
    spa.g = 1;
    spa.b = 0;
    spa.pressure = 35;
    spa.brushSize = 10;
    //spa.erase = true;
    IMG_SprayPaint(gGame.images[gGLData.mask1], lastP[2], lastP[3], currP[2], currP[3], spa);
    
    memcpy(lastP, currP, 4*sizeof(float));
}

float gTick = 0;


 struct Camera {
    Camera() {
        zoomed = 0;
        camX = 0;
        camY = 0;
        camZ = 10;
    }
    
    static void FlyToRing(float inRingZ, float inWindowAspect, float inFOVXRad, float inFOVYRad, float & outCamZ);
    static void FlyToPhoto(float * inCorners, float inWindowAspect, float inFOVXRad, float inFOVYRad, float * outPos);
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
    
    float projectionMat[16];
} gCameraData;


void Camera::FlyToRing(float inRingZ, float inWindowAspect, float inFOVXRad, float inFOVYRad, float & outCamZ)
// Call this function to have to camera animate from where it currently is up -close to 'inRing'
{
	float radius = kR1;
	
	float halfFov;
	if( inWindowAspect < 1 ) {  // window is taller than it is wide
        halfFov = inFOVXRad * 0.5f;
	} else {
		halfFov = inFOVYRad * 0.5f;
	}
    
	float z = radius / tan(halfFov);
    
    outCamZ = inRingZ + z;
}

void Camera::FlyToPhoto(float * inCorners, float inWindowAspect, float inFOVXRad, float inFOVYRad, float * outPos)
// Call this function to have to camera animate from where it currently is up close to inImage
{
	
    float * p0 = inCorners+0;
	float * p1 = inCorners+3;
	float * p2 = inCorners+6;
	//float * p3 = inCorners+9;
	
	// p1 ----- p0
	// |        |
	// p3 ----- p2
	float dx = p0[0] - p1[0];
	float dy = p0[1] - p2[1];
	
	float camZ;
    
	float imageAspect = dx / dy;
	float windowAspect = inWindowAspect;
    
	if( imageAspect > windowAspect ) {
		// fit width
		camZ = dx*0.5f / tanf(inFOVXRad*0.5f);
		float yDist = 2*camZ * tanf(inFOVYRad*0.5f);
		if( yDist - dy < 0.02f ) {
			// leave space around the border so you can click the ring to go back
			dx += 0.02f - (yDist - dy);
			camZ = dx*0.5f / tanf(inFOVXRad*0.5f);
		}
	} else {
		camZ = dy*0.5f / tanf(inFOVYRad*0.5f);
		float xDist = 2*camZ * tanf(inFOVXRad*0.5f);
		if( xDist - dx < 0.02 ) {
			// leave space around the border so you can click the ring to go back
			dy += 0.02f - (xDist - dx);
			camZ = dy*0.5f / tanf(inFOVYRad*0.5f);
		}
	}
    
    VEC3_Average(p1, p2, outPos);
    outPos[2] += camZ;
}


void Camera::Setup(Camera & inCam, float inWindowAspect) {
    inCam.windowAspect = inWindowAspect;
    inCam.fovY = MTH_DegToRad(65.0f);
    inCam.halfNearPlaneHeight = 0.01f;
	inCam.nearPlaneDistance = inCam.halfNearPlaneHeight / tanf(inCam.fovY*0.5f);
	inCam.farPlaneDistance = 100;
	inCam.halfNearPlaneWidth = inCam.halfNearPlaneHeight * inCam.windowAspect;
	inCam.fovX = 2.0f * atanf(inCam.halfNearPlaneWidth / inCam.nearPlaneDistance);
	MAT4_MakeFrustum(-inCam.halfNearPlaneWidth, inCam.halfNearPlaneWidth, -inCam.halfNearPlaneHeight, inCam.halfNearPlaneHeight, inCam.nearPlaneDistance, inCam.farPlaneDistance, inCam.projectionMat);
    
}

int currentAnmID = 0;

class WhoParser
{
public:
    static bool PRS_Command(const char * inStr, int & inOutPos);
    
private:
    static void EatWhitespace(const char * inStr, int & inOutPos);
    static std::string Word(const char * inStr, int & inOutPos);
    static bool KeyValue(const char * inKey, const char * inStr, int & inOutPos, std::string & outValue);
    static bool ZoomToRing(const char * inStr, int & inOutPos);
    static bool ZoomToPhoto(const char * inStr, int & inOutPos);
    static bool IncrementCurrentRing(const char * inStr, int & inOutPos);
    static bool DecrementCurrentRing(const char * inStr, int & inOutPos);
    static bool SetCurrentPhoto(const char * inStr, int & inOutPos);
    static bool DecrementCurrentPhoto(const char * inStr, int & inOutPos);
    static bool AddImageFromText(const char * inStr, int & inOutPos);
    static bool AddImageFromFile(const char * inStr, int & inOutPos);
    static bool AddPhotoToRing(const char * inStr, int & inOutPos);
    static bool AddMaskToPhoto(const char * inStr, int & inOutPos);
    static bool NewBackRing(const char * inStr, int & inOutPos);
    static bool DeleteBackRing(const char * inStr, int &inOutPos);

};

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
        
            Ring * ring = gGame.GetRing(ringName);
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
        
            Photo * photo = gGame.GetPhoto(value);
            
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            
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

        Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
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
        Ring * ring = gGame.GetRing(ringStr);
        ring->photos.push_back(name);

        Photo photo;
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
        Photo * photo = gGame.GetPhoto(photoStr);

        photo->maskImages.push_back(image);
        photo->maskWeights.push_back(1);
        
        return true;
    }
    
    inOutPos = pos;
    return false;
}

bool WhoParser::NewBackRing(const char * inStr, int & inOutPos) {
    typedef void (* newBackRing_beginCallback)(Ring & inRing, void * inArgs);

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
        
        gGame.rings.rings[nameStr] = Ring(nameStr, eRingTypePlay);
        
        Ring & ring = gGame.rings.rings[nameStr];
        
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

- (void)update
// This function animates stuff
{
    if ( gGame.rings.currentRing == "") return; 
    
    gGLData.viewport[0] = 0;
    gGLData.viewport[1] = 0;
    gGLData.viewport[2] = self.view.bounds.size.width;
    gGLData.viewport[3] = self.view.bounds.size.height;
    
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    Camera::Setup(gCameraData, aspect);
    MAT4_Equate(gCameraData.projectionMat, gGLData.projectionMat);
    
    //float mv[16];
    MAT4_LoadIdentity(gGLData.viewMat);
    MAT4_Translate(-gCameraData.camX, -gCameraData.camY, -gCameraData.camZ, gGLData.viewMat);
    
    MAT4_Multiply(gGLData.projectionMat, gGLData.viewMat, gGLData.mvpMat);
    MAT4_Equate(gGLData.viewMat, gGLData.normalMat);
    VEC4_Set(0, 0, 0, 1, gGLData.normalMat+12);
    
    _rotation += self.timeSinceLastUpdate * 0.1f;
    gTick += self.timeSinceLastUpdate;
    
   // static int currentAnmID = 0;
    
    if( !ANM_IsRunning(currentAnmID) && !gGame.animations.empty() ) {
        
        /*const int pattern[] = { 
                eZoomToPhoto, eDecrementCurrentPhoto, 
                eZoomToRing, eDecrementCurrentPhoto,
                eIncrementCurrentRing, eZoomToRing };
        */
        
        std::string anm = gGame.animations.front();
        gGame.animations.pop_front();
        //pattern[gCurrentPattern];
        
        int pos = 0;
        WhoParser::PRS_Command(anm.c_str(), pos);
        /*
        if( anm == eZoomToRing ) {
            int ringZ = -gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
            
            float endZ;
            FlyToRing(ringZ, aspect, gCameraData.fovX, gCameraData.fovY, endZ);
            ANM_CreateFloatAnimation(gCameraData.camX, 0, 2, InterpolationTypeSmooth, &gCameraData.camX);
            ANM_CreateFloatAnimation(gCameraData.camY, 0, 2, InterpolationTypeSmooth, &gCameraData.camY);
            ANM_CreateFloatAnimation(gCameraData.zoomed, 0, 2, InterpolationTypeLinear, &gCameraData.zoomed);
            currentAnmID = ANM_CreateFloatAnimation(gCameraData.camZ, endZ, 2, InterpolationTypeSmooth, &gCameraData.camZ);
            
        } else if( anm == eZoomToPhoto ) { 
            int ringZ = -gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
            
            float corners[3*4];
            float endPos[3]; 
            
            ComputeTopPhotoCorners(gGame.rings.rings[gGame.rings.currentRing], corners);
            FlyToPhoto(corners, aspect, gCameraData.fovX, gCameraData.fovY, endPos);
            
            endPos[2] += ringZ;
            endPos[1] += (kR1+kR0)*0.5f;
            ANM_CreateFloatAnimation(gCameraData.camX, endPos[0], 2, InterpolationTypeSmooth, &gCameraData.camX);
            ANM_CreateFloatAnimation(gCameraData.camY, endPos[1], 2, InterpolationTypeSmooth, &gCameraData.camY);
            ANM_CreateFloatAnimation(gCameraData.zoomed, 1, 2, InterpolationTypeLinear, &gCameraData.zoomed);
            currentAnmID = ANM_CreateFloatAnimation(gCameraData.camZ, endPos[2], 2, InterpolationTypeSmooth, &gCameraData.camZ);
            
            

        } else if( anm == eIncrementCurrentRing ) {  // next ring
            int currentRing = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
            currentRing = glm::min(currentRing+1, int(gGame.rings.rings.size())-1);
            gGame.rings.currentRing = gGame.rings.stackingOrder[currentRing];
           
        } else if( anm == eDecrementCurrentRing ) {
            int currentRing = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
            currentRing = glm::max(currentRing-1, 0);
            gGame.rings.currentRing = gGame.rings.stackingOrder[currentRing];
            
        } else if( anm == eIncrementCurrentPhoto ) { 
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            int startPhoto;
            if( ring.selectedPhoto+1 >= ring.photos.size() ) {
                startPhoto = ring.currentPhoto - ring.photos.size();
                ring.selectedPhoto = 0;
            } else {
                startPhoto = ring.currentPhoto;
                ring.selectedPhoto++;
            }
            
            currentAnmID = ANM_CreateFloatAnimation(startPhoto, ring.selectedPhoto, 2, InterpolationTypeSmooth, &ring.currentPhoto);
            
        } else if( anm == eDecrementCurrentPhoto ) {
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            int startPhoto;
            if( ring.selectedPhoto-1 < 0 ) {
                startPhoto = ring.currentPhoto + ring.photos.size();
                ring.selectedPhoto = ring.photos.size()-1;
            } else {
                startPhoto = ring.currentPhoto;
                ring.selectedPhoto--;
            }
            
            currentAnmID = ANM_CreateFloatAnimation(startPhoto, ring.selectedPhoto, 2, InterpolationTypeSmooth, &ring.currentPhoto);
        } else if( anm == eFadeOutMask ) {
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            Photo & photo = ring.photos[ring.currentPhoto];
            if ( photo.currentMask != kNone ) {
                float & mask = photo.maskWeights[photo.currentMask];
                currentAnmID = ANM_CreateFloatAnimation(mask, 0, 2, InterpolationTypeSmooth, &mask);
            }
            else 
                currentAnmID = ANM_CreateFloatAnimation(ring.currentPhoto, 0, 2, InterpolationTypeSmooth, &ring.currentPhoto);
            
            
        } else if( anm == eFadeInMask ) {
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            Photo & photo = ring.photos[ring.currentPhoto];
            if ( photo.currentMask != kNone ) {
             float & mask = photo.maskWeights[photo.currentMask];
             currentAnmID = ANM_CreateFloatAnimation(mask, 1, 2, InterpolationTypeSmooth, &mask);
            }
            else 
                currentAnmID = ANM_CreateFloatAnimation(ring.currentPhoto, 0, 2, InterpolationTypeSmooth, &ring.currentPhoto);
            
        } else if( anm == eIncrementCurrentMask ) {
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            Photo & photo = ring.photos[ring.currentPhoto];
            photo.currentMask = (photo.currentMask+1) % photo.maskImageNames.size();
        
        } else if( anm == eDecrementCurrentMask ) {
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            Photo & photo = ring.photos[ring.currentPhoto];
            photo.currentMask--;
            
        } else if( anm == eDelay ) {
            static float waitTimer;
            currentAnmID = ANM_CreateFloatAnimation(0, 1, 2, InterpolationTypeLinear, &waitTimer);
            
        } else if( anm == eAddImage ) {  // add new image on back ring
          WHO_AddPhotoToBackRing("001.jpg", 2, "002 face 001.png", "002 face 002.png");
        
        } else if( anm == eRemoveImage ) {
            Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
            ring.photos.pop_back();
            
        }  else if( anm == eRemoveRing ) {
            WHO_DeleteBackRing();
        
        } else if( anm == eFacesDropdown ) {
            ANM_CreateFloatAnimation(gGame.faceDropdownAnim, 1, 2, InterpolationTypeLinear, &gGame.faceDropdownAnim);

        } else if( anm == eFacesPullup ) {
            ANM_CreateFloatAnimation(gGame.faceDropdownAnim, 0, 2, InterpolationTypeLinear, &gGame.faceDropdownAnim);

        } else if( anm == eDragFace1ToCenter ) {
            
            
        }
   */     
        //gCurrentPattern = (gCurrentPattern+1)%(sizeof(pattern)/sizeof(int));
    }
    
    //if( gGame.rings.currentRing == 0 ) {  // test code
    //    MarkupMask(_rotation*3);
    //}
    
    ANM_UpdateAnimations(gTick);
    
    std::vector<int> removedRingIndices;
    
    for_j( gGame.rings.stackingOrder.size() ) {
        
        Ring * ring = gGame.GetRing(gGame.rings.stackingOrder[j]);
        if( ring->ringAlpha == 0 )
        // delete the ring if its alpha has gone to 0
        {
            // remember the index in stacking order of the ring we're removing
            removedRingIndices.push_back(j);
            
            for_i( gGame.rings.stackingOrder.size() ) 
            // shift subsequent rings in the stacking order
            {
                Ring * shiftRing = gGame.GetRing(gGame.rings.stackingOrder[i]);
                shiftRing->stackingOrder--;
            }
            
            for_i( ring->photos.size() ) {
                Photo * photo = gGame.GetPhoto(ring->photos[i]);
                
                std::string resourceName = photo->filename;
                glDeleteTextures(1, &gGame.images[resourceName].texID);
                delete gGame.images[resourceName].image;
                gGame.images[resourceName].image = 0;
                
                for_j( photo->maskImages.size() ) {
                    resourceName = photo->maskImages[j];
                    glDeleteTextures(1, &gGame.images[resourceName].texID);
                    delete gGame.images[resourceName].image;
                    gGame.images[resourceName].image = 0;
                }
            }
            
            if( ring->ringType == eRingTypeEdit ) {
                std::string resourceName = "brush";
                glDeleteTextures(1, &gGame.images[resourceName].texID);
                delete gGame.images[resourceName].image;
                gGame.images[resourceName].image = 0;
                
                resourceName = "eraser";
                glDeleteTextures(1, &gGame.images[resourceName].texID);
                delete gGame.images[resourceName].image;
                gGame.images[resourceName].image = 0;
                
                resourceName = "scissors";
                glDeleteTextures(1, &gGame.images[resourceName].texID);
                delete gGame.images[resourceName].image;
                gGame.images[resourceName].image = 0;
                
            }
            if( gGame.rings.currentRing == gGame.rings.stackingOrder.back() ) {
                gGame.rings.currentRing = gGame.rings.stackingOrder[gGame.rings.stackingOrder.size()-2];
            }
            //gGame.rings.stackingOrder.pop_back();
            //gGame.rings.rings.erase(backRing);
        }

    }
    
    if( !removedRingIndices.empty() ) 
    // if any reings have been deleted, update the stackingOrder list
    {
        std::vector<std::string> newStackingOrder;
        
        int removedI = 0;
        
        for_i( removedRingIndices.size() ) {
            if( i == removedRingIndices[removedI] ) {
                removedI++;
            } else {
                newStackingOrder.push_back(gGame.rings.stackingOrder[i]);
            }
        }
        gGame.rings.stackingOrder = newStackingOrder;
    }
        
}

float GetTick() {
    return gTick;
}

- (void) drawFirstTierScreen
{}

//-(void) draw
void DrawFaceList(float inDropdownAnim) {
    
    // draw face list
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(gGLData.colorProgram.program);
    glBindVertexArrayOES(gGLData.squareVAO);
    glUniform4f(gGLData.colorProgram.colorLoc, 0, 0, 1, 1);
    glUniform1f(gGLData.colorProgram.imageWeight, 0);
    glUniform1i(gGLData.colorProgram.imageTexture, 0);
    glActiveTexture(GL_TEXTURE0);
    
    float height = 0.07f;
    float width = 0.1f;
    
    int currentRingZ = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
    
    float corners[3*4];
    ComputeTopPhotoCorners(gGame.rings.rings[gGame.rings.currentRing], corners);
    float top = (kR1+kR0)*0.5f + corners[2*3 + 1];
    width = corners[0*3 + 0] - corners[1*3 + 0];
    float dy = height * fabs(sinf(inDropdownAnim));
    float mat[16];
    MAT4_Equate(gGLData.mvpMat, mat);
    MAT4_PostTranslate(0, top - dy*0.5f, -currentRingZ+0.01f, mat);
    MAT4_PostScale(width, dy, 1, mat);
    glUniform4f(gGLData.colorProgram.colorLoc, 0.8f, 0.8f, 0.8f, 0.5f);
    glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, mat);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    int numItems = int(gGame.faceList.size());
    
    int xSpacing = 0;
    float centerX = -width*0.5f + height*0.5f;
    float xInc = height + xSpacing;
    
    centerX += xSpacing;
    if( width / height >= numItems )
    // simple layout of faces
    {  
        xInc = width / numItems;
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
    } 
    else 
    // shrink face images down to fit them all
    {  
        xInc = width / numItems;
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
        height = xInc;
        dy = height * fabs(sinf(inDropdownAnim));
        
    }
    
    for_i( numItems ) {
        
        MAT4_Equate(gGLData.mvpMat, mat);
        MAT4_PostTranslate(centerX, top - dy*0.5f, -currentRingZ+0.01f, mat);
        MAT4_PostScale(height, dy, 1, mat);
        glUniform4f(gGLData.colorProgram.colorLoc, 0.8f, 0.8f, 0.8f, 1);
        glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, mat);
        glBindTexture(GL_TEXTURE_2D, gGame.images[gGame.faceList[i]].texID);
        glUniform1f(gGLData.colorProgram.imageWeight, 1);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        centerX += xInc;
    }
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    
}

void DrawToolList(float inRotation) {
    
    float _rotation = inRotation;
    
    // draw tools
    glDisable(GL_DEPTH_TEST);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glUseProgram(gGLData.colorProgram.program);
    glBindVertexArrayOES(gGLData.squareVAO);
    glUniform4f(gGLData.colorProgram.colorLoc, 1, 1, 1, 0.3f);
    glUniform1f(gGLData.colorProgram.imageWeight, 0);
    glUniform1i(gGLData.colorProgram.imageTexture, 0);
    glActiveTexture(GL_TEXTURE0);
    
    float height = 0.04f;
    float width = 0.1f;
    
    int currentRingZ = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
    
    Ring & editRing = gGame.rings.rings[gGame.rings.currentRing];
    float corners[3*4];
    ComputeTopPhotoCorners(editRing, corners);
    float top = (kR0+kR1)*0.5f + corners[0*3 + 1] + height;
    width = corners[0*3 + 0] - corners[1*3 + 0];
    float dy = height * fabs(sinf(4*_rotation));
    float mat[16];
    MAT4_Equate(gGLData.mvpMat, mat);
    MAT4_PostTranslate(0, top - dy*0.5f, -currentRingZ+0.01f, mat);
    MAT4_PostScale(width, dy, 1, mat);
    glUniform4f(gGLData.colorProgram.colorLoc, 0.8f, 0.8f, 0.8f, 0.5f);
    glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, mat);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    int numItems = int(gGame.faceList.size());
    
    float xSpacing = 0.01;
    float centerX = -width*0.5f + height*0.5f;
    float xInc = height + xSpacing;
    
    centerX += xSpacing;
    if( width / height >= numItems ) {  // simple placement
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
    } else {  // shrink images down
        centerX = -width*0.5f + xInc - 0.5*xInc;
        
        height = xInc;
        dy = height * fabs(sinf(4*_rotation));
        
    }
    
    std::string faceList[] = { 
        "brush",
        "eraser",
        "scissors"
    };
    
    for_i( numItems ) {
        
        MAT4_Equate(gGLData.mvpMat, mat);
        MAT4_PostTranslate(centerX, top - dy*0.5f, -currentRingZ+0.01f, mat);
        MAT4_PostScale(height, dy, 1, mat);
        glUniform4f(gGLData.colorProgram.colorLoc, 0.8f, 0.8f, 0.8f, 1);
        glUniformMatrix4fv(gGLData.colorProgram.mvpMatLoc, 1, GL_FALSE, mat);
        glBindTexture(GL_TEXTURE_2D, gGame.images[faceList[i]].texID);
        glUniform1f(gGLData.colorProgram.imageWeight, 1);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        centerX += xInc;
    }
    
    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    
}
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
// this function draws the rings and photos
{
    [self update];
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    float mat[16];
    MAT4_Equate(gGLData.mvpMat, mat);
    
    int currentRingZ = gGame.rings.rings[gGame.rings.currentRing].stackingOrder;
    
    size_t startRingI = size_t(glm::max(currentRingZ-2, 0));
    size_t endRingI = gGame.rings.rings.size();
    
    if( gCameraData.zoomed == 1 ) {
        startRingI = currentRingZ;
        endRingI = startRingI+1;
    } 
    
    for( size_t i=startRingI; i < endRingI; i++ ) {
        
        Ring & ring = gGame.rings.rings[gGame.rings.stackingOrder[i]];
        //Photo & photo = gGame.GetPhoto(ring.photos[ring.currentPhoto]);

        float mvMat[16];
        MAT4_Equate(mat, mvMat);
        MAT4_PostTranslate(0, 0, -float(i), mvMat);
        
        DrawRing(ring, gCameraData.zoomed==1, mvMat);
#if 0 
        if( gGame.rings.currentRing==i && gGame.faceDropdownAnim>0 && gCameraData.zoomed==1 ) {
            if( ring.ringType == eRingTypeEdit ) {                
                DrawFaceList(gGame.faceDropdownAnim);
                DrawToolList(gGame.faceDropdownAnim);
            } else if(ring.ringType == eRingTypePlay ) {
                DrawFaceList(gGame.faceDropdownAnim);
            }
        }
#endif 
        
    }
    
    
}

- (BOOL)loadShaders
{
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    return YES;
}
-(void) dissmissPopoverController
{
    [self lock]; 
    [popoverController dismissPopoverAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil]; 
	//[self dismissModalViewControllerAnimated:NO];
	
    [self unlock]; 
}
#if 0 
bool giSaveGameData(GameImages & inOutGI, const std::string & inFilename) {
    
    gGame.photos

	GameImages & gi = inOutGI;
    
	ofstream out(inFilename.c_str());
    
	if( !out.is_open() ) {
		return GenerateErrorCode(1);
	}
    std::map<std::string, Photo>::iterator it
    
	for(  std::map<std::string, Photo>::iterator it = gGame.photos.begin(); it != gGame.photos.end(); it++ ) {
		Photo thisPhoto = it->second;
        
		out << "face \"" << thiPhoto.Photo<< "\"\n";
	}
    
    
	for( std::vector<GamePhoto *>::iterator it = gi.photos.begin(); it != gi.photos.end(); it++ ) {
		GamePhoto * photo = *it;
        
		out << "photo \"" << photo->filename << "\" ";
		for( std::vector<GameFace *>::iterator it2 = photo->masks.begin(); it2 != photo->masks.end(); it2++ ) {
			GameFace * mask = *it2;
			std::string faceName = giExtractFaceName(photo->filename, mask->filename);
			
			out << "\"" << faceName << "\" ";
		}
		out << endl;
	}
    
	out.close();
	return GenerateErrorCode(0);
}
#endif

static BOOL SaveGameData( const std::string & inFilename) {

	std::ofstream out(inFilename.c_str(), std::ios::out);
    
	if( !out.is_open() ) {
       return NO;
	}
    Ring * currentRing = gGame.GetCurrentRing();
    ////////////////////////////////////////////////
    
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        if ( aphoto->type=="face") {
            out << "face \"" << aphoto->filename <<" \""<<aphoto->username <<"\"\n";
        }
    }
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        if ( aphoto->type=="mask") {
            out << "mask \"" << aphoto->filename <<" \""<<aphoto->username <<"\"\n";
        }
    }
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        if ( 1){//aphoto->type =="photo") {
            out<<"photo \""<< aphoto->filename<<"\""<<" ";
            for (int j = 0; j <aphoto->maskImages.size(); j ++) {
                out<<"\""<<aphoto->maskImages[j]<<"\"" <<" ";
            }
           out <<"\n";

        }
    }
    
	out.close();
	return YES; 
}
- (IBAction)requestToSaveGame:(id)sefnder {
    //gGame.images
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
    NSString *gameNameText = [gameName text];
    NSString *gameTxtFile = [gameNameText  stringByAppendingPathExtension: @"txt"];
   

    
    NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:gameNameText];

    if (![[NSFileManager defaultManager] fileExistsAtPath:gameFolderPath ]) {
		BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:gameFolderPath withIntermediateDirectories: YES attributes:nil error: nil];
		
		if ( !ret) {
			NSLog(@"Fail to create a new director for this game.");
			gameFolderPath = nil;
		}
	}
    gameFolderPath = [gameFolderPath  stringByAppendingPathComponent:gameNameText];
    
    NSString *gameTextFileNameWithFullPath = [gameFolderPath stringByAppendingPathExtension: @"txt"];
    SaveGameData(NSStringToString(gameTextFileNameWithFullPath));
    NSString *gameFileNameWithFullPath = [gameFolderPath  stringByAppendingPathExtension: kFileExtension];
     
    
    ZipArchive *zip = [[ZipArchive alloc] init];
	//[zip CreateZipFile2:gameNameText];
	[zip CreateZipFile2:gameFileNameWithFullPath];
    
    // add game.txt to the zip fle
#if 0
	[zip addFileToZip:gameTxtFile newname:gameTxtFile];
	[fileManager removeItemAtPath:gameTxtFile error:NULL];
	
	// add all face mage files to the zip
    
	NSString *tmpGameDataPath =(NSString *) getGameDataFolderPath();
	for( std::vector<GameFace *>::iterator it = app.gi.faces.begin(); it != app.gi.faces.end(); it++ ) {
		GameFace * face = *it;
		
		std::string faceFileName = face->filename;
		
		NSString *faceFileNamestd::string = [[NSString alloc] initWithUTF8String:faceFileName.c_str()];
		NSString *facestd::string = [tmpGameDataPath stringByAppendingPathComponent:faceFileNamestd::string];
		if ( faceFileNamestd::string )
			[zip addFileToZip:facestd::string newname:faceFileNamestd::string];
		
		[faceFileNamestd::string release];
		faceFileNamestd::string = nil;
	}
    
	// add all photo image files to the zip file
	for( std::vector<GamePhoto *>::iterator it = app.gi.photos.begin(); it != app.gi.photos.end(); it++ ) {
		GamePhoto * photo = *it;
		
		std::string photoFileName = photo->filename;
		NSString *photoFileNamestd::string = [[NSString alloc] initWithUTF8String:photoFileName.c_str()];
		NSString *photostd::string = [tmpGameDataPath stringByAppendingPathComponent:photoFileNamestd::string];
		if ( photoFileNamestd::string)
			[zip addFileToZip:photostd::string newname:photoFileNamestd::string];
        
		[photoFileNamestd::string release];
		photoFileNamestd::string = nil;
	}
    
	if( ![zip CloseZipFile2] )
	{
		// error handler here
		
	}
	
	[zip release];
#endif 
}
- (IBAction)requestToUploadGame:(id)sende {
    int nn = 100; 
}
// game done button has been clicked
- (IBAction)gameDone:(id)sender
{
    [self lock]; 
    // Set the pull-down menu size when "Done" button is clicked. 
    CGRect frameRect = self.view.frame; 
	frameRect.origin.y = 0; 
	frameRect.origin.x = frameRect.size.width; 
	frameRect.size.height = 120;
	frameRect.size.width = 128;
	
	
	GameDoneController *controller = nil;
	controller = [[GameDoneController alloc] initWithNibName:@"GameDoneController" bundle:nil]; 
	controller.delegate = self; 
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
	popover.delegate = self; 	
	self.popoverController = popover; 
	
	[self.popoverController setPopoverContentSize:frameRect.size animated:NO];
    
	CGRect selectedRect = CGRectMake(frameRect.origin.x,frameRect.origin.y,1,1);
	
	[self.popoverController presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
  //  [popover release]; 
    [self unlock]; 

}
- (void)registrationCommandPicker:(Registration *)controller didChooseCommand:(NSString *)commandNameStr
// Called by the gameDoneController when the user chooses a command .
{
#if 0 
    NSString *title;  	
    title =@"Send this game to friends?"; // NSLocalizedstd::string(@"Send this game to friends?", @"");  
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title  
                                                    message:nil  
                                                   delegate:self  
                                          cancelButtonTitle:@"NO"//NSLocalizedstd::string(@"NO", @"")
                                          otherButtonTitles: @"YES",nil]; ////NSLocalizedstd::string(@"YES", @""), nil ];
    //otherButtonTitles:nil];  
    [alert show];  
    [alert release]; 
#endif 
    [self createNewUserAcct]; 
}
- (IBAction)uploadGame:(id)sender
{

    if ( popoverController )
        [self dissmissPopoverController];
    
    Registration *controller = nil;
    controller = [[Registration alloc] initWithNibName:@"Registration" bundle:nil];
    //[controller presentModalViewController: nil  animated:YES];
    //[self.navigationController pushViewController:controller animated:YES];
    controller.delegate = self;
    
    // Piggie back the user password dialog
    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    
    popover.delegate = self;
    self.popoverController = popover;
    
    CGRect menuFrame = controller.view.frame;
    CGRect viewFrame = self.view.frame;
    CGRect buttonBounds = [(UIButton *)sender frame];
    [popoverController setPopoverContentSize:CGSizeMake(320,420) animated:NO];
    CGRect selectedRect; 
    selectedRect.origin = buttonBounds.origin;
    selectedRect.origin.y += buttonBounds.size.height;
    selectedRect.origin.x += 0.5*buttonBounds.size.width;
    
    [popoverController presentPopoverFromRect:selectedRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}
- (void)commandPicker:(GameDoneController *)controller didChooseCommand:(NSString *)commandNameStr
// Called by the gameDoneController when the user chooses a command .
{

#pragma unused(controller)
    assert(controller != nil);
    
    // If it wasn't cancelled...
	
    if (commandNameStr != nil &&  [commandNameStr compare: @"Rename..." options:NSCaseInsensitiveSearch] == NSOrderedSame)  {
        
		
#if 1
		[self dissmissPopoverController]; 
		
		
		gameName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 120, 30)];
		gameName.delegate = self;
		gameName.font = [UIFont systemFontOfSize:17.0];
		
		[gameName setBackgroundColor:[UIColor clearColor]];
		gameName.text = gameNavigationBar.topItem.title; 
		[gameName setTextColor:[UIColor orangeColor]];
		
		gameName.adjustsFontSizeToFitWidth = YES;
		gameName.autocorrectionType = UITextAutocorrectionTypeNo;
        
		[gameName setEnabled: YES];
        
		gameName.borderStyle = UITextBorderStyleRoundedRect; 
		
		gameName.textAlignment = UITextAlignmentCenter;
        
		gameNavigationBar.topItem.titleView = gameName; 
		//[gameNavigationBar.topItem.titleView setBackgroundColor : [UIColor orangeColor]]; 
        
#else 
        // [textField release];
		//UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		//btn.frame = CGRectMake(0, 6, 40, 30);
		//[btn setTitle:@"list" forState:UIControlStateNormal];
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 120, 30)];
		[label setFont:[UIFont boldSystemFontOfSize:16.0]];
		[label setBackgroundColor:[UIColor clearColor]];
		[label setTextColor:[UIColor whiteColor]];
		[label setText :@"I am BIG"]; 
		//[self.navigationController.navigationBar.topItem setTitleView:label];
		self.navigationBar.topItem.titleView = label; 
		UIView *item = self.navigationBar.topItem.titleView;
		//[self.navigationBar.topItem.titleView addSubview :label]; 
		//UINavigationBar *item = self.navigationController.navigationBar.topIte; 
		
		//[self.navigationController.navigationBar.topItem setTitleView:label];
		
		[label release];
#endif 
	}
   
	else if (commandNameStr != nil &&  [commandNameStr compare: @"Upload..." options:NSCaseInsensitiveSearch] == NSOrderedSame ){
        
        [self lock]; 
		if ( popoverController ) 
			[self dissmissPopoverController]; 
        
		Registration *controller = nil;
		controller = [[Registration alloc] initWithNibName:@"Registration" bundle:nil]; 
		//[controller presentModalViewController: nil  animated:YES];
		//[self.navigationController pushViewController:controller animated:YES];
		controller.delegate = self; 
		
		// Piggie back the user password dialog 
		UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
    
        popover.delegate = self; 
		self.popoverController = popover;   
		
		CGRect menuFrame = controller.view.frame; 
		CGRect viewFrame = self.view.frame; 
		
		[popoverController setPopoverContentSize:CGSizeMake(320,420) animated:NO];
		CGRect selectedRect = CGRectMake(viewFrame.size.width - menuFrame.size.width,20,1,1);
		[popoverController presentPopoverFromRect:selectedRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
		
        //[popover release];
        //[controller release]; 
        
        [self unlock]; 
	}
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController  
{  
    popoverController = nil;  
}  
- (void)commandPicker:(GameDoneController *)controller highlightGameName :(NSString *)commandNameStr	 	 
{

	if (gameName ) {
		[gameName setSelected:YES]; 
		[gameName setHighlighted:YES];
		[gameName setEnabled: YES];
        
	}

}


-(void)lock
{ 
    return; 
	pthread_mutex_trylock(&drawingLock); 
}
-(void) unlock
{
    return;
	pthread_mutex_unlock(&drawingLock);
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
   		
		if (buttonIndex == 1) {
			
            [self createNewUserAcct];  
		}
		else  {
			[self createNewUserAcct]; 
		}
		
    
	
	
}


-(void) createNewUserAcct
{
    [self lock]; 
    
    if ( popoverController ) {
        [self dissmissPopoverController]; 
         
    }
   CreateNewAccount* controller = [[CreateNewAccount alloc] initWithNibName:@"CreateNewAccount" bundle:nil]; 
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
	popover.delegate = self; 
	self.popoverController = popover;   

	CGRect menuFrame = controller.view.frame; 
	CGRect viewFrame = self.view.frame; 
	
    [popoverController  setPopoverContentSize:CGSizeMake(535,450) animated:NO];
    float offset = menuFrame.size.width; 
	CGRect selectedRect = CGRectMake(viewFrame.size.width - offset,20,535,450);
	[ popoverController presentPopoverFromRect:selectedRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
 
    [self unlock]; 
}


#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	textField.clearsOnBeginEditing = YES;
	
	return YES; 
}
-(BOOL)textFieldShouldReturn:(UITextField *)sender
{
	if ( [sender.text length]>3  ) {
		//finish editing
		[sender resignFirstResponder];
		
		gameNavigationBar.topItem.titleView = nil;
		[self dismissModalViewControllerAnimated:YES];
		[self.popoverController dismissPopoverAnimated:YES];
        
        if ( _currentLoadedGame) {
            _currentLoadedGame->filename = NSStringToString( (NSString *)sender.text);
            //gGame.images[_currentHitPhoto->name].originalWidth = 20;
            GL_LoadTextureFromText(_currentLoadedGame->filename, gGame.images[_currentLoadedGame->filename]);
        }
        
		return YES;
	} else {
		return NO;
	}
}
-(BOOL)textFieldShouldEndEditing:(UITextField *)sender
{
	if ( [sender.text length]>3  ) {

		//finish editing
		NSString *name =  (NSString *)sender.text; 
		// XXX - need to do this later 
        //[(AppView *)renderView saveGame:name]; 
		
		gameNavigationBar.topItem.title = name; 
        
		[sender resignFirstResponder];
		
		return YES;
	} else {
		return NO;
	}
}
@end
