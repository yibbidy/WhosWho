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
static NSString *sNewGameName = @"new game";

static void LoadGame(NSString *gameNameWithFullPath)
{
	NSString *gameNameStr = [[gameNameWithFullPath lastPathComponent] stringByDeletingPathExtension];
	
	NSString *gameFolderName = getGameDataFolderPath(gameNameStr);
	if (gameFolderName) {
		NSLog(gameFolderName);
        NSLog(gameNameWithFullPath);
		ZipArchive *zip = [[ZipArchive alloc] init];
		
		if([zip UnzipOpenFile:gameNameWithFullPath]) {
			//zip file is there
			if ([zip UnzipFileTo:gameFolderName overWrite:YES]) {
				//unzipped successfully
				NSLog(@"Archive unzip Success");
				
				// Get game.txt file to load this game
				NSString *gameTxtFile = [gameNameStr  stringByAppendingPathExtension: @"txt"];
				
                //				LLoadGameDataNSStringToString(gameTxtFile));
				
                //				[self drawCurrentView];
				//result= YES;
			} else {
				NSLog(@"Failure To Extract Archive, maybe password?");
			}
		} else  {
			NSLog(@"Failure To Open Archive");
		}
		
	}
	
}
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
    for( int i=0; i<currentRing->maskPhotos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->maskPhotos[i]);
        
        if ( aphoto->type=="mask") {
            out << "mask \"" << aphoto->filename <<" \""<<aphoto->username <<"\"\n";
        }
    }
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        if ( aphoto->type =="photo" && aphoto->filename !="addPhoto.png") {
            out<<"photo \""<< aphoto->filename<<"\""<<" ";
            for (int j = 0; j <aphoto->_maskImages.size(); j ++) {
                out<<"\""<<aphoto->_maskImages[j]<<"\"" <<" ";
            }
            out <<"\n";
            
        }
    }
    
	out.close();
	return YES;
}
static void DisplaySaveAndUploadButtons()
{
    who::Ring * hitRing = gGame.GetCurrentRing();
    int nn = 0; 
    if (hitRing ) {
        
        if (hitRing->selectedPhoto !=0)
            nn = 100; 
        who::Photo * currentPhoto = gGame.GetPhoto(hitRing->photos[hitRing->selectedPhoto]);
        //if (!_currentLoadedGame)
        //   _currentLoadedGame = currentPhoto;
        if ( !currentPhoto)
            nn = 200;
       	float z = -hitRing->stackingOrder;
        glm::vec4 cornerPt = glm::vec4(-.5, .5, z, 1);
        glm::vec4 cornerPt2 = glm::vec4(.5, .5, z, 1);
        
        cornerPt = gGame.camera.vpMat * (currentPhoto->transform * glm::vec3(cornerPt));
        cornerPt2 = gGame.camera.vpMat * (currentPhoto->transform * glm::vec3(cornerPt2));
        
        int viewportWidth = gGame.camera.viewport[2];
        int viewportHeight = gGame.camera.viewport[3];
        
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
        if ( textWidth < 2.0)
            nn = 700; 
        float textStartX = cornerPt[0] - 0.5*textWidth;
        if (textStartX < 5.0)
            nn = 500;
        float offsetY = 20;
        CGRect textEditRect = CGRectMake(textStartX, offsetY, textWidth+100, kGameNameTextEditHeightBig);
        gameNameOnPlayrRing.frame = textEditRect;
        gameNameOnPlayrRing.text =gameName? gameName.text:sNewGameName;
        [gameNameOnPlayrRing setEnabled: YES];
        gameNameOnPlayrRing.hidden = NO;
        gameName = gameNameOnPlayrRing;
        
        // add a save game button on the left
        CGRect buttonRect = CGRectMake(textEditRect.origin.x -kButtonWidthBig-kButtonOffsetX,offsetY, kButtonWidthBig, kButtonHeightBig);
          
        saveGameButton.frame = buttonRect;
        saveGameButton.hidden = NO;
          
        //Add a upload button on the right
        buttonRect = CGRectMake(textEditRect.origin.x+textEditRect.size.width+kButtonOffsetX,offsetY, kButtonWidthBig, kButtonHeightBig);
          
        uploadButton.frame = buttonRect;
        uploadButton.hidden = NO;
       // gGame.Execute("zoomToRing ring=playRing");
    }
    else
        nn = 500;
    NSLog(@"nn= %d\n", nn);
}
static void DisplayLoadAndDeleteButtons()
{
    // _currentLoadedGame = hitPhoto;
    //  WHO_Execute("newBackRing name=ring2 begin=PopulatePlayRing", 1, "PopulatePlayRing", PopulatePlayRing);
    //WHO_Execute("zoomToRing ring=ring2");
    who::Ring * hitRing = gGame.GetCurrentRing();
    float z = -hitRing->stackingOrder;
    who::Photo * currentPhoto = nil;
    if (hitRing->photos.size()>0)
       currentPhoto = gGame.GetPhoto(hitRing->photos[hitRing->selectedPhoto]);
    
    glm::vec4 cornerPt, cornerPt2;
    if ( currentPhoto )
       cornerPt = gGame.camera.vpMat * (currentPhoto->transform * glm::vec4(-0.5, -0.5, z, 1));
       cornerPt /= cornerPt.w;
    
    if ( currentPhoto )
       cornerPt2 = gGame.camera.vpMat * (currentPhoto->transform * glm::vec4(0.5, -0.5, z, 1));
    cornerPt2 /= cornerPt2.w;
    
    int viewportWidth = gGame.camera.viewport[2];
    int viewportHeight =gGame.camera.viewport[3];
    cornerPt.x = 0.5*viewportWidth*(cornerPt.x+1.0);
    cornerPt.y = viewportHeight- 0.5*viewportHeight*(cornerPt.y+1.0);
    cornerPt2.x = 0.5*viewportWidth*(cornerPt2.x+1.0);
    cornerPt2.y = viewportHeight- 0.5*viewportHeight*(cornerPt2.y+1.0);
    // Add a delete button right below
    CGRect buttonRect = CGRectMake(cornerPt.x, cornerPt.y, kButtonWidth, kButtonHeight);
    deleteGameButton.frame = buttonRect;
    [deleteGameButton setHidden:NO];
    
    //Add a load button
    buttonRect = CGRectMake(cornerPt.x+kButtonWidth+kButtonOffsetX, cornerPt.y, kButtonWidth, kButtonHeight);
    loadGameButton.frame = buttonRect;
    [loadGameButton setHidden:NO];
    
    //Add a text edit box for game name
    float textWidth = cornerPt2[0]-cornerPt[0];
    CGRect textEditRect = CGRectMake(cornerPt[0], cornerPt[1]-kGameNameTextEditHeight, textWidth, kGameNameTextEditHeight);
    [gameNameOnNameRing setFrame:textEditRect];
    
    if ( currentPhoto)
        gameNameOnNameRing.text =(__bridge NSString *)StringToNSString(currentPhoto->filename);
    
    [gameNameOnNameRing setEnabled: YES];
    [gameNameOnNameRing setHidden:NO];
    gameName =  gameNameOnNameRing;
    
}
static void PopulateLocalGameNamesRing(who::Ring & inRing, void *) {
    who::GameName thisGame;
	
    NSFileManager* fileManager = [NSFileManager defaultManager];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:@"WhoIsWho"];
	// NSString *gameFolderPath = getGameDataFolderPath(gameNameText);
	NSString* fullExtension = [NSString stringWithFormat:@".%@",  @"who"];
	NSLog(gameFolderPath);
    
	for (NSString* eachGameFolder in [fileManager subpathsOfDirectoryAtPath: gameFolderPath error:nil]){
		//check if it's our custom documemnt
		NSString *eachGameFolderFull = [gameFolderPath stringByAppendingPathComponent:eachGameFolder];
        
        NSLog(eachGameFolderFull);
        
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
                ////////
              //  gGame.Execute(std::string("addImageFromFile name=")+filename+std::string("file=")+filename);
                //gGame.Execute(std::string("addPhotoToRing name=")+filename+std::string("user=")+userName+std::string("type=face ring=") + ring);
                ///////////
                gGame.Execute(std::string("addImageFromTextAndImage name=")+nameString+std::string(" text=")+NSStringToString(fileName)+std::string(" imageFile=")+nameString);
                gGame.Execute(std::string("addPhotoToRing name=")+nameString+std::string(" user=")+nameString+std::string(" type=photo ring=") + inRing.name);
                
                
			}
		}
	}
    gGame.Execute("DisplayControlsForRing");
    
}

