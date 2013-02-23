//
//  glUtilities.cpp
//  WhoIsWho
//
//  Created by Hongbing  Carter on 3/15/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

static const char *NSStringToCString( const NSString *thisNSString)
{
	
	const char *cString = [thisNSString cStringUsingEncoding: NSUTF8StringEncoding ]; 
	return cString; 
}
static string NSStringToString(NSString *thisNSString)
{
	
	const char *cString = [thisNSString cStringUsingEncoding: NSUTF8StringEncoding ]; 
	string thisString(cString);
	
	return thisString; 
	
}