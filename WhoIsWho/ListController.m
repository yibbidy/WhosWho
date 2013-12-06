// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#import "ListController.h"
#include <CFNetwork/CFNetwork.h>

static NSString * kDefaultURLText =  @"ftp://Hongbing%20Carter:hsc10266@localhost";//@"ftp://Shirley:Carter@yibbidy.no-ip.info/";//


@implementation ListController

@synthesize popoverController; 

@synthesize listNetworkStream = _listNetworkStream; 

@synthesize bufferOffset  = _bufferOffset;
@synthesize bufferLimit   = _bufferLimit;

@synthesize listData        = _listData;
@synthesize listEntries     = _listEntries;
@synthesize listGameNames   = _listGameNames; 
@synthesize renderView = renderView; 

// Implement loadView to create a view hierarchy programmatically, without using a nib.

 // Because buffer is declared as an array, you have to use a custom getter.  
 // A synthesised getter doesn't compile.
 
 - (uint8_t *)buffer
{
	return self->_buffer;
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (id)init 
{
	
	if (self.listEntries == nil) {
        self.listEntries = [NSMutableArray array];
        assert(self.listEntries != nil);
    }
	
	if ( self.listGameNames == nil) {
		self.listGameNames = [NSMutableArray array]; 
		assert(self.listGameNames != nil); 
	}
	
	
	return self; 
	
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
 
 - (void)startList
 // Starts a connection to list all the files on the server 
{
	BOOL                success;
	NSURL *             url;
	CFReadStreamRef     ftpStream;
	
	assert(self.listNetworkStream == nil);      // don't tap receive twice in a row!
	
	// First get and check the URL.
	NSString *  currentURLText = kDefaultURLText;
	url = [self smartURLForString:currentURLText];
	success = (url != nil);
	
	// If the URL is bogus, let the user know.  Otherwise kick off the connection.
	
	if ( ! success) {
		//[self updateStatus:@"Invalid URL"];
		NSLog(@"Invalid URL"); 
	} else {
		
		// Create the mutable data into which we will receive the listing.
		
		self.listData = [NSMutableData data];
		
		assert(self.listData != nil);
		
		// Open a CFFTPStream for the URL.
		
		ftpStream = CFReadStreamCreateWithFTPURL(NULL, (__bridge  CFURLRef) url);
		assert(ftpStream != NULL);
		
		self.listNetworkStream = (__bridge NSInputStream *) ftpStream;
		
		self.listNetworkStream.delegate = self;
		[self.listNetworkStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		[self.listNetworkStream open];
		
		// Have to release ftpStream to balance out the create.  self.networkStream 
		// has retained this for our persistent use.
		
		CFRelease(ftpStream);
		
		// Tell the UI we're receiving.
		
		 [self.listEntries removeAllObjects];
	}
}

	 
 - (NSDictionary *)_entryByReencodingNameInEntry:(NSDictionary *)entry encoding:(NSStringEncoding)newEncoding
 // CFFTPCreateParsedResourceListing always interprets the file name as MacRoman, 
 // which is clearly bogus <rdar://problem/7420589>.  This code attempts to fix 
 // that by converting the Unicode name back to MacRoman (to get the original bytes; 
 // this works because there's a lossless round trip between MacRoman and Unicode) 
 // and then reconverting those bytes to Unicode using the encoding provided. 
{
	NSDictionary *  result;
	NSString *      name;
	NSData *        nameData;
	NSString *      newName;
	
	newName = nil;
	
	// Try to get the name, convert it back to MacRoman, and then reconvert it 
	// with the preferred encoding.
	
	name = [entry objectForKey:(id) kCFFTPResourceName];
	if (name != nil) {
		assert([name isKindOfClass:[NSString class]]);
		
		nameData = [name dataUsingEncoding:NSMacOSRomanStringEncoding];
		if (nameData != nil) {
			newName = [[NSString alloc] initWithData:nameData encoding:newEncoding];
		}
	}
	
	// If the above failed, just return the entry unmodified.  If it succeeded, 
	// make a copy of the entry and replace the name with the new name that we 
	// calculated.
	
	if (newName == nil) {
		assert(NO);                 // in the debug builds, if this fails, we should investigate why
		result = (NSDictionary *) entry;
	} else {
		NSMutableDictionary *   newEntry;
		
		newEntry = [entry mutableCopy] ;
		assert(newEntry != nil);
		
		[newEntry setObject:newName forKey:(id) kCFFTPResourceName];
		
		result = newEntry;
	}
	
	return result;
}
	 
 - (void)_addListEntries:(NSArray *)newEntries
{
	assert(self.listEntries != nil);
	
	[self.listEntries addObjectsFromArray:newEntries];
	//[self.tableView reloadData];
}
 - (void)parseListData
{
	NSMutableArray *    newEntries;
	NSUInteger          offset;
	
	// We accumulate the new entries into an array to avoid a) adding items to the 
	// table one-by-one, and b) repeatedly shuffling the listData buffer around.
	
	newEntries = [NSMutableArray array];
	assert(newEntries != nil);
	
	offset = 0;
	do {
		CFIndex         bytesConsumed;
		CFDictionaryRef thisEntry;
		
		thisEntry = NULL;
		
		assert(offset <= self.listData.length);
		bytesConsumed = CFFTPCreateParsedResourceListing(NULL, &((const uint8_t *) self.listData.bytes)[offset], self.listData.length - offset, &thisEntry);
		if (bytesConsumed > 0) {
			
			// It is possible for CFFTPCreateParsedResourceListing to return a 
			// positive number but not create a parse dictionary.  For example, 
			// if the end of the listing text contains stuff that can't be parsed, 
			// CFFTPCreateParsedResourceListing returns a positive number (to tell 
			// the caller that it has consumed the data), but doesn't create a parse 
			// dictionary (because it couldn't make sense of the data).  So, it's 
			// important that we check for NULL.
			
			if (thisEntry != NULL) {
				NSDictionary *  entryToAdd;
				
				// Try to interpret the name as UTF-8, which makes things work properly 
				// with many UNIX-like systems, including the Mac OS X built-in FTP 
				// server.  If you have some idea what type of text your target system 
				// is going to return, you could tweak this encoding.  For example, 
				// if you know that the target system is running Windows, then 
				// NSWindowsCP1252StringEncoding would be a good choice here.
				// 
				// Alternatively you could let the user choose the encoding up 
				// front, or reencode the listing after they've seen it and decided 
				// it's wrong.
				//
				// Ain't FTP a wonderful protocol!
				
				entryToAdd = [self _entryByReencodingNameInEntry:(__bridge NSDictionary *) thisEntry encoding:NSUTF8StringEncoding];
				
				[newEntries addObject:entryToAdd];
			}
			
			// We consume the bytes regardless of whether we get an entry.
			
			offset += bytesConsumed;
		}
		
		if (thisEntry != NULL) {
			CFRelease(thisEntry);
		}
		
		if (bytesConsumed == 0) {
			// We haven't yet got enough data to parse an entry.  Wait for more data 
			// to arrive.
			break;
		} else if (bytesConsumed < 0) {
			// We totally failed to parse the listing.  Fail.
			//[self _stopReceiveWithStatus:@"Listing parse failed"];
			break;
		}
	} while (YES);
	
	if (newEntries.count != 0) {
		[self _addListEntries:newEntries];
	}
	if (offset != 0) {
		[self.listData replaceBytesInRange:NSMakeRange(0, offset) withBytes:NULL length:0];
	}
}
	 
- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
	#pragma unused(aStream)
    assert(aStream == self.listNetworkStream);
	
    switch (eventCode) {
        case NSStreamEventOpenCompleted: {
           // [self updateStatus:@"Opened connection"];
        } break;
        case NSStreamEventHasBytesAvailable: {
            NSInteger       bytesRead;
            uint8_t         buffer[32768];
			
            //[self updateStatus:@"Receiving"];
            
            // Pull some data off the network.
            
            bytesRead = [self.listNetworkStream read:buffer maxLength:sizeof(buffer)];
            if (bytesRead == -1) {
                [self _stopListWithStatus:@"Network read error"];
            } else if (bytesRead == 0) {
                [self _stopListWithStatus:nil];
            } else {
                assert(self.listData != nil);
                
                // Append the data to our listing buffer.
                
                [self.listData appendBytes:buffer length:bytesRead];
                
                // Check the listing buffer for any complete entries and update 
                // the UI if we find any.
                
                [self parseListData];
            }
        } break;
        case NSStreamEventHasSpaceAvailable: {
            assert(NO);     // should never happen for the output stream
        } break;
        case NSStreamEventErrorOccurred: {
            [self _stopListWithStatus:@"Stream open error"];
        } break;
        case NSStreamEventEndEncountered: {
            // ignore
        } break;
        default: {
            assert(NO);
        } break;
    }
}

 - (void)_stopListWithStatus:(NSString *)statusString
 // Shuts down the connection and displays the result (statusString == nil) 
 // or the error status (otherwise).
{
	if (self.listNetworkStream != nil) {
		[self.listNetworkStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
		self.listNetworkStream.delegate = nil;
		[self.listNetworkStream close];
		self.listNetworkStream = nil;
	}
	//[self receiveDidStopWithStatus:statusString];
	self.listData = nil;
	
	// now get list of game names from listEntries; 
	
	[self getListOfGameNames]; 
	
	//[(AppView *)self.renderView displayAllRemoteGameNames]; 
}
- (void) getListOfGameNames
{
	NSDictionary *      listEntry = nil; 
	NSString *name; 
	
	for ( int i = 0; i< [self.listEntries count]; i++) {
	
		listEntry = [self.listEntries objectAtIndex:i]; 
		assert([listEntry isKindOfClass:[NSDictionary class]]);
		name = [listEntry objectForKey:(id) kCFFTPResourceName];
        if ( [[name pathExtension] caseInsensitiveCompare:@"who"] == NSOrderedSame) 
            [self.listGameNames addObject:name]; 
	}

}



- (void)dealloc {
   
}


@end
