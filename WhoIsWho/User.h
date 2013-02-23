// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FromFriend, ToFriend;

@interface User : NSManagedObject {
}
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * passwd;
@property (nonatomic, retain) FromFriend *gamesFrom;
@property (nonatomic, retain) NSSet *gameTo;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addGameToObject:(ToFriend *)value;
- (void)removeGameToObject:(ToFriend *)value;
- (void)addGameTo:(NSSet *)values;
- (void)removeGameTo:(NSSet *)values;

@end
