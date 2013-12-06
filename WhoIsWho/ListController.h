// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <UIKit/UIKit.h>
//#import "AppView.h"
enum {
    kListBufferSize = 32768
};


@interface ListController  : NSObject{// <NSStreamDelegate>{
	
	UIPopoverController *popoverController;   
	UITextField *gameName; 
	NSString *currentGameFileName; 
	UIView *renderView; 
	

	// List 
	NSInputStream *             _listNetworkStream;
	
	NSMutableData *             _listData;
    NSMutableArray *            _listEntries;           // of NSDictionary as returned by CFFTPCreateParsedResourceListing
	NSMutableArray *			_listGameNames; 
	
   // NSString *                  _status;
	
	uint8_t                     _buffer[kListBufferSize];
    size_t                      _bufferOffset;
    size_t                      _bufferLimit;
	short						streamKind; 
	
}
	
@property (nonatomic, retain) UIPopoverController *popoverController;

@property (nonatomic, retain)   NSInputStream *	listNetworkStream; 

@property (nonatomic, readonly) uint8_t *         buffer;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;
//@property (nonatomic, retain) IBOutlet UITextField *gameName;
@property (nonatomic, retain)   NSMutableData *   listData;
@property (nonatomic, retain)   NSMutableArray *  listEntries;
@property (nonatomic, retain)   NSMutableArray *  listGameNames;
@property (nonatomic, retain)	UIView *		  renderView; 	
 
- (void)startList;; 

- (NSURL *)smartURLForString:(NSString *)str; 
- (void)_addListEntries:(NSArray *)newEntries; 
- (NSDictionary *)_entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding; 
- (void)parseListData; 
 

- (void)_stopListWithStatus:(NSString *)statusString; 

- (void) getListOfGameNames; 

@end
