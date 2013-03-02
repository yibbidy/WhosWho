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
// who::Photo myPhoto;
// myPhoto.imageI = photoImageOffset;  // offset in gGame.images
// myRing.push_back(myPhoto);
//
// To make a new ring do this:
// who::Ring myRing;
// gGame.rings.rings.push_back(ring);
//
// To add a mask to a photo do this:
// myPhoto.maskImages.push_back(maskImageOffset);  // offset in gGame.images
// myPhoto.maskWeights.push_back(1.0f);  // this means the mask is opaque
//

#import "TViewController.h"
#include "utilities.h"
#import "Registration.h"
#import "FriendsListController.h"
#import "CreateNewAccount.h"
#import "glUtilities.h"
#import "ZipArchive/ZipArchive.h"
#include <map>
#include <fstream>
#include "glm/glm.hpp"
#include "WhosWho.h"
#include "Animation.h"
#include "Renderer.h"
#include "Camera.h"
#include "Parser.h"
#include "utilities.h"

static const int kButtonWidth = 24;
static const int kButtonHeight = 21;
static const int kButtonOffsetX = 3;
static const int kGameNameTextEditHeight =20;
static const int kGameNameTextEditHeightBig =40;
static const int kButtonWidthBig = 34;
static const int kButtonHeightBig = 31;



static void PopulateLocalGameNamesRing(who::Ring & inRing, void *) {
    who::GameName thisGame;
	
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
                
				thisGame.name =  fileName.UTF8String;
				thisGame.isEditable = true;
                thisGame.imageI = gGame.images.size();
                
                std::string nameString = fileName.UTF8String;
                //gGame.images.push_back(ImageInfo());
                //   GL_LoadTextureFromText(fileName,  gGame.images[fileName.UTF8String]);//.back());
                // gGame.animations.push_back("addImageFromText name=create text=Create");
                //  gGame.animations.push_back("addImageFromText name= namestd::string text=fileName);
                
                // name=\"002 face 001\" file=\"002 face 001.png\"
                
                //  who::Photo photo;
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
    //gGame.rings.rings.push_back(who::Ring(eRingTypeBrowseLocal));
    // who::Ring & ring = WHO_NewBackRing("local", eRingTypeBrowseLocal);
    
	who::GameName thisGame;
	
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
                
				thisGame.name =  fileName.UTF8String;
				thisGame.isEditable = true;
                thisGame.imageI = gGame.images.size();
                
                
                //gGame.images.push_back(ImageInfo());
                //   GL_LoadTextureFromText(fileName,  gGame.images[fileName.UTF8String]);//.back());
                // gGame.animations.push_back("addImageFromText name=create text=Create");
                gGame.animations.push_back("addImageFromText name=fileName.UTF8String text=fileName");
                
                //  gGame.animations.push_back(std::string("addPhotoToRing name=fileName.UTF8String image=fileName.UTF8String ring=") + inRing.name);
                
                
                who::Photo photo;
                photo.filename = fileName.UTF8String;
                //     ring.photos.push_back(photo);
                //  ring.browseData.localGameNames.push_back(thisGame);
			}
		}
	}	
    
}

void PopulateTitleRing(who::Ring & inRing, void *)
// This function is the callback target to populate the title ring with items
{
    
    gGame.animations.push_back("addImageFromText name=play text=Play");
    gGame.animations.push_back("addImageFromText name=edit text=Edit");
    gGame.animations.push_back("addImageFromText name=create text=Create");
    
    gGame.animations.push_back(std::string("addPhotoToRing name=play image=play ring=") + inRing.name);
    gGame.animations.push_back(std::string("addPhotoToRing name=edit image=edit ring=") + inRing.name);
    gGame.animations.push_back(std::string("addPhotoToRing name=create image=create ring=") + inRing.name);
}

void PopulatePlayRing(who::Ring & inRing, void *)
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
    else if line is who::Photo
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
    int errorCode = 0;
    
    errorCode = gGLData.Init();
   
    if( !errorCode )
        // create and show the Title ring
    {
        gGame.Execute("newBackRing name=title begin=PopulateTitleRing", 1, "PopulateTitleRing", PopulateTitleRing);
        gGame.Execute("zoomToRing ring=title");
        gGame.rings.currentRing = "title";
    }
    
    gCameraData._lookAt = glm::vec3(0, 0, 0);
    gCameraData._up = glm::vec3(0, 1, 0);
    
    glEnable(GL_DEPTH_TEST);
    
}

