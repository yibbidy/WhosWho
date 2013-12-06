// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import <UIKit/UIKit.h>
enum {
    kGetBufferSize = 32768
};

@interface GetController  : NSObject{
	
	UIView *renderView; 
	NSURLConnection *_connection; 
	
	
	// Get
	NSInputStream *             getNetworkStream;
    NSOutputStream *            getFileStream;

	uint8_t                     _buffer[kGetBufferSize];
    size_t                      _bufferOffset;
    size_t                      _bufferLimit;
	short						streamKind; 
	
}
	
@property (nonatomic, retain)   NSURLConnection *connection;

@property (nonatomic, retain)   NSOutputStream*   getFileStream;
@property (nonatomic, retain)   NSInputStream*   getNetworkStream;

@property (nonatomic, readonly) uint8_t *         buffer;
@property (nonatomic, assign)   size_t            bufferOffset;
@property (nonatomic, assign)   size_t            bufferLimit;

- (void)startReceive:(NSString *)filePath; 
- (void)_stopReceiveWithStatus:(NSString *)statusString;

- (NSURL *)smartURLForString:(NSString *)str; 

@end
