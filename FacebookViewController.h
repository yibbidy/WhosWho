//
//  FacebookViewController.h
//  WhoIsWho
//
//  Created by Hongbing Carter on 8/9/13.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FacebookViewController :  UIViewController<UITextFieldDelegate, UIPopoverControllerDelegate,UITableViewDelegate, UITableViewDataSource,UIApplicationDelegate>
{
    IBOutlet UITableView *albumsList;
    IBOutlet UITableView *photosList;
    IBOutlet UIImageView *albumPreview;
    IBOutlet UIImageView *photoPreview;
    
     UIImage *checkImage;
}
//@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, retain) UIViewController *hostViewController;
@property (strong, nonatomic) IBOutlet FBProfilePictureView *userProfileImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) FBSession *session;
@property (strong, nonatomic) id albumsRequestResult;
@property (assign) int selectedAlbumIndex;
@property (assign) int selectedPhotoIndex;

-(void)facebookLoginAuthenticate;


- (IBAction)getAlbumClicked:(id)sender;

@end
