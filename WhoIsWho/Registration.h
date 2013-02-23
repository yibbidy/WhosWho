// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <UIKit/UIKit.h>
//#import "TViewController.h" 

@protocol RegistrationDelegate;

@interface Registration : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {
	//TViewController *viewController_; 
	BOOL isAnyButtonClicked; 
	//user *currentUser; 
	id<RegistrationDelegate>  delegate;

    IBOutlet UITextField *userName;
    IBOutlet UITextField *password;
	//IBOutlet UITextField *password; 
	//IBOutlet UITextField *verifyPassword;
}
@property (nonatomic, retain) id<RegistrationDelegate> delegate;
//@property (nonatomic, retain) TViewController *viewController; 
- (IBAction)cancel:(id)sender;
- (IBAction)signIn:(id)sender;

- (IBAction)test:(id)sender;
- (IBAction)createNewAcct:(id)sender;

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex; 
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;

@end


@protocol RegistrationDelegate <NSObject>
@required

- (void)registrationCommandPicker:(Registration *)controller didChooseCommand:(NSString *)commandNameStr;  

// nil for cancellation
@end