void PopulateLoadAndDeleteDrawer(who::Drawer & inOutDrawer, void * inArgs)
{
    gGame.Execute("addPhotoToRing name=cancel user=abc type=photo ring=gameNamesRing");
    gGame.Execute("addPhotoToDrawer drawer=loadAndDelete photo=play");
    gGame.Execute("showDrawer drawer=loadAndDelete location=bottom");
}

void PopulateControlsForRing()
{
    who::Ring * hitRing = gGame.GetCurrentRing();
    
    
    saveGameButton.hidden = YES;
    uploadButton.hidden = YES;
    deleteGameButton.hidden = YES;
    loadGameButton.hidden = YES;
    
    gameNameOnNameRing.hidden = YES;
    gameNameOnPlayrRing.hidden = YES;
    
    if (hitRing->name =="playRing") {
        DisplaySaveAndUploadButtons();
    }
    if (hitRing->name =="gameNamesRing") {
        gGame.Execute("newDrawer name=loadAndDelete populate=PopulateLoadAndDeleteDrawer", 1, "PopulateLoadAndDeleteDrawer", PopulateLoadAndDeleteDrawer);
        //DisplayLoadAndDeleteButtons();
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
    gGame.animations.push_back("addImageFromText name=editor text=Editor");

    gGame.animations.push_back(std::string("addPhotoToRing name=play user=play type=photo ring=") + inRing.name);
    gGame.animations.push_back(std::string("addPhotoToRing name=editor user=edit type=photo ring=") + inRing.name);
   //  gGame.Execute(std::string("addPhotoToRing name=editor user=edit type=face ring=") + inRing.name);
    
   

}

static void PopulatePlayRing(who::Ring & inRing, void *argsStr)
// this function is the callback target to populate the play ring
{
    std::string ring = inRing.name;

    NSString *gameNameStr = (__bridge NSString *)argsStr;
    if ( !gameName) return; 
    gameNameStr = [gameNameStr stringByAppendingPathExtension: kFileExtension];
    NSString *gameNameFullpath = getGameFileNameNSString(NSStringToString(gameNameStr));
    LoadGame(gameNameFullpath);
   
    NSString *gameNameFullPathNoExt = [gameNameFullpath stringByDeletingPathExtension];
    NSString *gameNameTxtFullPath = [gameNameFullPathNoExt stringByAppendingPathExtension:@"txt"];
    NSLog(gameNameFullPathNoExt);
    NSLog(gameNameTxtFullPath);
    const char *cString = NSStringToCString(gameNameTxtFullPath);
     std::ifstream in(cString);
    if( !in.is_open() ){
        return ;
    }
    
    std::string line;
    while( getline(in, line) ) {
        int pos = 0;
        std::string command = ReadWord(line, pos);
        
        if( command == "face" ) {
            std::string filename = ReadQuotedString(line, pos);
            std::string userName = ReadQuotedString(line, pos);
            
            gGame.ExecuteImmediately(std::string("addImageFromFile name=")+filename+std::string(" file=")+filename);
            gGame.ExecuteImmediately(std::string("addPhotoToRing name=")+filename+std::string(" user=")+filename+std::string(" type=face ring=") + ring);
    
            
        }else if( command == "mask" ) {
            std::string filename = ReadQuotedString(line, pos);
            std::string userName = ReadQuotedString(line, pos);
            // Add mask to photo and then add to the ring
            gGame.ExecuteImmediately(std::string("addImageFromFile name=")+filename+std::string(" file=")+filename);
            gGame.ExecuteImmediately(std::string("addPhotoToRing name=001.jpg")+std::string(" user=001.jpg")+std::string(" type=mask ring=") + ring);
            
        }else if( command == "photo" ) {
            std::string filename = ReadQuotedString(line, pos);
            
            gGame.ExecuteImmediately(std::string("addImageFromFile name=")+filename+std::string(" file=")+filename);
            gGame.ExecuteImmediately(std::string("addPhotoToRing name=")+filename+std::string(" user=")+filename+std::string(" type=photo ring=") + ring);
            
            bool isEmptyString = false;
            while( !isEmptyString ) {
               std:: string maskname = ReadQuotedString(line, pos, &isEmptyString);
                if( isEmptyString ) {
                    break;
                }
                
                gGame.ExecuteImmediately(std::string("addMaskToPhoto name=")+maskname+std::string(" image=")+maskname+std::string(" photo=")+filename);
                
            }
        } else {
         //   GenerateErrorCode(2);
        }
        
    }
    
    in.close();
    gGame.ExecuteImmediately("addImageFromFile name=addPhoto.png file=addPhoto.png");
    gGame.ExecuteImmediately(std::string("addPhotoToRing name=addPhoto.png user=addPhoto.png type=photo ring=") + ring);

     gGame.Execute("DisplayControlsForRing");
    
       

    /////////////////////////
#if 0 
    open game.txt
    read first line<#float inT#>, <#float *#>)
    if first line is "face"
        addImageFromFile();
        AddFace();
        gGame.Execute("addImageFromFile name=face file=002.jpg");
    
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
}

static void PopulateEditorRing(who::Ring & inRing, void *argsStr)
// this function is the callback target to populate the play ring
{
    std::string ring = inRing.name;
 
    gGame.Execute("addImageFromFile name=addPhoto.png file=addPhoto.png");
    gGame.Execute(std::string("addPhotoToRing name=addPhoto.png user=addPhoto.png type=photo ring=") + ring);
    gGame.Execute("setCurrentPhoto photo=addPhoto.png");
   
    gGame.Execute("DisplayControlsForRing");
}


void Reanimate(const std::string & inArgs)
// this is an animaton completed callback that just issues another animation.
// it can be used to chain animations together
{
    gGame.Execute(inArgs);
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
        gGame.animationVars["reanimate"] = (void *)Reanimate;
        
        gGame.Execute("newBackRing name=titleRing begin=PopulateTitleRing", 1, "PopulateTitleRing", PopulateTitleRing);
        gGame.Execute("zoomToRing ring=titleRing completed=reanimate args=\"setCurrentPhoto photo=editor\"");
        gGame.rings.currentRing = "titleRing";
    }
    
    gGame.camera.lookAt = glm::vec3(0, 0, 0);
    gGame.camera.up = glm::vec3(0, 1, 0);
    
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

UITextField *CreateTextEdit(CGRect rect, CGFloat fontSize )
{

    UITextField *textEdit = [[UITextField alloc] initWithFrame:rect];
   
    textEdit.font = [UIFont systemFontOfSize:fontSize];
    [textEdit setBackgroundColor:[UIColor whiteColor]];
    textEdit.adjustsFontSizeToFitWidth = YES;
    textEdit.autocorrectionType = UITextAutocorrectionTypeNo;
    textEdit.borderStyle = UITextBorderStyleRoundedRect;
    //textEdit.textAlignment = UITextAlignmentCenter;
    
    return textEdit;
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
    
    // Instantiate the load button 
    loadGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage * uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"load2" ofType:@"png"]];
    [loadGameButton setImage:uiImage forState:UIControlStateNormal];
    [loadGameButton setBackgroundColor:[UIColor clearColor]];
    [loadGameButton setBackgroundImage:nil forState:UIControlStateNormal];
    [loadGameButton addTarget:self action:@selector(requestToLoadGame:) forControlEvents:UIControlEventTouchUpInside];
    loadGameButton.frame =CGRectMake(0, 0, 5, 5);
    [loadGameButton setHidden:YES];
    [self.view addSubview:loadGameButton];
    

     // Instantiate the delete button
    deleteGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"listremove" ofType:@"png"]];
    [deleteGameButton setImage:uiImage forState:UIControlStateNormal];
    [deleteGameButton setBackgroundColor:nil];
    [deleteGameButton setBackgroundImage:nil forState:UIControlStateNormal];
    deleteGameButton.frame =CGRectMake(0, 0, 5, 5);
    [deleteGameButton setHidden:YES];
    [self.view addSubview:deleteGameButton];

    gameNameOnNameRing = CreateTextEdit(CGRectMake(0, 0, 5, 5), 12.0f);
    gameNameOnNameRing.delegate = self;
    [gameNameOnNameRing setHidden:YES];
    [self.view addSubview:gameNameOnNameRing];
    
    gameNameOnPlayrRing = CreateTextEdit(CGRectMake(10, 10, 5, 5), 26.0f);
    gameNameOnPlayrRing.delegate = self;
    gameNameOnPlayrRing.hidden = YES;
    [self.view addSubview:gameNameOnPlayrRing];
    
    saveGameButton = [UIButton buttonWithType:UIButtonTypeCustom];
    uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Save" ofType:@"png"]];
    
    [saveGameButton setImage:uiImage forState:UIControlStateNormal];
    [saveGameButton setBackgroundColor:nil];
    [saveGameButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    saveGameButton.frame =CGRectMake(0, 0, 5, 5);
    [saveGameButton addTarget:self action:@selector(requestToSaveGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveGameButton];
    
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"goup" ofType:@"png"]];
    
    [uploadButton setImage:uiImage forState:UIControlStateNormal];
    [uploadButton setBackgroundColor:nil];
    [uploadButton setBackgroundImage:nil forState:UIControlStateNormal];
    
    uploadButton.frame = CGRectMake(0, 0, 5, 5);
    [uploadButton addTarget:self action:@selector(requestToUploadGame:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:uploadButton];
    
    ///////
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

void PopulateFacesDrawer(who::Drawer & inOutDrawer, void * /*inArgs*/)
{
    who::Ring & ring = gGame.rings.rings[gGame.rings.currentRing];
    
    for( int i=0; i<ring.facePhotos.size(); i++ )
    {
        std::string photo = ring.facePhotos[i];
        gGame.Execute("addPhotoToDrawer drawer=" + inOutDrawer.name + " photo=" + photo);
    }
}

- (IBAction) requestToLoadGame:(id) sender
{
    if (!_currentLoadedGame) {
        
        who::Ring * currentRing = gGame.GetCurrentRing();
      
        if( currentRing &&  currentRing->name =="gameNamesRing")
            _currentLoadedGame = gGame.GetPhoto(currentRing->photos[0]);   
        
    }
    if (!_currentLoadedGame) return;
    
    std::string commandStr = "newBackRing name=playRing begin=PopulatePlayRing";
    commandStr +=" args=";
    commandStr +=_currentLoadedGame->filename;
    
    gOriginalGameName = (__bridge NSString *)StringToNSString( _currentLoadedGame->filename);
    
    gGame.Execute(commandStr, 1, "PopulatePlayRing", PopulatePlayRing);
    gGame.Execute("zoomToRing ring=playRing");
    gGame.Execute("newDrawer name=FacesDrawer populate=PopulateFacesDrawer", 1, "PopulateFacesDrawer", PopulateFacesDrawer);
    
    deleteGameButton.hidden = YES;
    loadGameButton.hidden = YES;
    
}

-(void) showImagePhotosPicker : (CGPoint) topLeftCorner
{
    
	// Set the pull-down menu size when "Done" button is clicked.
    CGRect frameRect = self.view.frame;
	frameRect.origin.y = topLeftCorner.y;
	frameRect.origin.x = topLeftCorner.x;
	frameRect.size.height = 120;
	frameRect.size.width = 356;
	
	
	ChooseImagesSitesViewController *controller = nil;
	controller = [[ChooseImagesSitesViewController alloc] initWithNibName:@"ChooseImagesSitesViewController" bundle:nil];
	controller.delegate = self;
	
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:controller];
	popover.delegate = self;
	self.popoverController = popover;
	
	[self.popoverController setPopoverContentSize:frameRect.size animated:NO];
    
	CGRect selectedRect = CGRectMake(frameRect.origin.x,frameRect.origin.y,1,1);
	
	[self.popoverController presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
#if debug
	NSString *modeStr = [[UIDevice currentDevice]model];
	BOOL temp = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary ];
	BOOL temp2 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum ];
    
    imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.delegate = self;
    
	imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
	//imagePickerController.allowsImageEditing = NO;
	imagePickerController.allowsEditing = YES;
	//imagePickerController.wantsFullScreenLayout = YES;
    
	//[self.view addSubview:[imagePickerController view]];
	//[self presentModalViewController:imagePickerController animated:NO];
	/*
    
	UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
	popover.delegate = self;
	self.popoverController = popover;
	
	
	[self.popoverController setPopoverContentSize:CGSizeMake(60,60) animated:NO];
	CGRect selectedRect = CGRectMake(topLeftCorner.x,topLeftCorner.y,1,1);
	[self.popoverController presentPopoverFromRect:selectedRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
    */
