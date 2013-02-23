// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface FromFriend : NSManagedObject

@property (nonatomic, retain) NSString * friendFrom;
@property (nonatomic, retain) id gameList;
@property (nonatomic, retain) User *toUser;

@end
