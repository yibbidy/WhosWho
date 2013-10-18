//
//  Facebook2ViewController.m
//  WhoIsWho
//
//  Created by Hongbing Carter on 9/5/13.
//
//

#import "Facebook2ViewController.h"

#import "AppDelegate.h"
#import "TViewController.h"
#import "FacebookTableViewCell.h"

@interface Facebook2ViewController ()
@property (strong) NSMutableArray *selectedAlbumPhotos;
@property (strong) NSMutableArray *selectedPhotoIndexArray; 
@end

static NSString *fbEmail= @"email";
static NSString *fbUserPhotos = @"user_photos";

@implementation Facebook2ViewController

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
    Facebook2ViewController *controller = self; 
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
                 NSString *temp = user.name;
                 NSString *temp2= user.id;
                 controller.userNameLabel.text = user.name;
                 controller.userProfileImage.profileID = user.id;
                 
             }
         }];
    }
}
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
    [FBProfilePictureView class];
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _selectedAlbumPhotos = [[NSMutableArray alloc] init];
        _selectedPhotoIndexArray = [[NSMutableArray alloc] init]; 
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _selectedAlbumIndex = 0;
    _selectedPhotoIndex = 0;
    
    NSString *newFileName = @"check.jpg";
	NSString *extension = [newFileName pathExtension];
	NSString *newFileNameWithNoExtension = [newFileName stringByDeletingPathExtension];
	checkImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:newFileNameWithNoExtension ofType:extension]];
    photoPreview.image =nil;
    albumPreview.image = nil;
    
    if (FBSession.activeSession.isOpen) {
        [self populateUserDetails];
    }
}
- (void)viewDidUnload
{
    
    [super viewDidUnload];

    albumsList = nil;
    photosList = nil;
    albumPreview = nil;
    photoPreview = nil;
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [photosList removeFromSuperview];
    [albumsList removeFromSuperview];
    albumsList = nil;
    photosList = nil;
    albumPreview = nil;
    photoPreview = nil;
}
-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
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
                              
                              _photosRequestResult = result;
                              [photosList reloadData];
                              
                              NSArray* photos = (NSArray*)[result data];
                              NSLog(@"You have %d photo(s) in the album %@",
                                    [photos count],
                                    [album objectForKey:@"name"]);
                          }];
#endif
}

