// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import "PutController.h"
#include <CFNetwork/CFNetwork.h>

//static NSString * kDefaultPutURLText =  @"ftp://localhost";//@"ftp://Shirley:Carter@yibbidy.no-ip.info/";//
//static NSString *userName = @"Justin"; 

//static NSString * kDefaultPutURLText =  @"ftp://Hongbing%20Carter:hsc10266@localhost";//@"ftp://Shirley:Carter@yibbidy.no-ip.info/";//
static NSString * kDefaultPutURLText = @"Hongbing%20Carter:hsc10266@localhost";//@"Shirley:Carter@yibbidy.no-ip.info/";

@implementation PutController

@synthesize putFileStream   = _putFileStream; 
@synthesize putNetworkStream = _putNetworkStream; 
@synthesize putFileName = _putFileName; 
@synthesize createDirNetworkStream = _createDirNetworkStream; 
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
- (void)startSend:(NSString *)filePath
{
	
	BOOL                    success;
	NSURL *                 url;
	CFWriteStreamRef        ftpStream;
	
	streamKind = kStreamGet; 
	
	assert(filePath != nil);
	assert([[NSFileManager defaultManager] fileExistsAtPath:filePath]);
	
	assert(self.putNetworkStream == nil);      // don't tap send twice in a row!
	streamKind = kStreamPut; 
	
	NSString *ext =  [userName stringByAppendingPathComponent: [filePath lastPathComponent]]; 
	
	// First get and check the URL.
	NSString *  currentURLText = kDefaultPutURLText;
	url = [self smartURLForString:currentURLText];
	success = (url != nil);
	
	if (success) {
		// Add the last the file name to the end of the URL to form the final 
		// URL that we're going to PUT to.
		url  = (__bridge NSURL *) CFURLCreateCopyAppendingPathComponent (NULL,  (__bridge CFURLRef)url, (__bridge CFStringRef) ext, false); 

		success = (url != nil);
	}
	
	// If the URL is bogus, let the user know.  Otherwise kick off the connection.
	
	if ( ! success) {
		//self.statusLabel.text = @"Invalid URL";
	} else {
		
		// Open a stream for the file we're going to send.  We do not open this stream; 
		// NSURLConnection will do it for us.
		//	
		
		self.putFileStream = [NSInputStream inputStreamWithFileAtPath:filePath];
		assert(self.putFileStream != nil);
		
		[self.putFileStream open];
		
		// Open a CFFTPStream for the URL.
		
		ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
		
		assert(ftpStream != NULL);
		
		self.putNetworkStream = (__bridge NSOutputStream *) ftpStream;
		
		//   if (self._usernameText.text.length != 0) {
#pragma unused (success) //Adding this to appease the static analyzer.
		success = [self.putNetworkStream setProperty:@"Hongbing Carter" forKey:(id)kCFStreamPropertyFTPUserName];
		assert(success);
		success = [self.putNetworkStream setProperty:@"hsc10266" forKey:(id)kCFStreamPropertyFTPPassword];
		assert(success);
		// }
		
		self.putNetworkStream.delegate = self;
		[self.putNetworkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[self.putNetworkStream open];
		
		// Have to release ftpStream to balance out the create.  self.networkStream 
		// has retained this for our persistent use.
		
		CFRelease(ftpStream);
		
		// Tell the UI we're sending.
		
		// [self _sendDidStart];
	}
}
- (void)startCreate : (NSString *)userNameInput
{
	BOOL                    success;
	NSURL *                 url;
	CFWriteStreamRef        ftpStream;
	
	
	//assert( [filePath.pathExtension isEqual:@"png"] || [filePath.pathExtension isEqual:@"jpg"] );
	assert(self.createDirNetworkStream == nil);      // don't tap send twice in a row!

	userName = userNameInput;
	streamKind = kStreamCreateDir; 
	NSString *dirName = userName; 
	
	// First get and check the URL.
	NSString *  currentURLText = kDefaultPutURLText;
	url = [self smartURLForString:currentURLText];
	success = (url != nil);
	
	if (success) {
		// Add the last the file name to the end of the URL to form the final 
		// URL that we're going to PUT to.
		
		url =  (__bridge NSURL *)CFURLCreateCopyAppendingPathComponent(NULL, (__bridge CFURLRef) url, (__bridge CFStringRef) dirName, true);
		success = (url != nil);
	}
	
    
	// If the URL is bogus, let the user know.  Otherwise kick off the connection.
	if ( ! success) {
		//self.statusLabel.text = @"Invalid URL";
	} else {
		
			
		// Open a CFFTPStream for the URL.
		
        ftpStream = CFWriteStreamCreateWithFTPURL(NULL, (__bridge CFURLRef) url);
        
		assert(ftpStream != NULL);
        
        self.createDirNetworkStream = (__bridge NSOutputStream *) ftpStream;
		
     //   if (self._usernameText.text.length != 0) {
			#pragma unused (success) //Adding this to appease the static analyzer.
            success = [self.createDirNetworkStream setProperty:@"Hongbing Carter" forKey:(id)kCFStreamPropertyFTPUserName];
            assert(success);
            success = [self.createDirNetworkStream setProperty:@"hsc10266" forKey:(id)kCFStreamPropertyFTPPassword];
            assert(success);
       // }
		
        self.createDirNetworkStream.delegate = self;
        [self.createDirNetworkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        [self.createDirNetworkStream open];
		
        // Have to release ftpStream to balance out the create.  self.networkStream 
        // has retained this for our persistent use.
        
        CFRelease(ftpStream);
		
        // Tell the UI we're sending.
        
       // [self _sendDidStart];
	}
}
	 
 - (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
 // An NSStream delegate callback that's called when events happen on our 
 // network stream.
{
	
	if ( streamKind == kStreamCreateDir )
		[self streamCreateDir:aStream handleEvent:eventCode]; 
	else if ( streamKind == kStreamPut )
		[self streamPut:aStream handleEvent:eventCode];
}	
- (void)streamCreateDir:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
// An NSStream delegate callback that's called when events happen on our 
// network stream.
{
#pragma unused(aStream)
    assert(aStream == self.createDirNetworkStream);
	
	streamKind = kStreamCreateDir; 
	int nn = 100; 
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
           // [self _updateStatus:@"Opened connection"];
            // Despite what it says in the documentation <rdar://problem/7163693>, 
            // you should wait for the NSStreamEventEndEncountered event to see 
            // if the directory was created successfully.  If you shut the stream 
            // down now, you miss any errors coming back from the server in response 
            // to the MKD command.
            //
           // [self _stopCreateWithStatus:nil];
			nn = 0; 
        } break;
        case NSStreamEventHasBytesAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);
        } break;
        case NSStreamEventErrorOccurred: {
            CFStreamError   err;
            
            // -streamError does not return a useful error domain value, so we 
            // get the old school CFStreamError and check it.
            
            err = CFWriteStreamGetError( (__bridge CFWriteStreamRef) self.createDirNetworkStream );
            if (err.domain == kCFStreamErrorDomainFTP) {
               [self _stopCreateWithStatus:[NSString stringWithFormat:@"FTP error %d", (int) err.error]];
				nn = 200;
			} else {
                [self _stopCreateWithStatus:@"Stream open error"];
				nn = 300; 
            }
        } break;
        case NSStreamEventEndEncountered: {
            [self _stopCreateWithStatus:nil];
			nn = 500; 
        } break;
        default: {
            assert(NO);
        } break;
    }
	
}
	 
 - (void)streamPut:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
 // An NSStream delegate callback that's called when events happen on our 
 // network stream.
{
	streamKind = kStreamPut; 
	
#pragma unused(aStream)
	assert(aStream == self.putNetworkStream);
	int nn = 100; 
	switch (eventCode) {
		case NSStreamEventOpenCompleted: {
			//[self _updateStatus:@"Opened connection"];
			nn = 0; 
		} break;
		case NSStreamEventHasBytesAvailable: {
			assert(NO);     // should never happen for the output stream
		} break;
		case NSStreamEventHasSpaceAvailable: {
			//[self _updateStatus:@"Sending"];
			
			// If we don't have any data buffered, go read the next chunk of data.
			
			if (self.bufferOffset == self.bufferLimit) {
				NSInteger   bytesRead;
				
				bytesRead = [self.putFileStream read:self.buffer maxLength:kPutBufferSize];
				
				if (bytesRead == -1) {
					[self _stopSendWithStatus:@"File read error"];
				} else if (bytesRead == 0) {
					[self _stopSendWithStatus:nil];
				} else {
					self.bufferOffset = 0;
					self.bufferLimit  = bytesRead;
				}
			}
			
			// If we're not out of data completely, send the next chunk.
			
			if (self.bufferOffset != self.bufferLimit) {
				NSInteger   bytesWritten;
				bytesWritten = [self.putNetworkStream write:&self.buffer[self.bufferOffset] maxLength:self.bufferLimit - self.bufferOffset];
				assert(bytesWritten != 0);
				if (bytesWritten == -1) {
					[self _stopSendWithStatus:@"Network write error"];
				} else {
					self.bufferOffset += bytesWritten;
				}
			}
		} break;
		case NSStreamEventErrorOccurred: {
			[self _stopSendWithStatus:@"Stream open error"];
			nn = 200; 
		} break;
		case NSStreamEventEndEncountered: {
			// ignore
		} break;
		default: {
			assert(NO);
		} break;
	}
}
	 
 - (void)_stopSendWithStatus:(NSString *)statusString
{
	if (streamKind == kStreamPut ) {
		if (self.putFileStream != nil) {
			[self.putFileStream close];
			self.putFileStream = nil;
		} 
	}
	
	//[self _sendDidStopWithStatus:statusString];
}
	 
 - (void)_stopCreateWithStatus:(NSString *)statusString
{
	if (self.createDirNetworkStream != nil) {
		[self.createDirNetworkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		self.createDirNetworkStream.delegate = nil;
		[self.createDirNetworkStream close];
		self.createDirNetworkStream = nil;
	}
	//[self _createDidStopWithStatus:statusString];
	
	// Now finished creating folder, back to putting file 
	[ self startSend: self.putFileName]; 
}

@end
