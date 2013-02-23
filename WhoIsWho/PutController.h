// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <UIKit/UIKit.h>
//#import "GamesSelectionController.h"
//#import "GameDoneController.h"
enum {
    kPutBufferSize = 32768
};
enum STREAM_KIND {
	kStreamCreateDir, 
	kStreamPut, 
	kStreamGet,
	kStreamList
};

@interface PutController  : NSObject {
	   
	UITextField *gameName; 
	NSString *currentGameFileName; 
	UIView *_renderView; 
	
	// Create directory 
	NSOutputStream *            _createDirNetworkStream;
	// Put
	NSOutputStream *            _putNetworkStream;
	NSInputStream *             _putFileStream;
	NSString *					_putFileName; 	
	NSString *					userName; 
	uint8_t                     _buffer[kPutBufferSize];
    size_t                      _bufferOffset;
    size_t                      _bufferLimit;
	short						streamKind; 
}

@property (nonatomic, retain)   NSInputStream *   putFileStream;
@property (nonatomic, retain)   NSOutputStream *   putNetworkStream;
@property (nonatomic, retain)   NSString * putFileName; 

@property (nonatomic, retain)   NSOutputStream *   createDirNetworkStream;


@property (nonatomic, readonly) uint8_t *         buffer;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;


- (void)startSend:(NSString *)filePath; 
- (void)startCreate : (NSString *)userNameInput;

- (NSURL *)smartURLForString:(NSString *)str; 

- (void)streamCreateDir:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode; 
- (void)streamPut:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode; 


- (void)_stopCreateWithStatus:(NSString *)statusString; 
- (void)_stopSendWithStatus:(NSString *)statusString; 

@end
