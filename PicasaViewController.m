//
//  PicasaViewController.m
//  WhoIsWho
//
//  Created by Hongbing Carter on 4/9/13.
//
//

#import "PicasaViewController.h"
#import "TViewController.h"

@interface PicasaViewController ()

@end

@implementation PicasaViewController
@synthesize popoverController, hostViewController;

- (GDataServiceGooglePhotos *)googlePhotosService {
    
    static GDataServiceGooglePhotos* service = nil;
    
    if (!service) {
        service = [[GDataServiceGooglePhotos alloc] init];
        
        [service setShouldCacheResponseData:YES];
        [service setServiceShouldFollowNextLinks:YES];
    }
    
    // update the username/password each time the service is requested
    NSString *username = [usernameField text];
    NSString *password = [passwordField text];

    if ([username length] && [password length]) {
        [service setUserCredentialsWithUsername:username
                                       password:password];
    } else {
        [service setUserCredentialsWithUsername:nil
                                       password:nil];
    }

    return service;
}

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
    NSString *newFileName = @"check.jpg";
	NSString *extension = [newFileName pathExtension];
	NSString *newFileNameWithNoExtension = [newFileName stringByDeletingPathExtension];
	checkImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:newFileNameWithNoExtension ofType:extension]];
    
    
    albumsList.delegate = self;
    albumsList.dataSource = self;
    
    photosList.delegate = self;
    photosList.dataSource = self;
    
    albumsList.scrollEnabled = YES;
    photosList.scrollEnabled = YES;
    
    usernameField.delegate = self;
    passwordField.delegate = self;
    _isExportingPhotos = NO;
    
    selectedAlbum = nil;
    selectedPhotoIndexArray = [[NSMutableArray alloc] init];
   
    _selectedAlbumIndex = -1;
    _selectedPhotoIndex = -1;
    
    [self setEditing:YES animated:YES];
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    usernameField = nil;
    passwordField = nil;
    albumsList = nil;
    photosList = nil; 
    albumPreview = nil;
    photoPreview = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
-(void)updateAlbumUI
{
    // album fetch result or selected item
    NSString *albumResultStr = @"";
    if (_albumFetchError) {
        albumResultStr = [_albumFetchError description];
        [self updateImageForAlbum:nil];
    } else {
        GDataEntryPhotoAlbum *album = [self selectedAlbum];
        if (album) {
            albumResultStr = [album description];
        }
        // fetch or clear the album thumbnail
        [self updateImageForAlbum:album];
    }
}
-(void)updatePhotoUI
{
    // photo list display
    [photosList reloadData];
    // display photo entry fetch result or selected item
    GDataEntryPhoto *selectedPhoto = [self selectedPhoto];
    
    NSString *photoResultStr = @"";
    if (photosFetchError) {
        photoResultStr = [photosFetchError description];
        // [self updateImageForPhoto:nil];
    } else {
        if (selectedPhoto) {
            photoResultStr = [selectedPhoto description];
        }
        // fetch or clear the photo thumbnail
        // [self updateImageForPhoto:selectedPhoto];
    }
}
- (void)albumListFetchTicket:(GDataServiceTicket *)ticket
            finishedWithFeed:(GDataFeedPhotoUser *)feed
                       error:(NSError *)error {
    _userAlbumFeed = feed;
    _albumFetchError = error;
    _albumFetchTicket= nil;
    
    if (error == nil) {
        // load the Change Album pop-up button with the
        // album entries
       // [self updateChangeAlbumList];
    }
    
    [self updateUI];
}

