// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)
//  Justin Hutchison (yibbidy@gmail.com)

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "GameDoneController.h"
#import "ListController.h" 
#import "PutController.h"
#import "Registration.h"
#import "CreateNewAccount.h"
#import "ChooseImagesSitesViewController.h"
#import "PicasaViewController.h"
//#import "FacebookViewController.h"
//#import "Facebook2ViewController.h"
#define kFileExtension @"who"
UITextField *gameName;
UITextField *gameNameOnPlayrRing;
UITextField *gameNameOnNameRing;
UIButton *deleteGameButton;
UIButton *loadGameButton;
UIButton *saveGameButton;
UIButton *uploadButton;
NSString *gOriginalGameName;



@interface TViewController : GLKViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, GameDoneControllerDelegate, RegistrationDelegate, ChooseSitesControllerDelegate> {
   
    UIImagePickerController *imagePickerController;
    PicasaViewController *picasaController;
    //Facebook2ViewController *facebookController;
    float _rotation;
    
    UIPopoverController *popoverController;
    IBOutlet UIBarButtonItem *gameDoneButton;
    IBOutlet UINavigationBar *gameNavigationBar;
    
    // Internet connetiong stuff 
	ListController *listController; 
	PutController *putController;
    
    pthread_mutex_t		drawingLock;
    
}
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;
@property (assign) BOOL requestToDisplayLoadAndDeleteButtons;
@property (assign) BOOL requestToDisplaySaveAndUploadButtons;


- (void)setupGL;
- (void)tearDownGL;
- (void)lock; 
- (void)unlock; 

- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
- (void)loadMenuRing; 

-(void) dissmissPopoverController; 
- (IBAction)saveGame:(id)sender;

- (IBAction)gameDone:(id)sender;
- (IBAction)uploadGame:(id)sender;

- (void)commandPicker:(GameDoneController *)controller didChooseCommand:(NSString *)commandNameStr; 
- (void)commandPicker:(GameDoneController *)controller highlightGameName :(NSString *)commandNameStr;


- (void)registrationcommandPicker:(Registration *)controller didChooseCommand:(NSString *)commandNameStr; 


-(void) createNewUserAcct; 
-(void)uploadGame: (NSString *)usernameString passwd: passwordString;
-(void)addImageToPhotos:(NSData *)data photoName:(NSString *)name;
-(void)addLocalImageToPhotos:(UIImage *)image;
-(void)setTotalPhotosToDownload:(int)numOfPhotos;
-(void)setPhotosDownloaded:(int)numOfPhotos;
- (void)launchFacebookDialog; 
@end
