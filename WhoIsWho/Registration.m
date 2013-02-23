// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import "Registration.h"
//#import "FriendsListController.h"
//#import "CreateNewAccount.h"
#import "TViewController.h"

@implementation Registration

//@synthesize viewController = viewController_; 
@synthesize delegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
 if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
 // Custom initialization
 }
 return self;
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    userName.delegate = self;
	password.delegate = self;
	
    
}

-(IBAction ) cancel: (id) sender
{
	//if (self.viewController )
	//	[self.viewController dissmissPopoverController]; 
}


-(IBAction ) signIn: (id) sender
{
	// First verify userID and password 
	// then upload game 
	
	if (1){//self.viewController && userName.text && password.text) {
#if 0 
		// check whether database has this user or not. 
		NSFetchRequest *request = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"user" inManagedObjectContext: self.viewController.managedObjectContext];
		[request setEntity:entity];
		
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userID LIKE[c] %@)", userName.text]; 
		[request setPredicate:predicate]; 
		NSError *error = nil; 
		
		NSArray *array = [ self.appViewController.managedObjectContext executeFetchRequest:request error:&error];
		if ( [array count] > 0 ) { 
            
            
			currentUser  = (user *)[array objectAtIndex:0]; 
            
            
			NSString *title;  	
			title =@"Send this game to friends?"; // NSLocalizedString(@"Send this game to friends?", @"");  
			
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title  
															message:nil  
														   delegate:self  
												  cancelButtonTitle:@"NO"//NSLocalizedString(@"NO", @"")
												  otherButtonTitles: @"YES",nil]; ////NSLocalizedString(@"YES", @""), nil ];
			//otherButtonTitles:nil];  
			[alert show];  
			[alert release]; 
			
			//XXX [self.appViewController uploadGameWrapper: userName.text passwd: password.text]; 
		}
		
		[request release]; 
#endif 
	}
}

-(IBAction ) createNewAcct: (id) sender
{
	//if (self.viewController )
      //  [self.viewController createNewUserAcct]; 
    TViewController *controller = (TViewController *)(self.delegate);
   // [controller createNewUserAcct]; 
    
    [controller registrationCommandPicker:self didChooseCommand:@"CreateNewAcct"];
}

- (IBAction)test:(id)sender {
    //if (self.viewController )
      //  [self.viewController createNewUserAcct];
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{
	
    if (isAnyButtonClicked) {
		
        if (buttonIndex == 1) {
			
         //   if ( self.viewController)
			//	[self.viewController sendToFriends: userName.text]; 
        }
        else  {
          //  if (self.viewController )
            //    [self.viewController dissmissPopoverController]; 
        }
		
    } else { /* No button is clicked -  dismissWithClickedButtonIndex is called */
		
        if (buttonIndex == 1) {
			
            /* dismissWithClickedButtonIndex:1 is called */
			//if ( self.viewController)
			//	[self.viewController sendToFriends: userName.text]; 
        }
		else {
		//	if (self.viewController )
		//		[self.viewController dissmissPopoverController];
		}
        
    }
	
	isAnyButtonClicked = NO;
	
}
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex 
{
	
	isAnyButtonClicked = YES; 
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    userName = nil;
    password = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    //[super dealloc];
}
#pragma mark -
#pragma mark UITextFieldDelegate Protocol

//  Sets the label of the keyboard's return key to 'Done' when the insertion
//  point moves to the table view's last field.
//
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
	//textField.clearsOnBeginEditing = YES;
	
	return YES; 
}
-(BOOL)textFieldShouldReturn:(UITextField *)sender
{
	if ( [sender.text length]>3  ) {
		//finish editing
		[sender resignFirstResponder];
		
        return YES;
	} else {
		return NO;
	}
} 

-(BOOL)textFieldShouldEndEditing:(UITextField *)sender
{
	if ( [sender.text length]>3  ) {
		
		[sender resignFirstResponder];
		
		return YES;
	} else {
		return NO;
	}
}


@end
