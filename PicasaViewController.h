//
//  PicasaViewController.h
//  WhoIsWho
//
//  Created by Hongbing Carter on 4/9/13.
//
//

#import <UIKit/UIKit.h>
#import "GDataServiceGooglePhotos.h"
#import "GDataEntryPhotoAlbum.h"
#import "GDataEntryPhoto.h"
#import "GDataFeedPhotoUser.h"
#import "GDataFeedPhotoAlbum.h"
#import "GDataMediaThumbnail.h"
#import "GDataQueryGooglePhotos.h"
#import "GDataMediaContent.h"

@interface PicasaViewController : UIViewController<UITextFieldDelegate, UIPopoverControllerDelegate,UITableViewDelegate, UITableViewDataSource>
{

    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    IBOutlet UITableView *albumsList;
    IBOutlet UITableView *photosList;
    IBOutlet UIImageView *albumPreview;
    IBOutlet UIImageView *photoPreview;
    NSError *_albumFetchError;
    NSError *_photosFetchError;
    
    NSError *albumFetchError;
    NSString *albumImageURLString;
    
    NSError *photosFetchError;
    NSString *photoImageURLString;
    
    GDataEntryPhotoAlbum *selectedAlbum;
    NSMutableArray *selectedPhotoIndexArray;
    
    UIPopoverController *popoverController;
    UIImage *checkImage;
    UIViewController *hostViewController;
}

@property (nonatomic, strong) GDataFeedPhotoUser *userAlbumFeed; // user feed of album entries
@property (nonatomic, strong) GDataServiceTicket *albumFetchTicket;
@property (nonatomic, strong) GDataFeedPhotoAlbum *albumPhotosFeed; // album feed of photo entries
@property (nonatomic, strong) GDataServiceTicket *photosFetchTicket;
@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIViewController *hostViewController;
@property (assign) BOOL isExportingPhotos;
@property (assign) int selectedAlbumIndex;
@property (assign) int selectedPhotoIndex;

- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

- (IBAction)getAlbumClicked:(id)sender;
@end