// begin retrieving the list of the user's albums
- (void)fetchAllAlbums {
    
    _userAlbumFeed = nil;
    _albumFetchError= nil;
    _albumFetchTicket = nil;
   
    _albumPhotosFeed = nil; 
    _photosFetchError = nil; 
    _photosFetchTicket= nil; 
    
    NSString *username = [usernameField text];
    
    GDataServiceGooglePhotos *service = [self googlePhotosService];
    GDataServiceTicket *ticket;
    
    NSURL *feedURL = [GDataServiceGooglePhotos photoFeedURLForUserID:username
                                                             albumID:nil
                                                           albumName:nil
                                                             photoID:nil
                                                                kind:nil
                                                              access:nil];
    ticket = [service fetchFeedWithURL:feedURL
                              delegate:self
                     didFinishSelector:@selector(albumListFetchTicket:finishedWithFeed:error:)];
    [self setAlbumFetchTicket:ticket];
    
  //  [self updateUI];
}
- (void)updateUI {
    
    // album list display
    [albumsList reloadData];

    // album fetch result or selected item
    NSString *albumResultStr = @"";
    if (_albumFetchError) {
        albumResultStr = [_albumFetchError description];
        [self updateImageForAlbum:nil];
    } else {
        GDataEntryPhotoAlbum *album = [self selectedAlbum];
        if (album) {
            albumResultStr = [album description];
        }
        // fetch or clear the album thumbnail
        [self updateImageForAlbum:album];
    }
   // [mAlbumResultTextField setString:albumResultStr];
 
    // photo list display
    [photosList reloadData];
 
   
    // display photo entry fetch result or selected item
    GDataEntryPhoto *selectedPhoto = [self selectedPhoto];
    
    NSString *photoResultStr = @"";
    if (photosFetchError) {
        photoResultStr = [photosFetchError description];
       // [self updateImageForPhoto:nil];
    } else {
        if (selectedPhoto) {
            photoResultStr = [selectedPhoto description];
        }
        // fetch or clear the photo thumbnail
       // [self updateImageForPhoto:selectedPhoto];
    }
    /*
    [mPhotoResultTextField setString:photoResultStr];
    
    // enable/disable cancel buttons
    [mAlbumCancelButton setEnabled:(mAlbumFetchTicket != nil)];
    [mPhotoCancelButton setEnabled:(mPhotosFetchTicket != nil)];
    
    // enable/disable other buttons
    BOOL isAlbumSelected = ([self selectedAlbum] != nil);
    BOOL isPasswordProvided = ([[mPasswordField stringValue] length] > 0);
    [mAddToDropBoxButton setEnabled:isPasswordProvided];
    [mAddToAlbumButton setEnabled:(isAlbumSelected && isPasswordProvided)];
    
    BOOL isPhotoEntrySelected = (selectedPhoto != nil &&
                                 [selectedPhoto videoStatus] == nil);
    [mDownloadPhotoButton setEnabled:isPhotoEntrySelected];
    
    BOOL isSelectedEntryEditable = ([selectedPhoto editLink] != nil);
    [mDeletePhotoButton setEnabled:isSelectedEntryEditable];
    [mChangeAlbumPopupButton setEnabled:isSelectedEntryEditable];
    
    BOOL hasPhotoFeed = ([selectedPhoto feedLink] != nil);
    
    BOOL isTagProvided = ([[mTagField stringValue] length] > 0);
    BOOL isCommentProvided = ([[mCommentField stringValue] length] > 0);
    
    [mAddTagButton setEnabled:(hasPhotoFeed && isTagProvided)];
    [mAddCommentButton setEnabled:(hasPhotoFeed && isCommentProvided)];
    
    BOOL doesFeedHavePostLink = ([mUserAlbumFeed postLink] != nil);
    BOOL isNewAlbumNameProvided = ([[mCreateAlbumField stringValue] length] > 0);
    BOOL canCreateAlbum = doesFeedHavePostLink && isNewAlbumNameProvided;
    [mCreateAlbumButton setEnabled:canCreateAlbum];
    */
}
- (IBAction)okClicked:(id)sender {
    
    if ( _albumPhotosFeed) {
        
        [(TViewController *)hostViewController setTotalPhotosToDownload: [selectedPhotoIndexArray count]];
        [(TViewController *)hostViewController  setPhotosDownloaded:0];
         
        for (int i = 0; i < [[_albumPhotosFeed entries] count]; i++) {
            if ( [selectedPhotoIndexArray containsObject:[NSNumber numberWithInt:i] ]) {
                GDataEntryPhoto *photoEntry = [[_albumPhotosFeed entries] objectAtIndex:i];
                [self downloadSelectedPhoto:photoEntry];
            }
        }
    }
    [popoverController dismissPopoverAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancelClicked:(id)sender {
    
    [_albumFetchTicket cancelTicket];
    [_photosFetchTicket cancelTicket];
    
    [popoverController dismissPopoverAnimated:NO];
    [self dismissViewControllerAnimated:NO completion:nil];
}
-(void)getAlbum
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    
    NSString *username = [usernameField text];
    username = [username stringByTrimmingCharactersInSet:whitespace];
    
    if ([username rangeOfString:@"@"].location == NSNotFound) {
        // if no domain was supplied, add @gmail.com
        username = [username stringByAppendingString:@"@gmail.com"];
    }
    
    [usernameField setText:username];
    
    [self fetchAllAlbums];
}

- (IBAction)getAlbumClicked:(id)sender {
    [self getAlbum]; 
}
#pragma mark Fetch an album's photos
// get the album selected in the top list, or nil if none
- (GDataEntryPhotoAlbum *)selectedAlbum {
    
    NSArray *albums = [_userAlbumFeed entries];
    int rowIndex =_selectedAlbumIndex;
    if (rowIndex > -1 && rowIndex <[albums count]) {
        
        GDataEntryPhotoAlbum *album = [albums objectAtIndex:rowIndex];
        return album;
    }
    return nil;
}

// get the photo selected in the bottom list, or nil if none
- (GDataEntryPhoto *)selectedPhoto {
    
    NSArray *photos = [_albumPhotosFeed entries];
    int rowIndex =_selectedPhotoIndex;
    if ( rowIndex > -1 && rowIndex <[photos count]) {
        
        GDataEntryPhoto *photo = [photos objectAtIndex:rowIndex];
        return photo;
    }
    return nil;
}

// for the album selected in the top list, begin retrieving the list of
// photos
- (void)fetchSelectedAlbum :( GDataEntryPhotoAlbum *)album
{
    if (album) {
        
        // fetch the photos feed
        NSURL *feedURL = [[album feedLink] URL];
        if (feedURL) {
            _albumPhotosFeed = nil;
            photosFetchError = nil;
            _photosFetchTicket = nil;
            
            GDataServiceGooglePhotos *service = [self googlePhotosService];
            GDataServiceTicket *ticket;
            ticket = [service fetchFeedWithURL:feedURL
                                      delegate:self
                             didFinishSelector:@selector(photosTicket:finishedWithFeed:error:)];
            _photosFetchTicket = ticket;
            
            // album list display
            [albumsList reloadData];
            [self updateAlbumUI];
            
        }
    }
}
- (void)photosTicket:(GDataServiceTicket *)ticket
    finishedWithFeed:(GDataFeedPhotoAlbum *)feed
               error:(NSError *)error {
    
    _albumPhotosFeed = feed;
    _albumFetchError = error;
    _photosFetchTicket= nil;
    
    for (int i = 0; i < [[_albumPhotosFeed entries] count]; i++)
        [selectedPhotoIndexArray addObject: [NSNumber numberWithInt:i]];
           
    [self updatePhotoUI];
}
- (void)imageFetcher:(GTMHTTPFetcher *)fetcher finishedWithData:(NSData *)data error:(NSError *)error {
    if (error == nil) {
        // got the data; display it in the image view
        UIImage *image = [[UIImage alloc] initWithData:data];
       
        UIImageView *view = (UIImageView *)[fetcher userData];
        [view setImage:image];
    } else {
        NSLog(@"imageFetcher:%@ error:%@", fetcher,  error);
    }
}
- (void)fetchURLString:(NSString *)urlString
          forImageView:(UIImageView *)view
                 title:(NSString *)title {
    
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithURLString:urlString];
    
    // use the fetcher's userData to remember which image view we'll display
    // this in once the fetch completes
    [fetcher setUserData:view];
    
    // http logs are more readable when fetchers have comments
    [fetcher setCommentWithFormat:@"thumbnail for %@", title];
    
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:@selector(imageFetcher:finishedWithData:error:)];
}
// fetch or clear the thumbnail for this specified album
- (void)updateImageForAlbum:(GDataEntryPhotoAlbum *)album {
    
    // if there's a thumbnail and it's different from the one being shown,
    // fetch it now
   // [albumPreview seetBorderStyle:];
    if (!album) {
        // clear the image
        [albumPreview setImage:nil];
        albumImageURLString = nil; 
        
    } else {
        // if the new thumbnail URL string is different from the previous one,
        // save the new one, clear the image and fetch the new image
        
        NSArray *thumbnails = [[album mediaGroup] mediaThumbnails];
        if ([thumbnails count] > 0) {
            GDataMediaThumbnail *thumbnail = [thumbnails objectAtIndex:0];
            
            NSString *imageURLString = [thumbnail URLString];
            if (!imageURLString || ![albumImageURLString isEqual:imageURLString]) {
                
                albumImageURLString= imageURLString;
                [albumPreview setImage:nil];
                
                if (imageURLString) {
                    [self fetchURLString:imageURLString
                            forImageView:albumPreview
                                   title:[[album title] stringValue]];
                }
            } 
        }
    }
}
- (void)updateImageForPhoto:(GDataEntryPhoto *)photo {
    
    // if there's a thumbnail and it's different from the one being shown,
    // fetch it now
    if (!photo) {
        // clear the image
        [photoPreview setImage:nil];
        photoImageURLString = nil;
        
    } else {
        // if the new thumbnail URL string is different from the previous one,
        // save the new one, clear the image and fetch the new image
        
        NSArray *thumbnails = [[photo mediaGroup] mediaThumbnails];
        if ([thumbnails count] > 0) {
            
            NSString *imageURLString = [[thumbnails objectAtIndex:0] URLString];
            if (!imageURLString || ![photoImageURLString isEqual:imageURLString]) {
                
                photoImageURLString = imageURLString;
                [photoPreview setImage:nil];
                
                if (imageURLString) {
                    [self fetchURLString:imageURLString
                            forImageView:photoPreview
                                   title:[[photo title] stringValue]];
                }
            }
        }
    }
}