-(void)request:(FBRequest *)request didLoad:(id)result {
    
    NSString *url = [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
    
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    photoPreview.image = [UIImage imageWithData:data];
}
-(UIImage *)getImageByPhotoObject:(id) photoObject
{
    NSArray *images =  [photoObject objectForKey:@"images"] ;
    id oneImage = [images objectAtIndex:0];
    NSString *source = [oneImage objectForKey:@"source"];
    NSURL *url  =  [NSURL URLWithString:source];
    NSData *data = [NSData dataWithContentsOfURL:url];
    
   return [UIImage imageWithData:data];
}
-(void) retrievePhotosByAlbum: (NSDictionary*)album forAlbumPreview:(BOOL)isForPreview
{
    
    NSString* photos = [NSString stringWithFormat:@"%@/photos", [album objectForKey:@"id"]];
    [FBRequestConnection startWithGraphPath:photos
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              _photosRequestResult = result;
                              
                              // Get the first photo in the album for album preview 
                              if (isForPreview) {
                                  NSArray* photos = (NSArray*)[result data];
                                  id object = [photos objectAtIndex:0];
                                  albumPreview.image = [self getImageByPhotoObject:object];
                                        
                                  NSLog(@"You have %d photo(s) in the album %@",
                                        [photos count],
                                        [album objectForKey:@"name"]);
                              }
                              [photosList reloadData];
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
                                  else {
                                      [self retrieveAlbums:result];
                                      NSArray* collection = (NSArray*)[_albumsRequestResult data];
                                      NSDictionary *album = [collection objectAtIndex:0];
                                      [self retrievePhotosByAlbum: album forAlbumPreview:YES];
                                  }
                                  
                              }];
        
    }
    
}
- (IBAction)switchUsers:(id)sender
{
    
    [FBSession.activeSession closeAndClearTokenInformation];
    
    
    NSArray *permission = [NSArray arrayWithObjects:fbEmail,fbUserPhotos, nil];
    
    FBSession *session = [[FBSession alloc] initWithPermissions:permission];
    [FBSession setActiveSession: session];
    
    [[FBSession activeSession] openWithBehavior:FBSessionLoginBehaviorForcingWebView completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        
        switch (status) {
            case FBSessionStateOpen: {
                
                _albumsRequestResult = nil;
                _photosRequestResult = nil;
                
                [photosList reloadData];
                [albumsList reloadData];
                
                albumPreview.image = nil;
                photoPreview.image = nil; 
                [self populateUserDetails];
                
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
- (IBAction)cancelClicked:(id)sender
{
    [_hostPopoverController dismissPopoverAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}
- (IBAction)okClicked:(id)sender
{
    int totalPhotosSelected = 0;
    
    for (int i = 0; i < photosList.numberOfSections;i++) {
        for (int j = 0; j <[photosList numberOfRowsInSection:i]; j++) {
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            FacebookTableViewCell *cell = (FacebookTableViewCell *)[photosList cellForRowAtIndexPath:indexPath];
            for (int k = 0; k <kNumberOfImages; k++) {
                if ( [cell.selectedImageIndex[k] integerValue] != -1)
                    totalPhotosSelected++;
            }
        }
    }
    [(TViewController *)_hostViewController setTotalPhotosToDownload:totalPhotosSelected];
    [(TViewController *)_hostViewController  setPhotosDownloaded:0];
    
    _photosRequestResult = nil;
    for (int i = 0; i < photosList.numberOfSections;i++) {
        for (int j = 0; j <[photosList numberOfRowsInSection:i]; j++) {
         
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:j inSection:i];
            FacebookTableViewCell *cell = (FacebookTableViewCell *)[photosList cellForRowAtIndexPath:indexPath];
            for (int k = 0; k <kNumberOfImages; k++) {
                if ( [cell.selectedImageIndex[k] integerValue] != -1) {
                    UIImage *eachImage = cell.images[k];
                    if (eachImage)
                        [(TViewController *)_hostViewController addLocalImageToPhotos:eachImage];
                    
                }
            }
        }
    }
    [_hostPopoverController dismissPopoverAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}
#pragma mark TableView delegate methods
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
            
            return [collection count];
        }
        else
            return 0;
    } else {
        if (_photosRequestResult) {
            NSArray* collection = (NSArray*)[_photosRequestResult data];
            int numOfRows = ceilf((float)([collection count])/kNumberOfImages);
            return numOfRows;
        }
        else
            return 0;
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
            cell = [[FacebookTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier2];
    }

    if (tableView == albumsList) {
        // get the album entry's title
        if (!_albumsRequestResult)  
            cell = nil;
        else {
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
                
                if ( indexPath.row ==_selectedAlbumIndex) {
                    
                    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                    btn.frame = CGRectMake(cellFrame.origin.x, cellFrame.origin.y, checkImage.size.width, checkImage.size.height);
                    [btn setImage:checkImage forState:UIControlStateNormal ];//]:checkImage forState:UITouch];
                    [cell addSubview:btn];
                    
                    
                }

                [cell addSubview:lbl];
            }
        }
    } else {


        if (!_photosRequestResult)
            cell.textLabel.text = nil;
        else {
            // get the photo entry's titleokcli
            
            
            NSArray* collection = (NSArray*)[_photosRequestResult data];
            
            int totalImages = [collection count];
            
            if (indexPath.row*kNumberOfImages <[collection count] ) {
                
                [cell clearsContextBeforeDrawing];
                
                NSMutableArray *photoImages = [NSMutableArray arrayWithCapacity:kNumberOfImages];
                
                for (int i = 0; i <kNumberOfImages; i++) {
                    int imageIndex = indexPath.row*kNumberOfImages+i;
                    if (imageIndex< totalImages) {
                        id photoObject = [collection objectAtIndex:imageIndex];
                        UIImage *image = [self getImageByPhotoObject:photoObject]; 
                        
                        [photoImages addObject:image];
                    }
                }
                FacebookTableViewCell *facebookCell = (FacebookTableViewCell *)cell;
                [facebookCell initImages:photoImages];
                [photoImages removeAllObjects];
                photoImages = nil;
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
#if 0
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (tableView == albumsList) {
        NSArray* collection = (NSArray*)[_albumsRequestResult data];
        if (indexPath.row <[collection count] ) {
            
            if (_selectedAlbumIndex != indexPath.row) {
                _selectedAlbumIndex = indexPath.row;
                NSDictionary *album = [collection objectAtIndex:_selectedAlbumIndex];
                [self retrievePhotosByAlbum: album forAlbumPreview:NO];
            }
                        
        }
    } else {
        
        NSArray* collection = (NSArray*)[_photosRequestResult data];
        UIImage *image = nil; 
        if (indexPath.row <[collection count] ) {
            id photoObject = [collection objectAtIndex:indexPath.row];
            image = [self getImageByPhotoObject:photoObject];
        }
        if ( [_selectedPhotoIndexArray containsObject:[NSNumber numberWithInt: indexPath.row]]) {
            [_selectedPhotoIndexArray removeObject:[NSNumber numberWithInt: indexPath.row]];
            cell.imageView.image = image; 
        }
        else {
            [_selectedPhotoIndexArray addObject:[NSNumber numberWithInt: indexPath.row]];
            // Get the width and height of the image
            size_t width = CGImageGetWidth(image.CGImage);
            size_t height = CGImageGetHeight(image.CGImage);
            
            CGContextRef ctx;
            CGColorSpaceRef            colorSpace;
            unsigned char *imageData =nil;// (unsigned char *)malloc(height * width * 4);
            
            colorSpace = CGColorSpaceCreateDeviceRGB();
            ctx = CGBitmapContextCreate(imageData, width, height, 8, 4*width, colorSpace, kCGImageAlphaPremultipliedLast);
            
            CGContextClearRect(ctx,  CGContextGetPathBoundingBox(ctx));
            CGContextSetRGBFillColor(ctx, 1, 1, 0.0, 0.25f);
            CGContextFillRect(ctx, CGRectMake(0, 0, width, height));
            
            CGContextSetBlendMode(ctx, kCGBlendModeDestinationAtop);
            CGContextDrawImage(ctx, CGRectMake(0, 0, width, height), image.CGImage);
            
            CGImageRef ciImage= CGBitmapContextCreateImage(ctx);
            
            UIImage *newImage =  [UIImage imageWithCGImage:ciImage];
            
            cell.imageView.image = newImage;
            CGContextRelease(ctx);
            CGColorSpaceRelease(colorSpace);
        }
    }
#endif 
}

- (void) photoImageViewPressed:(UITapGestureRecognizer *)recoginizer {
    NSUInteger index = recoginizer.view.tag;
    
  //  if (index < _images.count) {
    //    NSDictionary *photo = _images[recoginizer.view.tag];
      //  [self.delegate facebookPhotoGridTableViewCell:self didSelectPhoto:photo withPreviewImage:[(UIImageView *)recoginizer.view image]];
   // }
}


@end
