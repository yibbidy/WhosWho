// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface ToFriend : NSManagedObject

@property (nonatomic, retain) id friends;
@property (nonatomic, retain) NSString * gameName;
@property (nonatomic, retain) User *fromUser;

@end