#pragma mark Download a photo

- (void)downloadSelectedPhoto :(GDataEntryPhoto *) photoEntry
{
    if (photoEntry) {
       
          // the user clicked Save
          //
          // the feed may not have images in the original size, so we'll re-fetch the
          // photo entry with a query specifying that we want the original size
          // for downloading
    
          
          NSURL *entryURL = [[photoEntry selfLink] URL];
          
          GDataQueryGooglePhotos *query;
          query = [GDataQueryGooglePhotos photoQueryWithFeedURL:entryURL];
          
          // this specifies "imgmax=d" as described at
          // http://code.google.com/apis/picasaweb/docs/2.0/reference.html#Parameters
          [query setImageSize:kGDataGooglePhotosImageSizeDownloadable];
          
          GDataServiceGooglePhotos *service = [self googlePhotosService];
          GDataServiceTicket *ticket;
          ticket = [service fetchEntryWithURL:[query URL]
                                     delegate:self
                            didFinishSelector:@selector(fetchEntryTicket:finishedWithEntry:error:)];
    }
}

- (void)fetchEntryTicket:(GDataServiceTicket *)ticket
       finishedWithEntry:(GDataEntryPhoto *)photoEntry
                   error:(NSError *)error {
    if (error == nil) {
        // now download the uploaded photo data
        NSString *savePath = [ticket propertyForKey:@"save path"];
        
        // we'll search for the media content element with the medium attribute of
        // "image" to find the download URL; there may be more than one
        // media:content element
        //
        // http://code.google.com/apis/picasaweb/docs/2.0/reference.html#media_content
        NSArray *mediaContents = [[photoEntry mediaGroup] mediaContents];
        GDataMediaContent *imageContent;
        imageContent = [GDataUtilities firstObjectFromArray:mediaContents
                                                  withValue:@"image"
                                                 forKeyPath:@"medium"];
        if (imageContent) {
            NSURL *downloadURL = [NSURL URLWithString:[imageContent URLString]];
            
            // requestForURL:ETag:httpMethod: sets the user agent header of the
            // request and, when using ClientLogin, adds the authorization header
            GDataServiceGooglePhotos *service = [self googlePhotosService];
            NSMutableURLRequest *request = [service requestForURL:downloadURL
                                                             ETag:nil
                                                       httpMethod:nil];
            // fetch the request
            GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
            [fetcher setAuthorizer:[service authorizer]];
            [fetcher setShouldFetchInBackground:YES]; 
            // http logs are easier to read when fetchers have comments
            [fetcher setCommentWithFormat:@"downloading %@",
             [[photoEntry title] stringValue]];
            
            [fetcher beginFetchWithDelegate:self
                          didFinishSelector:@selector(downloadFetcher:finishedWithData:error:)];
            
            [fetcher setProperty:savePath forKey:@"save path"];
            [fetcher setProperty:photoEntry forKey:@"photo entry"];
        } else {
            // no image content for this photo entry; this shouldn't happen for
            // photos
        }
    }
}

