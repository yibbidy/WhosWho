//
//  ChooseImagesSitesViewController.h
//  WhoIsWho
//
//  Created by Hongbing Carter on 3/30/13.
//
//

#import <UIKit/UIKit.h>
#import "PicasaViewController.h"

static NSString *getPhotosFromPicasa= @"Get photos from Picasa...";
static NSString *getPhotosLocally = @"Get photos locally...";

@protocol ChooseSitesControllerDelegate;
@interface ChooseImagesSitesViewController : UITableViewController<UIPopoverControllerDelegate> {
	NSMutableArray* commandsArray;
	id<ChooseSitesControllerDelegate>  delegate;
	
}

@property (nonatomic,retain) NSMutableArray* commandsArray;
@property (nonatomic, retain) id<ChooseSitesControllerDelegate> delegate;

-(void)reloadCommandsArray;
@end

@protocol ChooseSitesControllerDelegate <NSObject>
@required
- (void)commandPicker:(ChooseImagesSitesViewController *)controller didChooseCommand:(NSString *)commandNameStr;
- (void)commandPicker:(ChooseImagesSitesViewController *)controller highlightGameName :(NSString *)commandNameStr;
// nil for cancellation
@end
