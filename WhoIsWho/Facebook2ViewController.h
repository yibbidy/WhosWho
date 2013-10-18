//
//  Facebook2ViewController.h
//  WhoIsWho
//
//  Created by Hongbing Carter on 9/5/13.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface Facebook2ViewController : UIViewController<UITextFieldDelegate, UIPopoverControllerDelegate,UITableViewDelegate, UITableViewDataSource,UIApplicationDelegate, FBRequestDelegate>
{
    IBOutlet UITableView *albumsList;
    IBOutlet UITableView *photosList;
    
    IBOutlet UIImageView *albumPreview;
    IBOutlet UIImageView *photoPreview;
    
    UIImage *checkImage;
    
}
@property (nonatomic, retain) UIViewController *hostViewController;
@property (nonatomic, retain) UIPopoverController *hostPopoverController;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) id albumsRequestResult;
@property (strong, nonatomic) id photosRequestResult;
@property (assign) int selectedAlbumIndex;
@property (assign) int selectedPhotoIndex;

-(void)facebookLoginAuthenticate;
- (IBAction)getAlbumClicked:(id)sender;
- (IBAction)switchUsers:(id)sender;
- (IBAction)okClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;

@end