- (void)downloadFetcher:(GTMHTTPFetcher *)fetcher
       finishedWithData:(NSData *)data
                  error:(NSError *)error {
    if (error == nil) {
        

        GDataEntryPhoto *photoEntry = [fetcher propertyForKey:@"photo entry"];
        [(TViewController *)hostViewController addImageToPhotos:data photoName: [[photoEntry title] stringValue]];
        int nn = 100; 
        /*
        // successfully retrieved this photo's data; save it to disk
        NSString *savePath = [fetcher propertyForKey:@"save path"];
        GDataEntryPhoto *photoEntry = [fetcher propertyForKey:@"photo entry"];
        
        NSError *error = nil;
        BOOL didSave = [data writeToFile:savePath
                                 options:NSAtomicWrite
                                   error:&error];
        if (didSave) {
            // we'll set the file date to match the photo entry's date
            NSDate *photoDate = [[photoEntry timestamp] dateValue];
            if (photoDate) {
                NSDictionary *attr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      photoDate, NSFileCreationDate,
                                      photoDate, NSFileModificationDate, nil];
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                [fileMgr setAttributes:attr ofItemAtPath:savePath error:NULL];
            }
        }
         */
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
        return [[_userAlbumFeed entries] count];
    } else {
        // entry table
        return [[_albumPhotosFeed entries] count];
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
    
    int temp = 0;
    NSString *tempStr;
    if (tableView == albumsList) {
        // get the album entry's title
        if (indexPath.row <[[_userAlbumFeed entries] count] ) {
           
            CGRect cellFrame = cell.frame;
            float checkImageWidthOffset = checkImage.size.width+2;
            
            GDataEntryPhotoAlbum *album = [[_userAlbumFeed entries] objectAtIndex:indexPath.row];
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(checkImageWidthOffset, cellFrame.origin.y, cellFrame.size.width-checkImageWidthOffset,cellFrame.size.height)];
            [lbl setText:[[album title]stringValue]];
            
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
    } else {
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
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
    if (tableView == albumsList) {
        // get the album entry's title
        if (indexPath.row <[[_userAlbumFeed entries] count] ) {
            
            if (_selectedAlbumIndex != indexPath.row) {
                _selectedAlbumIndex = indexPath.row;
                GDataEntryPhotoAlbum *album = [[_userAlbumFeed entries] objectAtIndex:_selectedAlbumIndex];
                [self fetchSelectedAlbum: album];
            }
             [self updatePhotoUI];
            
        }
    } else {
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
    }

}
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
#pragma mark -
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
   // textField.clearsOnBeginEditing = YES;
   
    CGSize popSize = popoverController.popoverContentSize;
    CGRect frameRect = self.view.frame;
    CGRect textFieldRect = textField.frame;
    textFieldRect.origin.x = 0;
    textFieldRect.origin.y = 0;
    // textFieldRect.size = popoverController.popoverContentSize;
    
    [popoverController presentPopoverFromRect:textFieldRect inView: self.hostViewController.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];

	return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}
-(BOOL)textFieldShouldReturn:(UITextField *)sender
{
	if ( [sender.text length]>3  ) {
        [sender setTextColor:[UIColor blackColor]];
		//finish editing
		[sender resignFirstResponder];
    
		return YES;
	} else {
		return NO;
	}
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)sender
{
	if ([sender.text length]>3  ) {
        
		//finish editing
		
		[sender resignFirstResponder];
		if ( sender == passwordField)
            [self getAlbum];
        
		return YES;
	} else {
		return NO;
	}
}
@end