#endif 
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
	
  //  NSString *name = [picker.pr valueForKey:@"name"];
    
    NSString *name  = [info valueForKey:UIImagePickerControllerMediaMetadata ] ;
    NSString *name2  = [info valueForKey:UIImagePickerControllerReferenceURL ] ;
   // [self addImageToPhotos:info photoName:info valueForKey: ]
	//if ( renderView )
	//	[(AppView *)renderView addPickedImage : image];
    
	//[picker dismissModalViewControllerAnimated:NO];
	//[self.popoverController dismissPopoverAnimated:NO];
	[self addLocalImageToPhotos:image];
	
	//[self.popoverController setPopoverContentSize:CGSizeMake(60,60) animated:NO];
	//CGRect selectedRect = CGRectMake(topLeftCorner.x,topLeftCorner.y,1,1);
	//[self.popoverController presentPopoverFromRect:selectedRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
}

void PopulateEditorDrawer(who::Drawer & inOutDrawer, void * /*inArgs*/)
{
    gGame.ExecuteImmediately("addImageFromFile name=test1 file=eraser.png");
    gGame.ExecuteImmediately("addPhotoToDrawer drawer=" + inOutDrawer.name + " photo=eraser.png");
}


-(void ) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch  locationInView:self.view];
    
    glm::vec3 viewPt = glm::vec3(touchPoint.x, touchPoint.y, 0);
    
    glm::vec3 rayOrigin, rayDir;
    
    GEO_MakePickRay(gGame.camera.viewMat, gGame.camera.projMat, gGame.camera.viewport, viewPt, rayOrigin, rayDir);
    
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
    who::Photo * hitDrawerItem = 0;
    
    if( gGame.GetCurrentRing() == hitRing )
    {
        auto hitTestPhotos = [&](std::vector<std::string> & inPhotos) -> who::Photo *
        {
            who::Photo * hitItem = 0;
            
            for( size_t i=0; i<inPhotos.size() & hitItem==0; i++ )
            {
                who::Photo * photo = gGame.GetPhoto(inPhotos[i]);
                
                float z = -hitRing->stackingOrder;
                
                glm::vec3 photoVerts[] =
                {
                    photo->transform * glm::vec3(-0.5, -0.5, z),
                    photo->transform * glm::vec3(0.5, -0.5, z),
                    photo->transform * glm::vec3(-0.5, 0.5, z),
                    photo->transform * glm::vec3(0.5, 0.5, z)
                };
                
                if( GEO_RayTriangleIntersection(rayOrigin, rayDir, photoVerts+0, 0, intersectPt) ||
                   GEO_RayTriangleIntersection(rayOrigin, rayDir, photoVerts+1, 0, intersectPt) )
                    hitItem = photo;
            }
            
            return hitItem;
        };
        
        hitPhoto = hitTestPhotos(hitRing->photos);
        
        if( gGame.currentDrawer != "" )
            hitDrawerItem = hitTestPhotos(gGame.drawers[gGame.currentDrawer].photos);
    }
    
    // for hit cancel
    who::Photo *photo = &gGame.photos[cancelString];
    if ( currentRing->name =="playRing" && gGame.totalPhotosToDownload>0) {
        float z = -hitRing->stackingOrder;
        glm::vec3 viewPt2 = glm::vec3(touchPoint.x, touchPoint.y, 0);
        
        glm::vec3 rayOrigin2, rayDir2;
        GEO_MakePickRay(gGame.camera.viewMat, gGame.camera.projMat, gGame.camera.viewport, viewPt2, rayOrigin2, rayDir2);

        
        glm::vec3 photoVerts[] = {
            photo->transform * glm::vec3(-0.5, -0.5, z),
            photo->transform * glm::vec3(0.5, -0.5, z),
            photo->transform * glm::vec3(-0.5, 0.5, z),
            photo->transform * glm::vec3(0.5, 0.5, z)
        };

        if( GEO_RayTriangleIntersection(rayOrigin2, rayDir2, photoVerts+0, 0, intersectPt) ||
           GEO_RayTriangleIntersection(rayOrigin2, rayDir2, photoVerts+1, 0, intersectPt) ) {
            hitPhoto = photo;

        }
    }
   char command[256];
    
    if( hitPhoto )
    {
        if( hitPhoto->type == "cancel" )
        {
            if (picasaController)
                [picasaController cancelClicked:nil];
        }
        //_currentHitPhoto = hitPhoto;
        else if( hitPhoto && hitPhoto->filename=="addPhoto.png") {
            [self showImagePhotosPicker:touchPoint ];
        }
    	else if( hitRing->name =="gameNamesRing") {
            _currentLoadedGame = hitPhoto;
            
            if( gGame.zoomedToPhoto ) {
                gGame.Execute("zoomToRing");
                
            } else {
                sprintf(command, "setCurrentPhoto photo=%s", hitPhoto->filename.c_str());
                //sprintf(command, "zoomToPhoto photo=%s", hitPhoto->filename.c_str());
                gGame.Execute(command);
                _requestToDisplayLoadAndDeleteButtons = YES;
              //  gGame.Execute("displayLoadAndDeleteButtons loadButton= deleteButton= editTextField=");
                 gGame.Execute("DisplayControlsForRing");
                
            }

    	}
        else if( hitPhoto->filename == "editor" ) {

            if( gGame.zoomedToPhoto )
            {
                //gGame.Execute("deleteRingsAfter ring=" + hitRing->name);
                
                //gGame.Execute("setCurrentPhoto photo=editor");
                //gGame.Execute("newBackRing name=playRing begin=PopulateEditorRing", 1, "PopulateEditorRing", PopulateEditorRing);
                //gGame.Execute("zoomToRing ring=playRing");
                
                //gGame.Execute("showTextEdit");
                
                //auto PopulateEditorDrawer = [&](who::Drawer & inOutDrawer, void * /*inArgs*/)
                //{
                  //  gGame.ExecuteImmediately("addImageFromFile file=deleteFace.jpg name=test1");
                    //gGame.ExecuteImmediately("addPhotoToDrawer drawer=" + inOutDrawer.name + " photo=test1");
                //};

                gGame.Execute("newDrawer name=EditorDrawer populate=PopulateEditorDrawer", 1, "PopulateEditorDrawer", PopulateEditorDrawer);
                gGame.Execute("showDrawer drawer=EditorDrawer location=top");
                

                //  [self displaySaveAndUploadButtons];
                //  gGame.Execute("zoomToRing ring=playRing");
                
            }
            else
            {
                sprintf(command, "zoomToPhoto photo=%s", hitPhoto->filename.c_str());
                gGame.Execute(command);
                
            }
            
            
        }
    	else if( hitPhoto->filename == "play" ) {
            if( gGame.zoomedToPhoto )
            {
                gGame.Execute("deleteRingsAfter ring=" + hitRing->name);
                
                gGame.Execute("setCurrentPhoto photo=play");

                gGame.Execute("newBackRing name=gameNamesRing begin=PopulateLocalGameNamesRing", 1, "PopulateLocalGameNamesRing", PopulateLocalGameNamesRing);
                gGame.Execute("zoomToRing ring=gameNamesRing");
            }
            else
            {
                gGame.Execute("zoomToPhoto photo=play");
            }

        }
        else if( hitPhoto->filename == "addPhoto" )
        {
            gGame.Execute("showDrawer drawer=faces");
        

        }
        else if( hitRing != 0 )
        {
            if( gGame.zoomedToPhoto )
            {
                gGame.Execute("zoomToRing");
                gGame.Execute("hideDrawer");
                
            }
            else
            {
                sprintf(command, "zoomToPhoto photo=%s", hitPhoto->filename.c_str());
                gGame.Execute(command);
                gGame.Execute("showDrawer drawer=FacesDrawer");
                
            }
        }
    }
    else if( hitRing )
    {
        gGame.Execute("hideDrawer");
        
        sprintf(command, "zoomToRing ring=%s", hitRing->name.c_str());
        gGame.Execute(command);
        gGame.Execute("DisplayControlsForRing");
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    WHO_InitApp();
    
    
    UIImage *image  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cancel" ofType:@"png"]];
    ImageInfo cancelImageInfo;
    
    std::string cancelString = "cancel";
    GL_LoadTextureFromUIImage(image,cancelImageInfo);
    
    if ( cancelImageInfo.image) {
   
        gGame.images[cancelString] = cancelImageInfo;
    
        who::Photo photo;
        photo.type ="cancel";
        photo.filename = "cancel";
        photo.username = "cancel";
        photo.transform = glm::mat4x3(glm::mat4(1));
        
        gGame.photos[cancelString]=photo;
    }
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

static bool PhotoNameExists(NSString *thisPhotoname)
{
    bool findName = false; 
    who::Ring * currentRing = gGame.GetCurrentRing();
    for( size_t i=0; i<currentRing->photos.size() && !findName; i++ ) {
        who::Photo * photo = gGame.GetPhoto(currentRing->photos[i]);
        NSString *photoName = (__bridge NSString *)StringToNSString(photo->filename);
        findName = [thisPhotoname isEqualToString:photoName];
    }
    
    return findName;
}

- (void)addImageToPhotos:(NSData *)data photoName:(NSString *)name
{
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    std::string nameString = NSStringToString(name);
    
    if (PhotoNameExists(name)) {
        NSString *newName = [name stringByDeletingPathExtension];
        NSString *extString = [name pathExtension];
        
        nameString  = NSStringToString(newName)+std::string("-2.")+NSStringToString(extString);
    }
    NSString *gameFolderPath = nil;
    if ( gameName) {
        gameFolderPath = getGameDataFolderPath([gameName text]);
       if ( !gOriginalGameName)
           gOriginalGameName = [gameName text];
    }
    else {
        gameFolderPath = getGameDataFolderPath(sNewGameName);
        gOriginalGameName = sNewGameName;
    }
    NSString *nameNSString = (__bridge NSString *)StringToNSString(nameString);
    
    NSString *imageFilePath = [gameFolderPath stringByAppendingPathComponent:nameNSString];
    NSError *error = nil;
    
    BOOL didSave = [data writeToFile:imageFilePath
                             options:NSAtomicWrite
                               error:&error];
    
    
    if (didSave) {
    
        who::Ring * currentRing = gGame.GetCurrentRing();
        std::string ring = currentRing->name;
        
        GL_LoadTextureFromUIImage(image, gGame.images[nameString]);
        gGame.Execute(std::string("addPhotoToRing name=")+nameString+std::string(" user=")+nameString+std::string(" type=photo ring=") + ring);
    }
}

-(void)setTotalPhotosToDownload:(int)numOfPhotos
{
    gGame.totalPhotosToDownload = numOfPhotos;
}
-(void)setPhotosDownloaded:(int)numOfPhotos;
{
    who::Ring * currentRing = gGame.GetCurrentRing();
    gGame.currentNumOfPhotos = currentRing->photos.size();
}
- (void)addLocalImageToPhotos:(UIImage *)image 
{
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"dd-MM-YY-HH-mm-ss"];
    NSString *name = [dateFormatter stringFromDate:currDate];
   // NSLog(@"%@",dateString);
    
    std::string nameString;// = NSStringToString(name);
     NSString *extString = @"png";
    if (PhotoNameExists(name)) {
        NSString *newName = [name stringByDeletingPathExtension];
        nameString  = NSStringToString(newName)+std::string("-2.")+NSStringToString(extString);
    }
    else
        nameString = NSStringToString(name)+std::string(".")+NSStringToString(extString);
    
    NSString *gameFolderPath = nil;
    if ( gameName)  {
        
        gameFolderPath = getGameDataFolderPath([gameName text]);
        if (!gOriginalGameName)
            gOriginalGameName = [gameName text];
    }
    else {
        gameFolderPath = getGameDataFolderPath(sNewGameName);
        gOriginalGameName = sNewGameName;
    }
    NSString *nameNSString = (__bridge NSString *)StringToNSString(nameString);
    
    NSString *imageFilePath = [gameFolderPath stringByAppendingPathComponent:nameNSString];
    NSLog(imageFilePath);
    NSError *error = nil;
    
    CGImageRef cgImage =  [image CGImage];
    CGImageAlphaInfo info =  CGImageGetAlphaInfo(cgImage);
    BOOL hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
    
    if (hasAlpha)
        [UIImagePNGRepresentation(image) writeToFile:imageFilePath atomically:YES];
    else
         [UIImageJPEGRepresentation(image, 1.0) writeToFile:imageFilePath atomically:YES];
    who::Ring * currentRing = gGame.GetCurrentRing();
    std::string ring = currentRing->name;
    
    GL_LoadTextureFromUIImage(image, gGame.images[nameString]);
    gGame.Execute(std::string("addPhotoToRing name=")+nameString+std::string(" user=")+nameString+std::string(" type=photo ring=") + ring);
    
}

