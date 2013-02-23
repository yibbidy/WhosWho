// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <UIKit/UIKit.h>

@interface CreateNewAccount : UIViewController <UIAlertViewDelegate, UITextFieldDelegate> {

    IBOutlet UITextField *emailEdit;
    IBOutlet UITextField *passwdEdit;
    IBOutlet UITextField *re_passwdEdit;
}
- (IBAction)saveUser:(id)sender;
@end
