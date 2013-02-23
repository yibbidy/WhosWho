// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import "GetController.h"
#include <CFNetwork/CFNetwork.h>

//static NSString * kDefaultPutURLText =  @"ftp://Hongbing%20Carter:hsc10266@localhost";//@"ftp://Shirley:Carter@yibbidy.no-ip.info/";//
static NSString * kDefaultGetURLText = @"Hongbing%20Carter:hsc10266@localhost";//@"Shirley:Carter@yibbidy.no-ip.info/";
static NSString *userName = @"Justin"; 




@implementation GetController

 


@synthesize connection    = _connection;

@synthesize getFileStream   = _getFileStream; 
@synthesize getNetworkStream = _getNetworkStream; 


@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

 

 // Because buffer is declared as an array, you have to use a custom getter.  
 // A synthesised getter doesn't compile.
 
 - (uint8_t *)buffer
{
	return self->_buffer;
}
 - (NSURL *)smartURLForString:(NSString *)str
{
	NSURL *     result;
	NSString *  trimmedStr;
	NSRange     schemeMarkerRange;
	NSString *  scheme;
	
	assert(str != nil);
	
	result = nil;
	
	trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
	if ( (trimmedStr != nil) && (trimmedStr.length != 0) ) {
		schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
		
		if (schemeMarkerRange.location == NSNotFound) {
			result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
		} else {
			scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
			assert(scheme != nil);
			
			if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
				result = [NSURL URLWithString:trimmedStr];
			} else {
				// It looks like this is some unsupported URL scheme.
			}
		}
	}
	
	return result;
}	 
 
 - (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
	NSString *  result;
	CFUUIDRef   uuid;
	CFStringRef uuidStr;
	
	uuid = CFUUIDCreate(NULL);
	assert(uuid != NULL);
	
	uuidStr = CFUUIDCreateString(NULL, uuid);
	assert(uuidStr != NULL);
	
	result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
	assert(result != nil);
	
	CFRelease(uuidStr);
	CFRelease(uuid);
	
	return result;
}
	 
- (void)startReceive :(NSString *)filePath
 // Starts a connection to download the current URL.
{
	BOOL                success;
	NSURL *             url;
	 NSURLRequest *      request;
	//NSString *filePath; 
	
	assert(self.getNetworkStream == nil);      // don't tap receive twice in a row!
	assert(self.getFileStream == nil);         // ditto
	//assert(self.filePath == nil);           // ditto
	
	// First get and check the URL.
	NSString *  currentURLText = kDefaultGetURLText;
	currentURLText = [currentURLText stringByAppendingPathComponent: userName]; 
	currentURLText = [currentURLText stringByAppendingPathComponent: @"tryftp.who"];
	
					  
	url = [self smartURLForString:currentURLText];
	success = (url != nil);
	
	// If the URL is bogus, let the user know.  Otherwise kick off the connection.
	
	if ( ! success) {
		//self.statusLabel.text = @"Invalid URL";
	} else {
		
		// Open a stream for the file we're going to receive into.
		
		//filePath = @"tryJustinftp2.who"; //[self pathForTemporaryFileWithPrefix:@"Get"];
		assert(filePath != nil);
		
		self.getFileStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
		assert(self.getFileStream  != nil);
		
		[self.getFileStream open];
		
		// Open a connection for the URL.
		
        request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
		
        // Tell the UI we're receiving.
		
		// Tell the UI we're receiving.
		
		//[self _receiveDidStart];
		
#if 0 
		NSString *documentsDirectory = [paths objectAtIndex:0];
		
		NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:@"WhoIsWho"]; 
		gameFolderPath = [gameFolderPath stringByAppendingPathComponent:gameFileName];
		gameFolderPath = [gameFolderPath stringByAppendingPathComponent:@"Data"];
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:gameFolderPath ]) {
			BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:gameFolderPath withIntermediateDirectories: YES attributes:nil error: nil];
			
			if ( !ret) {
				NSLog(@"Fail to create a new director for this game.");
				gameFolderPath = nil; 
			}
		}
		
		// First create a zip file in the folder: /whoiswho/game name/ as gameFileName.who
		gameFolderPath = [gameFolderPath stringByAppendingPathComponent:gameFileName];
		NSString *gameFileNameWithFullPath = [gameFolderPath  stringByAppendingPathExtension: kFileExtension]; 
		ZipArchive *zip = [[ZipArchive alloc] init];	
		[zip CreateZipFile2:gameFileNameWithFullPath];
#endif 
	}
}
	 	
	 
 - (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
 // A delegate method called by the NSURLConnection when the request/response 
 // exchange is complete.
 //
 // For an HTTP request you would check [response statusCode] and [response MIMEType] to 
 // verify that this is acceptable data, but for an FTP request there is no status code 
 // and the type value is derived from the extension so you might as well pre-flight that.
 //
 // You could, use this opportunity to get [response expectedContentLength] and 
 // [response suggestedFilename], but I don't need either of these values for 
 // this sample.
{
#pragma unused(theConnection)
#pragma unused(response)
	
	assert(theConnection == self.connection);
	assert(response != nil);
}
 
 - (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
 // A delegate method called by the NSURLConnection as data arrives.  We just 
 // write the data to the file.
{
#pragma unused(theConnection)
	NSInteger       dataLength;
	const uint8_t * dataBytes;
	NSInteger       bytesWritten;
	NSInteger       bytesWrittenSoFar;
	
	assert(theConnection == self.connection);
	
	dataLength = [data length];
	dataBytes  = [data bytes];
	
	bytesWrittenSoFar = 0;
	do {
		bytesWritten = [self.getFileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
		assert(bytesWritten != 0);
		if (bytesWritten == -1) {
			[self _stopReceiveWithStatus:@"File write error"];
			break;
		} else {
			bytesWrittenSoFar += bytesWritten;
		}
	} while (bytesWrittenSoFar != dataLength);
}
 
 - (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
 // A delegate method called by the NSURLConnection if the connection fails. 
 // We shut down the connection and display the failure.  Production quality code 
 // would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma unused(error)
	assert(theConnection == self.connection);
	
	[self _stopReceiveWithStatus:@"Connection failed"];
}
 
 - (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
 // A delegate method called by the NSURLConnection when the connection has been 
 // done successfully.  We shut down the connection with a nil status, which 
 // causes the image to be displayed.
{
#pragma unused(theConnection)
	assert(theConnection == self.connection);
	
	[self _stopReceiveWithStatus:nil];
}
	 	 
 - (void)_stopReceiveWithStatus:(NSString *)statusString
 // Shuts down the connection and displays the result (statusString == nil) 
 // or the error status (otherwise).
{
	if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.getFileStream != nil) {
        [self.getFileStream close];
        self.getFileStream = nil;
    }
    //[self _receiveDidStopWithStatus:statusString];
    //self.filePath = nil;
}



@end
