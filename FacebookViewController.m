//
//  FacebookViewController.m
//  WhoIsWho
//
//  Created by Hongbing Carter on 8/9/13.
//
//

#import "FacebookViewController.h"
#import "AppDelegate.h"
#import "TViewController.h"

static NSString *fbEmail= @"email";
static NSString *fbUserPhotos = @"user_photos";

@interface FacebookViewController ()
@property (strong) NSMutableArray *selectedAlbumPhotos;
@end

@implementation FacebookViewController

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            
            TViewController *host = (TViewController *)self.hostViewController;
            [host launchFacebookDialog ];
        
            break;
        }
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            // Once the user has logged in, we want them to
            // be looking at the root view.
            //   [self.navController popToRootViewControllerAnimated:NO];
            
            [FBSession.activeSession closeAndClearTokenInformation];
            
            //    [self showLoginView];
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}
-(void)openSession
{
    NSArray *permission = [NSArray arrayWithObjects:fbEmail,fbUserPhotos, nil];
    [FBSession openActiveSessionWithReadPermissions:permission allowLoginUI:YES completionHandler:
     ^(FBSession *session, FBSessionState state, NSError *error)
     {
         [ self sessionStateChanged:session state:state error:error];
     }];
    
}

- (void)populateUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 self.userNameLabel.text = user.name;
                 self.userProfileImage.profileID = user.id;
             }
         }];
    }
}
#if 0 
// Helper method to wrap logic for handling app links.
- (void)handleAppLink:(FBAccessTokenData *)appLinkToken {
    // Initialize a new blank session instance...
    FBSession *appLinkSession = [[FBSession alloc] initWithAppID:nil
                                                     permissions:nil
                                                 defaultAudience:FBSessionDefaultAudienceNone
                                                 urlSchemeSuffix:nil
                                              tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance] ];
    [FBSession setActiveSession:appLinkSession];
    // ... and open it from the App Link's Token.
    [appLinkSession openFromAccessTokenData:appLinkToken
                          completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                              // Forward any errors to the FBLoginView delegate.
                              if (error) {
                                 // [self.loginViewController loginView:nil handleError:error];
                              }
                          }];
}
#endif 
-(void)facebookLoginAuthenticate
{
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        [self openSession];
    }
    else  {
        
        NSArray *permission = [NSArray arrayWithObjects:fbEmail,fbUserPhotos, nil];
        
        FBSession *session = [[FBSession alloc] initWithPermissions:permission];
        [FBSession setActiveSession: session];
        
        [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            
            switch (status) {
                case FBSessionStateOpen: {
                    if (self.hostViewController) {
                      TViewController *host = (TViewController *)self.hostViewController;
                     [host launchFacebookDialog ];
                    }
                    break;
                }
                case FBSessionStateClosedLoginFailed: {
                    // prefer to keep decls near to their use
                    // unpack the error code and reason in order to compute cancel bool
                    NSString *errorCode = [[error userInfo] objectForKey:FBErrorLoginFailedOriginalErrorCode];
                    NSString *errorReason = [[error userInfo] objectForKey:FBErrorLoginFailedReason];
                    BOOL userDidCancel = !errorCode && (!errorReason || [errorReason isEqualToString:FBErrorLoginFailedReasonInlineCancelledValue]);
                    
                    
                    if(error.code == 2 && ![errorReason isEqualToString:@"com.facebook.sdk:UserLoginCancelled"]) {
                        
                         UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Facebook Login Failure"
                         message:@"Facebook login is canceled"
                         delegate:nil
                         cancelButtonTitle:@"OK"
                         otherButtonTitles:nil];
                         [errorMessage performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
                         errorMessage = nil;
                         
                    }
                }
                    break;
                    // presently extension, log-out and invalidation are being implemented in the Facebook class
                default:
                    break; // so we do nothing in response to those state transitions
            }
        }];
        permission = nil;
        
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    _selectedAlbumPhotos = [[NSMutableArray alloc] init];
    
    
    return self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    NSString *newFileName = @"check.jpg";
	NSString *extension = [newFileName pathExtension];
	NSString *newFileNameWithNoExtension = [newFileName stringByDeletingPathExtension];
	checkImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:newFileNameWithNoExtension ofType:extension]];
#if 0 
    albumsList.frame = CGRectMake(25, 148, 320, 500);
    albumsList.rowHeight = 34.0f;
    albumsList.separatorStyle=UITableViewCellSeparatorStyleNone;
    [albumsList setBackgroundColor:[UIColor redColor]];
    albumsList.showsVerticalScrollIndicator=NO;
#endif
    
    albumsList.delegate = self;
    albumsList.dataSource = self;
    
    photosList.delegate = self;
    photosList.dataSource = self;
    
    albumsList.scrollEnabled = YES;
    photosList.scrollEnabled = YES;
    
    [self.view addSubview:albumsList];
    [self.view addSubview:photosList];
    
     [self setEditing:YES animated:YES];
    
   
    // Do any additional setup after loading the view from its nib.
  
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
  
}
- (void)viewDidUnload
{
   
    albumsList = nil;
    photosList = nil;
    albumPreview = nil;
    photoPreview = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#if 0 
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}
#endif 
-(void)retrieveAlbums:(id)requestResult
{

    NSLog(@"Results: %@", requestResult);
    _albumsRequestResult = requestResult;
    [albumsList reloadData]; 
#if 0 
    NSArray* collection = (NSArray*)[requestResult data];
    NSLog(@"You have %d albums", [collection count]);
    
    NSDictionary* album = [collection objectAtIndex:0];
    NSLog(@"Album ID: %@", [album objectForKey:@"id"]);
    
    // /albums[0]/photos
    NSString* photos = [NSString stringWithFormat:@"%@/photos", [album objectForKey:@"id"]];
    [FBRequestConnection startWithGraphPath:photos
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              NSArray* photos = (NSArray*)[result data];
                              NSLog(@"You have %d photo(s) in the album %@",
                                    [photos count],
                                    [album objectForKey:@"name"]);
                          }];
