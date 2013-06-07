// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import "CreateNewAccount.h"
//#import <RestKit/RestKit.h>
//#import <RestKit/CoreData.h>
#import "User.h"

@interface CreateNewAccount ()

@end

@implementation CreateNewAccount

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
       
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    emailEdit.delegate = self;
    passwdEdit.delegate = self;
    re_passwdEdit.delegate = self;
}

- (void)viewDidUnload
{
    emailEdit = nil;
    passwdEdit = nil;
    re_passwdEdit = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)saveUser:(id)sender {
    
#if 0 
    
   // User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    
    RKObjectManager *manager= [RKObjectManager sharedManager];
    RKManagedObjectStore *objectStore =  [manager managedObjectStore];
    NSManagedObjectContext *context= objectStore.mainQueueManagedObjectContext;
    
    /////
    // check whether database has this user or not.
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:@"User" inManagedObjectContext: context];
	[request setEntity:entity];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(email LIKE[c] %@)", @"shirley@gmail.com"];
	[request setPredicate:predicate];
	NSError *error = nil;
	
	NSArray *array = [ context executeFetchRequest:request error:&error];
	if ( [array count] > 0 ) {
        NSString *title = NSLocalizedString(@"This user name has been used, please choose a different one", @"");
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
														message:nil
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"OK", @"")
											  otherButtonTitles: nil, nil ];
		//otherButtonTitles:nil];
		[alert show];
    }
        
    /////
    User *newUser = [NSEntityDescription insertNewObjectForEntityForName:@"User" inManagedObjectContext:context];
    
    
    newUser.email = @"shirley@gmail.com";//emailEdit.text;
    newUser.passwd = @"123";
    
    // Now save it
    error = nil;
	if (![context save:&error]) {
		// Handle the error.
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		exit(-1);  // Fail
	}
#endif 
    
}
@end
