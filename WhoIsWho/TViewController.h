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

#define kFileExtension @"who"

@interface TViewController : GLKViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate, UITextFieldDelegate, GameDoneControllerDelegate, RegistrationDelegate> {
   
    UIImagePickerController *imagePickerController;
    float _rotation;
    UITextField *gameName;
    UIButton *deleteGameButton;
    UIButton *loadGameButton;
    UIButton *saveGameButton;
    UIButton *uploadButton; 
    
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
-( void) uploadGame: (NSString *)usernameString passwd: passwordString; 
@end