@interface TViewController(){
    
}
@property (assign) who::Photo *currentLoadedGame;
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
    
    //gGame.rings.rings.push_back(who::Ring(eRingTypeBrowseMore));
  //  who::Ring & ring = WHO_NewBackRing("browseMore", eRingTypeBrowseMore);
    
    // First get all the games from server  
	NSString *fileName; 
	who::GameName thisGame;
    
	for ( int i = 0; i < [listController.listGameNames count]; i++){
		
		fileName = [listController.listGameNames objectAtIndex:i];
		//NSString *ext = [fileName pathExtension]; 
		if ( [[fileName pathExtension] caseInsensitiveCompare:@"who"] == NSOrderedSame) {
			fileName = [fileName stringByDeletingPathExtension];
			thisGame.name =  fileName.UTF8String;
			thisGame.isEditable = true;
            thisGame.imageI = gGame.images.size();
            
           
            //gGame.images.push_back(ImageInfo());
        //    GL_LoadTextureFromText(fileName,  gGame.images[fileName.UTF8String]);//.back()); 
            
            who::Photo photo;
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
        
        who::Ring * hitRing = gGame.GetCurrentRing();
        
       	float z = -hitRing->stackingOrder;
        glm::vec4 cornerPt = glm::vec4(-.5, .5, z, 1);
        glm::vec4 cornerPt2 = glm::vec4(.5, .5, z, 1);
        
        cornerPt = gCameraData._vpMat * (_currentLoadedGame->transform * glm::vec3(cornerPt));
        cornerPt2 = gCameraData._vpMat * (_currentLoadedGame->transform * glm::vec3(cornerPt2));
        
        int viewportWidth = gCameraData._viewport[2];
        int viewportHeight = gCameraData._viewport[3];
        
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
    
    glm::vec3 viewPt = glm::vec3(touchPoint.x, touchPoint.y, 0);
    
    glm::vec3 rayOrigin, rayDir;
    
    GEO_MakePickRay(gCameraData._viewMat, gCameraData._projectionMat, gCameraData._viewport, viewPt, rayOrigin, rayDir);
    
    who::Ring * hitRing = 0;
    who::Ring * currentRing = gGame.GetCurrentRing();
    
    glm::vec3 intersectPt;
    
    if( gGame.zoomedToPhoto ) {
        hitRing = currentRing;
    }
    else
    {
        
        for( int i=glm::max(0, currentRing->stackingOrder-1); i<gGame.rings.stackingOrder.size() && hitRing==0; i++ ) {
            who::Ring * ring = gGame.GetRing(gGame.rings.stackingOrder[i]);
            
            glm::vec3 ptOnPlane = glm::vec3(0, 0, -i);
            glm::vec3 planeNormal = glm::vec3(0, 0, 1);
            
            if( GEO_RayPlaneIntersection(ptOnPlane, planeNormal, rayOrigin, rayDir, 0, intersectPt) ) {
                float dist = glm::distance(intersectPt, ptOnPlane);
                if( dist >= who::kR0 && dist <= who::kR1 ) {
                    hitRing = ring;
                }
            }
            
        }
    }
    
    who::Photo * hitPhoto = 0;
    
    if( gGame.GetCurrentRing() == hitRing ) {
        for( size_t i=0; i<hitRing->photos.size() & hitPhoto==0; i++ ) {
            who::Photo * photo = gGame.GetPhoto(hitRing->photos[i]);
            
            float z = -hitRing->stackingOrder;
            
            glm::vec3 photoVerts[] = {
                photo->transform * glm::vec3(-0.5, -0.5, z),
                photo->transform * glm::vec3(0.5, -0.5, z),
                photo->transform * glm::vec3(-0.5, 0.5, z),
                photo->transform * glm::vec3(0.5, 0.5, z)
            };
            
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
            glm::vec4 cornerPt = gCameraData._vpvMat * (hitPhoto->transform * glm::vec4(-0.5, -0.5, z, 1));
            cornerPt /= cornerPt.w;
            
            glm::vec4 cornerPt2 = gCameraData._vpvMat * (hitPhoto->transform * glm::vec4(0.5, -0.5, z, 1));
			cornerPt2 /= cornerPt2.w;
            
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
    
    gGLData.DeInit();

}


float gTick = 0;


- (void)update
// This function animates stuff
{
    // TODO the camera should know about the viewport and hit test calculations should use the
    // camera's data, not gGLData's matrices and viewport
    if ( gGame.rings.currentRing == "") return; 
    
    gCameraData._viewport[0] = 0;
    gCameraData._viewport[1] = 0;
    gCameraData._viewport[2] = self.view.bounds.size.width;
    gCameraData._viewport[3] = self.view.bounds.size.height;
    
    //float aspect = glm::abs(self.view.bounds.size.width / float(self.view.bounds.size.height));

    
    /*windowAspect = inWindowAspect;
     fovY = MTH_DegToRad(65.0f);
     halfNearPlaneHeight = 0.01f;
     nearPlaneDistance = halfNearPlaneHeight / tanf(fovY*0.5f);
     farPlaneDistance = 100;
     halfNearPlaneWidth = halfNearPlaneHeight * windowAspect;
     fovX = 2.0f * atanf(halfNearPlaneWidth / nearPlaneDistance);
     MAT4_MakeFrustum(-halfNearPlaneWidth, halfNearPlaneWidth, -halfNearPlaneHeight, halfNearPlaneHeight, nearPlaneDistance, farPlaneDistance, projectionMat);
     */
    
    float z = gCameraData.zoomed;
    gCameraData = Camera(gCameraData._pos, gCameraData._lookAt, gCameraData._up, 65.0f,
                         glm::vec2(0.01, 100.0), glm::ivec4(0, 0, self.view.bounds.size.width, self.view.bounds.size.height),
                         glm::ivec2(self.view.bounds.size.width, self.view.bounds.size.height));
    gCameraData.zoomed = z;
    
    gCameraData._projectionMat = gCameraData._projectionMat;
    
    //float mv[16];
    gCameraData._viewMat = glm::mat4x3(1);
    gCameraData._viewMat[3] -= gCameraData._pos;
    
    gCameraData._vpMat = gCameraData._projectionMat * gCameraData._viewMat;
    gCameraData._viewportMat = glm::viewportMatrix<float>(gCameraData._viewport);
    gCameraData._vpvMat = gCameraData._viewportMat * gCameraData._vpMat;
    
   
    _rotation += self.timeSinceLastUpdate * 0.1f;
    gTick += self.timeSinceLastUpdate;
    
    if( !AnimationSystem::IsRunning(gGame.currentAnmID) && !gGame.animations.empty() ) {
        
        std::string anm = gGame.animations.front();
        gGame.animations.pop_front();
        
        int pos = 0;
        who::WhoParser::PRS_Command(anm.c_str(), pos);
    }
    
    //if( gGame.rings.currentRing == 0 ) {  // test code
    //    MarkupMask(_rotation*3);
    //}
    
    AnimationSystem::UpdateAnimations(gTick);
    
    std::vector<int> removedRingIndices;
    
    for_j( gGame.rings.stackingOrder.size() ) {
        
        who::Ring * ring = gGame.GetRing(gGame.rings.stackingOrder[j]);
        if( ring->ringAlpha == 0 )
        // delete the ring if its alpha has gone to 0
        {
            // remember the index in stacking order of the ring we're removing
            removedRingIndices.push_back(j);
            
            for_i( gGame.rings.stackingOrder.size() ) 
            // shift subsequent rings in the stacking order
            {
                who::Ring * shiftRing = gGame.GetRing(gGame.rings.stackingOrder[i]);
                shiftRing->stackingOrder--;
            }
            
            for_i( ring->photos.size() ) {
                who::Photo * photo = gGame.GetPhoto(ring->photos[i]);
                
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
            
            if( ring->ringType == who::eRingTypeEdit ) {
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
    // if any rings have been deleted, update the stackingOrder list
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

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
// this function draws the rings and photos
{
    [self update];
    
    gGLData.RenderScene();
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
    std::map<std::string, who::Photo>::iterator it
    
	for(  std::map<std::string, who::Photo>::iterator it = gGame.photos.begin(); it != gGame.photos.end(); it++ ) {
		who::Photo thisPhoto = it->second;
        
		out << "face \"" << thiPhoto.who::Photo<< "\"\n";
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
    who::Ring * currentRing = gGame.GetCurrentRing();
    ////////////////////////////////////////////////
    
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        if ( aphoto->type=="face") {
            out << "face \"" << aphoto->filename <<" \""<<aphoto->username <<"\"\n";
        }
    }
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        if ( aphoto->type=="mask") {
            out << "mask \"" << aphoto->filename <<" \""<<aphoto->username <<"\"\n";
        }
    }
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
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