#endif 
}
-(void) retrievePhotosByAlbum: (NSDictionary*)album
{
    
    // /albums[0]/photos
    NSString* photos = [NSString stringWithFormat:@"%@/photos", [album objectForKey:@"id"]];
    [FBRequestConnection startWithGraphPath:photos
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              NSArray* photos = (NSArray*)[result data];
                              NSLog(@"You have %d photo(s) in the album %@",
                                    [photos count],
                                    [album objectForKey:@"name"]);
                          }];
}
- (IBAction)getAlbumClicked:(id)sender
{
    if ([FBSession.activeSession.permissions indexOfObject:@"user_photos"] != NSNotFound) {
        
        
        [FBRequestConnection startWithGraphPath:@"/me/albums"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if(error) {
                                      NSLog(@"Error requesting /me/albums");
                                      return;
                                  }
                                  else
                                      [self retrieveAlbums:result];
                                  
                              }];
        
    }

}

#pragma mark TableView delegate methods
// table view data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (tableView == albumsList) {
        if (_albumsRequestResult) {
            NSArray* collection = (NSArray*)[_albumsRequestResult data];
            
            int temp = [collection count];
            
            return 2;// [collection count];
        }
        else
            return 2;
    } else {
        if (_selectedAlbumPhotos)
            return 2;//[_selectedAlbumPhotos count];
        else
            return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
	static NSString *CellIdentifier = @"albumCell";
    static NSString *CellIdentifier2 = @"photoCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil ){
        if ( tableView == albumsList)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        else if (tableView == photosList)
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
    }
#if 1
    int temp = 0;
    NSString *tempStr;
    if (tableView == albumsList) {
        // get the album entry's title
         NSArray* collection = (NSArray*)[_albumsRequestResult data];
        if (indexPath.row <[collection count] ) {
            
            CGRect cellFrame = cell.frame;
            float checkImageWidthOffset = checkImage.size.width+2;
            
            NSDictionary* album = [collection objectAtIndex:indexPath.row];
            NSString *albumName = [album objectForKey:@"name"];
            
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(checkImageWidthOffset, cellFrame.origin.y, cellFrame.size.width-checkImageWidthOffset,cellFrame.size.height)];
            [lbl setText:albumName];
            
            [cell clearsContextBeforeDrawing];
            
            cell.textLabel.text = nil;
#if 0 
            if ( indexPath.row ==_selectedAlbumIndex) {
                
                UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                btn.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, checkImage.size.width, checkImage.size.height);
                [btn setImage:checkImage forState:UIControlStateNormal ];//]:checkImage forState:UITouch];
                [cell addSubview:btn];
                
                
            }
#endif
            [cell addSubview:lbl];
        }
    } else {
#if 0 
        // get the photo entry's titleokcli
        CGRect cellFrame = cell.frame;
        float checkImageWidthOffset = checkImage.size.width+2;
        
        GDataEntryPhoto *photoEntry = [[_albumPhotosFeed entries] objectAtIndex:indexPath.row];
        [cell clearsContextBeforeDrawing];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(checkImageWidthOffset, cellFrame.origin.y, cellFrame.size.width-checkImageWidthOffset,cellFrame.size.height)];
        [lbl setText:[[photoEntry title]stringValue]];
        
        [cell clearsContextBeforeDrawing];
        cell.textLabel.text = nil;
        
        if ( [selectedPhotoIndexArray containsObject:[NSNumber numberWithInt: indexPath.row]]) {
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            btn.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, checkImage.size.width, checkImage.size.height);
            [btn setImage:checkImage forState:UIControlStateNormal ];//]:checkImage forState:UITouch];
            [cell addSubview:btn];
            
            
        }
        [cell addSubview:lbl];
#endif 
    }
#endif
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (tableView == albumsList) {
        NSArray* collection = (NSArray*)[_albumsRequestResult data];
        if (indexPath.row <[collection count] ) {
            
            if (_selectedAlbumIndex != indexPath.row) {
                _selectedAlbumIndex = indexPath.row;
                NSDictionary *album = [collection objectAtIndex:_selectedAlbumIndex];
                [self retrievePhotosByAlbum: album];
            }
            [photosList reloadData];
            
        }
    } else {
        /*
        // get the photo entry's title
        GDataEntryPhoto *photoEntry = [[_albumPhotosFeed entries] objectAtIndex:indexPath.row];
        // cell.textLabel.text = [[photoEntry title] stringValue];
        
        [self updateImageForPhoto:photoEntry];
        
        if ( [selectedPhotoIndexArray containsObject:[NSNumber numberWithInt: indexPath.row]]) {
            [selectedPhotoIndexArray removeObject:[NSNumber numberWithInt: indexPath.row]];
        }
        else
            [selectedPhotoIndexArray addObject:[NSNumber numberWithInt: indexPath.row]];
        [self updatePhotoUI];
         */
    }
    
}
@end