- (void)update
// This function animates stuff
{
    // TODO the camera should know about the viewport and hit test calculations should use the
    // camera's data, not gGLData's matrices and viewport
    if ( gGame.rings.currentRing == "") return;
    
    gGame.camera.viewport[0] = 0;
    gGame.camera.viewport[1] = 0;
    gGame.camera.viewport[2] = self.view.bounds.size.width;
    gGame.camera.viewport[3] = self.view.bounds.size.height;
    
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
    
    float z = gGame.camera.zoomed;
    gGame.camera = Camera(gGame.camera.pos, gGame.camera.lookAt, gGame.camera.up, 65.0f,
                         glm::vec2(0.01, 100.0), glm::ivec4(0, 0, self.view.bounds.size.width, self.view.bounds.size.height),
                         glm::ivec2(self.view.bounds.size.width, self.view.bounds.size.height));
    gGame.camera.zoomed = z;
    
    gGame.camera.projMat = gGame.camera.projMat;
    
    //float mv[16];
    gGame.camera.viewMat = glm::mat4x3(1);
    gGame.camera.viewMat[3] -= gGame.camera.pos;
    
    gGame.camera.vpMat = gGame.camera.projMat * gGame.camera.viewMat;
    gGame.camera.viewportMat = glm::viewportMatrix<float>(gGame.camera.viewport);
    gGame.camera.vpvMat = gGame.camera.viewportMat * gGame.camera.vpMat;
    
   
    rotation += self.timeSinceLastUpdate * 0.1f;
    gTick += self.timeSinceLastUpdate;
    
    if( !AnimationSystem::IsRunning(gGame.currentAnmID) && !gGame.animations.empty() )
    // The primary animation blocks subsequent animatinos from starting until it completes.
    {
        
        std::string anm = gGame.animations.front();
        gGame.animations.pop_front();
        
        int pos = 0;
        who::WhoParser::PRS_Command(anm.c_str(), pos, gGame.errorStream);
    }
    
    //if( gGame.rings.currentRing == 0 ) {  // test code
    //    MarkupMask(rotation*3);
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
                
                for_j( photo->_maskImages.size() ) {
                    resourceName = photo->_maskImages[j];
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
-(void) saveThumbnailImage:(NSString *)fileName
{
    UIImage *orgImage =(__bridge UIImage *)GL_GetUIImageFromFile(fileName.UTF8String);
    
    NSString *fontName = @"Helvetica-Bold";
	int fontSize = 62;//22;

	UIFont *font = [UIFont fontWithName:fontName size:fontSize];
	// Precalculate size of text and size of font so that text fits inside placard
	//CGSize thumbnailSize = [[gameName text] sizeWithFont:font] ; //forWidth:320 lineBreakMode:UILineBreakModeWordWrap];
    CGSize thumbnailSize = CGSizeMake(118, 66);
    UIGraphicsBeginImageContext(thumbnailSize);
    [orgImage drawInRect:CGRectMake(0,0,thumbnailSize.width,thumbnailSize.height)];
    UIImage *thumbnailImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSData *imageData= UIImagePNGRepresentation(thumbnailImage);
    NSString *gameFolderPath = getGameDataFolderPath([gameName text]);
    NSString *thumbnailFile = [gameFolderPath stringByAppendingPathComponent:kThumbnailImageFileName];
    
    //NSLog(thumbnailFile);
    if ( imageData)
        [imageData writeToFile:thumbnailFile atomically:YES];
    
}
- (IBAction)requestToSaveGame:(id)sefnder {
    //gGame.images
    
    NSString *gameNameText = [gameName text];
    NSString *gameTxtFile = [gameNameText  stringByAppendingPathExtension: @"txt"];
   

    NSString *gameFolderPath = getGameDataFolderPath(gameNameText);
    gameFolderPath = [gameFolderPath  stringByAppendingPathComponent:gameNameText];
    
    NSString *gameTextFileNameWithFullPath = [gameFolderPath stringByAppendingPathExtension: @"txt"];
    SaveGameData(NSStringToString(gameTextFileNameWithFullPath));
    NSString *gameFileNameWithFullPath = [gameFolderPath  stringByAppendingPathExtension: kFileExtension];
     
    
    ZipArchive *zip = [[ZipArchive alloc] init];
	//[zip CreateZipFile2:gameNameText];
	[zip CreateZipFile2:gameFileNameWithFullPath];
    
    // add game.txt to the zip fle

	[zip addFileToZip:gameTextFileNameWithFullPath newname:gameTxtFile];
	[[NSFileManager defaultManager] removeItemAtPath:gameTextFileNameWithFullPath error:NULL];

	// add all image files to the zip
    NSString *savedGameName = gOriginalGameName?gOriginalGameName:gameNameText;
	NSString *curGameDataPath = getGameDataFolderPath(savedGameName);
   
    
    /////////////////////
    who::Ring * currentRing = gGame.GetCurrentRing();
    ////////////////////////////////////////////////
    
    for( int i=0; i<currentRing->maskPhotos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        std::string faceFileName = aphoto->filename;
        
        NSString *faceFileNameString = (__bridge NSString *)StringToNSString(faceFileName);
        NSString *faceString = [curGameDataPath stringByAppendingPathComponent:faceFileNameString];
        if ( faceFileNameString )
            [zip addFileToZip:faceString newname:faceFileNameString];
        
    }
    NSString *firstPhotoFile = nil; 
    for( int i=0; i<currentRing->photos.size(); i++ ) {
        
        who::Photo * aphoto = gGame.GetPhoto(currentRing->photos[i]);
        
        std::string fileName = aphoto->filename;
        if (fileName != "addPhoto.png") {
            NSString *fileNameString = (__bridge NSString *)StringToNSString(fileName);
            NSString *fileString = [curGameDataPath stringByAppendingPathComponent:fileNameString];
            if ( fileNameString )
             [zip addFileToZip:fileString newname:fileNameString];
            
            if (!firstPhotoFile)
                firstPhotoFile = fileNameString;
        }
        
    }
    
    
    
	if( ![zip CloseZipFile2] )
	{
		// error handler here
		
	}
    
    // Then save a thumbnail image for this game
    [self saveThumbnailImage:firstPhotoFile];
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
- (void)launchFacebookDialog
{
#if USE_FACEBOOK
    
    if ( facebookController ) {
        // Set the pull-down menu size when "Done" button is clicked.
        CGRect frameRect = self.view.frame;
        frameRect.origin.y = 0;
        frameRect.origin.x = 0;
        frameRect.size.height = 620;
        frameRect.size.width = 457;
        
        [self dissmissPopoverController];
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:facebookController];
        popover.delegate = self;
        
        self.popoverController = popover;
        facebookController.hostViewController = self;
        facebookController.hostPopoverController = popover;
        
        [self.popoverController setPopoverContentSize:frameRect.size animated:NO];
        
        //   facebookController.popoverController= popover;
        CGRect selectedRect = CGRectMake(0,0,1,1);
        
        [self.popoverController presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
#endif
}
- (void)commandPicker:(ChooseImagesSitesViewController *)controller didChooseCommand:(NSString *)commandNameStr
// Called by the gameDoneController when the user chooses a command .
{
#if USE_FACEBOOK
    int nn = 0;
    if (commandNameStr != nil &&  [commandNameStr compare: getPhotosFromPicasa options:NSCaseInsensitiveSearch] == NSOrderedSame)  {
        // Set the pull-down menu size when "Done" button is clicked.
        CGRect frameRect = self.view.frame;
        frameRect.origin.y = 0;
        frameRect.origin.x = 0;
        frameRect.size.height = 536;
        frameRect.size.width = 457;
        
        
        picasaController = [[PicasaViewController alloc] initWithNibName:@"PicasaViewController" bundle:nil];
        [self dissmissPopoverController];
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:picasaController];
        popover.delegate = self;
        
        self.popoverController = popover;
        
        [self.popoverController setPopoverContentSize:frameRect.size animated:NO];
        
        picasaController.popoverController= popover;
        picasaController.hostViewController = self;
        CGRect selectedRect = CGRectMake(0,0,1,1);
        
        [self.popoverController presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
     }
    else if (commandNameStr != nil &&  [commandNameStr compare: getPhotosFromFacebook options:NSCaseInsensitiveSearch] == NSOrderedSame)  {
#if 1
        facebookController = [[Facebook2ViewController alloc] initWithNibName:@"Facebook2ViewController" bundle:nil];
        [facebookController setHostViewController:self];
      //  [self launchFacebookDialog];
        [facebookController facebookLoginAuthenticate];
#else
        facebookController = [[FacebookViewController alloc] initWithNibName:@"FacebookViewController" bundle:nil];
        [facebookController setHostViewController:self];
        //  [self launchFacebookDialog];
        [facebookController facebookLoginAuthenticate];
#endif 
    }
    else if (commandNameStr != nil &&  [commandNameStr compare: getPhotosLocally options:NSCaseInsensitiveSearch] == NSOrderedSame)  {

        NSString *modeStr = [[UIDevice currentDevice]model];
        BOOL temp = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary ];
        BOOL temp2 = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum ];
        
        imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        
        imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        //imagePickerController.allowsImageEditing = NO;
        imagePickerController.allowsEditing = YES;
        //imagePickerController.wantsFullScreenLayout = YES;
        
        //[self.view addSubview:[imagePickerController view]];
        //[self presentModalViewController:imagePickerController animated:NO];
         [self dissmissPopoverController];
         UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:imagePickerController];
         popover.delegate = self;
         self.popoverController = popover;
         
         
         [self.popoverController setPopoverContentSize:CGSizeMake(60,60) animated:NO];
         CGRect selectedRect = CGRectMake(0,0,1,1);
         [self.popoverController presentPopoverFromRect:selectedRect inView:[self view] permittedArrowDirections:UIPopoverArrowDirectionAny animated:NO];
         
    }
    else if (commandNameStr != nil &&  [commandNameStr compare: @"Picasa..." options:NSCaseInsensitiveSearch] == NSOrderedDescending)  {
         nn = 200; 
    }
    
#endif

}
/*
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
 */
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
        [sender setTextColor:[UIColor blackColor]];
		//finish editing
		[sender resignFirstResponder];
		
		gameNavigationBar.topItem.titleView = nil;
		[self dismissModalViewControllerAnimated:YES];
		[self.popoverController dismissPopoverAnimated:YES];
         who::Ring * hitRing = gGame.GetCurrentRing();
        if ( _currentLoadedGame && _currentLoadedGame->filename !="play" && _currentLoadedGame->filename !="editor") {
            std::string oldName = _currentLoadedGame->filename;
            _currentLoadedGame->filename = NSStringToString( (NSString *)sender.text);
            //gGame.images[_currentHitPhoto->name].originalWidth = 20;
            GL_LoadTextureFromTextAndImage(_currentLoadedGame->filename, oldName, gGame.images[_currentLoadedGame->filename]);
    
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
