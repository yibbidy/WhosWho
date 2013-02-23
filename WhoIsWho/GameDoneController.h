// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <UIKit/UIKit.h>

@protocol GameDoneControllerDelegate;

@interface GameDoneController : UITableViewController {
	NSMutableArray* commandsArray;  
	id<GameDoneControllerDelegate>  delegate;
	
}
@property (nonatomic,retain) NSMutableArray* commandsArray;
@property (nonatomic, retain) id<GameDoneControllerDelegate> delegate;


-(void)reloadCommandsArray;

@end


@protocol GameDoneControllerDelegate <NSObject>
@required
- (void)commandPicker:(GameDoneController *)controller didChooseCommand:(NSString *)commandNameStr; 
- (void)commandPicker:(GameDoneController *)controller highlightGameName :(NSString *)commandNameStr; 
// nil for cancellation
@end