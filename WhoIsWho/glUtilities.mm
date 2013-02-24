// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#include "glUtilities.h"


const char *NSStringToCString( const NSString *thisNSString)
{
	
	const char *cString = [thisNSString cStringUsingEncoding: NSUTF8StringEncoding ]; 
	return cString; 
}
std::string NSStringToString(NSString *thisNSString)
{
	
	const char *cString = [thisNSString cStringUsingEncoding: NSUTF8StringEncoding ]; 
    std::string thisString(cString);
	
	return thisString; 
	
}
NSString *StringToNSString(std::string aString)
{
    
    NSString *aNSString = [NSString stringWithUTF8String: aString.c_str()];
    return aNSString;
}


/**************************************************************************************************/


GLuint GL_CreateOpenGLTexture(const void *data, Texture2DPixelFormat pixelFormat, NSUInteger width,  NSUInteger height)
{
	GLuint texObj = 0; 
    
	glGenTextures(1, &texObj);
	//glGetIntegerv(GL_TEXTURE_BINDING_2D, &saveName);
	glBindTexture(GL_TEXTURE_2D, texObj);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	//glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE); 
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  //  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	//unsigned char *temp = (unsigned char *)data; 
	
	//int x = 193; 
	//int y = 463; 
	//unsigned char * bits = &temp[y*4*256 + x*4];
	
	switch(pixelFormat) {
			
		case kTexture2DPixelFormat_RGBA8888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
			break;
			
		case kTexture2DPixelFormat_RGBA4444:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_4_4_4_4, data);
			break;
			
		case kTexture2DPixelFormat_RGBA5551:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_SHORT_5_5_5_1, data);
			break;
			
		case kTexture2DPixelFormat_RGB565:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_SHORT_5_6_5, data);
			break;
			
		case kTexture2DPixelFormat_RGB888:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
			break;
			
		case kTexture2DPixelFormat_L8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, width, height, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, data);
			break;
			
		case kTexture2DPixelFormat_A8:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, width, height, 0, GL_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
			
		case kTexture2DPixelFormat_LA88:
			glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE_ALPHA, width, height, 0, GL_LUMINANCE_ALPHA, GL_UNSIGNED_BYTE, data);
			break;
			
		case kTexture2DPixelFormat_RGB_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, data);
			break;
			
		case kTexture2DPixelFormat_RGB_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGB_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, data);
			break;
			
		case kTexture2DPixelFormat_RGBA_PVRTC2:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG, width, height, 0, (width * height) / 4, data);
			break;
			
		case kTexture2DPixelFormat_RGBA_PVRTC4:
			glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG, width, height, 0, (width * height) / 2, data);
			break;
			
		default:
			[NSException raise:NSInternalInconsistencyException format:@""];
            
	}
    
	return texObj;
    
}

static void debugCheckImagePixels (unsigned char *imagePixels, int imageWidth, int imageHeight)
{
#if 0 
	int count1 = 0; 
	int count2 = 0; 
	int count3 = 0; 
	for ( int i = 0; i < imageWidth * imageHeight; i++) {
		
		
		if ( imagePixels[i*4+3] == 0 ) {
			
			unsigned char r = imagePixels[i*4+0]; 
			unsigned char g = imagePixels[i*4+1];
			unsigned char b = imagePixels[i*4+2];
			unsigned char a = imagePixels[i*4+3];
			
			
		//	imagePixels[i*4+0]	= 255; //255; //alpha *imagePixels[i*4+0]   + (1.0 - alpha)*bkgColorR; 
		//	imagePixels[i*4+1]  = 0; //alpha *imagePixels[i*4+1] + (1.0 - alpha)*bkgColorG; 
		///	imagePixels[i*4+2]  = 255; //alpha *imagePixels[i*4+2] + (1.0 - alpha)*bkgColorB; 
			//imagePixels[i*4+3]  = bkgColorA; // alpha *imagePixels[i*4+3] + (1.0 - alpha)*bkgColorA; 
			count1++; 
		}
		else if (imagePixels[i*4+3] == 255) {
			unsigned char r = imagePixels[i*4+0]; 
			unsigned char g = imagePixels[i*4+1];
			unsigned char b = imagePixels[i*4+2];
			unsigned char a = imagePixels[i*4+3];
			
			
            imagePixels[i*4+0]	= 255; //alpha *imagePixels[i*4+0]   + (1.0 - alpha)*bkgColorR; 
            imagePixels[i*4+1]  = 0; //alpha *imagePixels[i*4+1] + (1.0 - alpha)*bkgColorG; 
            imagePixels[i*4+2]  = 255; //alpha *imagePixels[i*4+2] + (1.0 - alpha)*bkgColorB; 
			
			count2++; 
		}
		else {
			unsigned char r = imagePixels[i*4+0]; 
			unsigned char g = imagePixels[i*4+1];
			unsigned char b = imagePixels[i*4+2];
			unsigned char a = imagePixels[i*4+3];
			
		//	imagePixels[i*4+0]	= 255;// bkgColorR; //alpha *imagePixels[i*4+0]   + (1.0 - alpha)*bkgColorR; 
		//	imagePixels[i*4+1]  = 0; //bkgColorG; //alpha *imagePixels[i*4+1] + (1.0 - alpha)*bkgColorG; 
		//	imagePixels[i*4+2]  = 0;// bkgColorB; //alpha *imagePixels[i*4+2] + (1.0 - alpha)*bkgColorB; 
		//	imagePixels[i*4+3]  = 255; //bkgColorA; // alpha *imagePixels[i*4+3] + (1.0 - alpha)*bkgColorA;
			count3 ++; 
		}
		
	}
#endif 
}

 GLuint GL_ConvertUIImageToOpenGLTexture(const UIImage *uiImage, int &imageWidth, int &imageHeight, int &width, int &height, unsigned char *&imageData)
{
    
	NSUInteger i; 
    
	CGImageRef newImage; 
	CGImageAlphaInfo info; 
	BOOL hasAlpha; 
	Texture2DPixelFormat pixelFormat; 
	GLuint texObj = 0; 
	//void *imageData = nil; 
	CGContextRef imageContext; 
	CGColorSpaceRef            colorSpace;
	unsigned char*                      tempData;
	unsigned int*              inPixel32;
	unsigned short*            outPixel16;
	BOOL                       sizeToFit = NO;
	CGAffineTransform               transform;
	unsigned char*			inPixel8;
	
	unsigned char*			outPixel8;
    
	
	int bitDepth;
	int bitsPerComponent;
	
	
	GLint MAX_TEX_SIZE; 
	// Get maximum texture size for this specific OpenGL implementation
	glGetIntegerv(GL_MAX_TEXTURE_SIZE, &MAX_TEX_SIZE); 
    
	// Get CGImage off uiImage
	newImage = uiImage.CGImage;
	// Get the width and height of the image
	imageWidth = CGImageGetWidth(newImage);
	imageHeight = CGImageGetHeight(newImage);
	
	// Get power of 2 for OpenGL texture dimensions 
	width  = imageWidth; 
	height = imageHeight; 
#if 1 
	if((width != 1) && (width & (width - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < width)
			i *= 2;
		width = i;
	}
	height = imageHeight;
	if((height != 1) && (height & (height - 1))) {
		i = 1;
		while((sizeToFit ? 2 * i : i) < height)
			i *= 2;
		height = i;
	}
	while((width > MAX_TEX_SIZE) || (height > MAX_TEX_SIZE)) {
		width /= 2;
		height /= 2;
		transform = CGAffineTransformScale(transform, 0.5, 0.5);
		imageWidth *= 0.5;
		imageHeight *= 0.5;
	}
#endif 
	if ( newImage){
		
		info = CGImageGetAlphaInfo(newImage);
		hasAlpha = ((info == kCGImageAlphaPremultipliedLast) || (info == kCGImageAlphaPremultipliedFirst) || (info == kCGImageAlphaLast) || (info == kCGImageAlphaFirst) ? YES : NO);
		
		bitDepth = CGImageGetBitsPerPixel(newImage); 
		bitsPerComponent = CGImageGetBitsPerComponent(newImage); 
		///////// Get pixel format
		if(CGImageGetColorSpace(newImage)) {
			if(CGColorSpaceGetModel(CGImageGetColorSpace(newImage)) == kCGColorSpaceModelMonochrome) {
				if(hasAlpha) {
					pixelFormat = kTexture2DPixelFormat_LA88;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(newImage) != 8) && (CGImageGetBitsPerPixel(newImage) != 16))
						REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
				}
				else {
					pixelFormat = kTexture2DPixelFormat_L8;
#if __DEBUG__
					if((CGImageGetBitsPerComponent(newImage) != 8) && (CGImageGetBitsPerPixel(newImage) != 8))
						REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
				}
			}
			else {
				if((CGImageGetBitsPerPixel(newImage) == 16) && !hasAlpha)
					pixelFormat = kTexture2DPixelFormat_RGBA5551;
				else {
					if(hasAlpha)
						pixelFormat = kTexture2DPixelFormat_RGBA8888;
					else {
						pixelFormat = kTexture2DPixelFormat_RGBA8888;
#if __DEBUG__
						if((CGImageGetBitsPerComponent(newImage) != 8) && (CGImageGetBitsPerPixel(newImage) != 24))
							REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%s\"", path);
#endif
					}
				}
			}		
		}
		else { //NOTE: No colorspace means a mask image
			pixelFormat = kTexture2DPixelFormat_A8;
#if __DEBUG__
			if((CGImageGetBitsPerComponent(newImage) != 8) && (CGImageGetBitsPerPixel(newImage) != 8))
				REPORT_ERROR(@"Unoptimal image pixel format for image at path \"%@\"", path);
#endif
		}
        
        
		
        
		
		
        //////
        //	colorSpace = CGColorSpaceCreateDeviceRGB();
        //	imageData = (unsigned char *)malloc(height * width * 4 *sizeof(unsigned char));
        //	imageContext = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
        //	CGColorSpaceRelease(colorSpace);
        
		switch(pixelFormat) {
				
			case kTexture2DPixelFormat_RGBA8888:
			case kTexture2DPixelFormat_RGBA4444:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				imageData = (unsigned char *)malloc(height * width * 4);
				imageContext = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
				CGColorSpaceRelease(colorSpace);
				break; 
				
			case kTexture2DPixelFormat_RGBA5551:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				imageData = (unsigned char *)malloc(height * width * 2);
				imageContext = CGBitmapContextCreate(imageData, width, height, 5, 2 * width, colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
				CGColorSpaceRelease(colorSpace);
				break;
				
			case kTexture2DPixelFormat_RGB888:
			case kTexture2DPixelFormat_RGB565:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				imageData = (unsigned char *)malloc(height * width * 4);
				imageContext = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
				CGColorSpaceRelease(colorSpace);
				break;
				
			case kTexture2DPixelFormat_L8:
				colorSpace = CGColorSpaceCreateDeviceGray();
				imageData = (unsigned char *)malloc(height * width);
				imageContext = CGBitmapContextCreate(imageData, width, height, 8, width, colorSpace, kCGImageAlphaNone);
				CGColorSpaceRelease(colorSpace);
				break;
				
			case kTexture2DPixelFormat_A8:
				imageData = (unsigned char *)malloc(height * width);
				imageContext = CGBitmapContextCreate(imageData, width, height, 8, width, NULL, kCGImageAlphaOnly);
				break;
				
			case kTexture2DPixelFormat_LA88:
				colorSpace = CGColorSpaceCreateDeviceRGB();
				imageData = (unsigned char *)malloc(height * width * 4);
				imageContext = CGBitmapContextCreate(imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
				CGColorSpaceRelease(colorSpace);
				break;
				
			default:
				[NSException raise:NSInternalInconsistencyException format:@"Invalid pixel format"];
				
		}
        
		if(imageContext == NULL) {
			NSLog(@"Failed creating CGBitmapContext", NULL);
			free(imageData);
			return 0; 
		}
		
        
		// Allocate  memory needed for the bitmap context
        
		// Flip the Y-axis
		//CGContextTranslateCTM (imageContext, 0, height);
		//CGContextScaleCTM (imageContext, 1.0, -1.0);
		
		// Use  the bitmatp creation function provided by the Core Graphics framework. 
		CGContextClearRect( imageContext, CGRectMake( 0, 0, width, height ) );
		//CGContextTranslateCTM(imageContext, 0, height - imageHeight);
        
        //if(!CGAffineTransformIsIdentity(transform))
		//	CGContextConcatCTM(imageContext, transform);
		
		// After you create the context, you can draw the  image to the context.
		CGContextDrawImage(imageContext, CGRectMake(0, 0, width, height), newImage);
        
        
		//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
		if(pixelFormat == kTexture2DPixelFormat_RGBA5551) {
			outPixel16 = (unsigned short*)imageData;
			for(i = 0; i < width * height; ++i, ++outPixel16)
				*outPixel16 = *outPixel16 << 1 | 0x0001;
            
			NSLog(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551", NULL);
			
		}
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
		else if(pixelFormat == kTexture2DPixelFormat_RGB888) {
			tempData = (unsigned char *)malloc(height * width * 3);
			inPixel8 = (unsigned char*)imageData;
			outPixel8 = (unsigned char*)tempData;
			for(i = 0; i < width * height; ++i) {
				*outPixel8++ = *inPixel8++;
				*outPixel8++ = *inPixel8++;
				*outPixel8++ = *inPixel8++;
				inPixel8++;
			}
			free(imageData);
			imageData = tempData;
            
			NSLog(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888", NULL);
            
		}
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
		else if(pixelFormat == kTexture2DPixelFormat_RGB565) {
			tempData =(unsigned char *)malloc(height * width * 2);
			inPixel32 = (unsigned int*)imageData;
			outPixel16 = (unsigned short*)tempData;
			for(i = 0; i < width * height; ++i, ++inPixel32)
				*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) | ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) | ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
			free(imageData);
			imageData = tempData;
            
			NSLog(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565", NULL);
            
		}
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGBBBBAAAA"
		else if(pixelFormat == kTexture2DPixelFormat_RGBA4444) {
			tempData = (unsigned char *)malloc(height * width * 2);
			inPixel32 = (unsigned int*)imageData;
			outPixel16 = (unsigned short*)tempData;
			for(i = 0; i < width * height; ++i, ++inPixel32)
				*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 4) << 12) | ((((*inPixel32 >> 8) & 0xFF) >> 4) << 8) | ((((*inPixel32 >> 16) & 0xFF) >> 4) << 4) | ((((*inPixel32 >> 24) & 0xFF) >> 4) << 0);
			free(imageData);
			imageData = tempData;
            
			NSLog(@"Falling off fast-path converting pixel data from RGBA8888 to RGBA4444", NULL);
            
		}
		//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
		else if(pixelFormat == kTexture2DPixelFormat_LA88) {
			tempData = (unsigned char *)malloc(height * width * 2);
			inPixel8 = (unsigned char*)imageData;
			outPixel8 = (unsigned char*)tempData;
			for(i = 0; i < width * height; ++i) {
				*outPixel8++ = *inPixel8++;
				inPixel8 += 2;
				*outPixel8++ = *inPixel8++;
			}
			free(imageData);
			imageData = tempData;
            
			NSLog(@"Falling off fast-path converting pixel data from RGBA8888 to LA88", NULL);
            
		}
        
		// Finally, create OpenGL texture object 
		//debugCheckImagePixels(imageData,width, height); 
        
		texObj = GL_CreateOpenGLTexture( imageData, pixelFormat, width, height); 
		
        
		CGContextRelease(imageContext);
		//free(imageData);  
	}		
	return texObj; 
}

NSString *getGameDataFolderPath()
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	//NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:@"WhoIsWho"]; 
	//gameFolderPath = [gameFolderPath stringByAppendingPathComponent:@"Game1"];
	NSString *gameDataFolderPath = documentsDirectory;//[gameFolderPath stringByAppendingPathComponent:@"Data"];
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:gameDataFolderPath ]) {
		BOOL ret = [[NSFileManager defaultManager] createDirectoryAtPath:gameDataFolderPath withIntermediateDirectories: YES attributes:nil error: nil];
        
		if ( !ret) {
			NSLog(@"Fail to create a new director for this game.");
			gameDataFolderPath = nil; 
		}
	}
	
	
	return gameDataFolderPath; 
	
}


NSString *getGameDataFolderPath(NSString *thisGame)
{
	BOOL ret = NO; 
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *gameFolderPath = [documentsDirectory stringByAppendingPathComponent:@"WhoIsWho"]; 
	gameFolderPath = [gameFolderPath stringByAppendingPathComponent:thisGame];
	NSString *gameDataFolderPath = [gameFolderPath stringByAppendingPathComponent:@"Data"];
	
	
	if (![[NSFileManager defaultManager] fileExistsAtPath:gameDataFolderPath ]) {
		ret = [[NSFileManager defaultManager] createDirectoryAtPath:gameDataFolderPath withIntermediateDirectories: YES attributes:nil error: nil];
		
		if ( !ret) {
			NSLog(@"Fail to create a new director for this game.");
		}
	}
	
	
	return gameDataFolderPath; 
	
}
static const char *getGameFileName(std::string fileName)
{
	NSString *newFileName  = [NSString stringWithUTF8String: fileName.c_str()];	
	NSString *newFileNameWithNoExt = [newFileName stringByDeletingPathExtension]; 
	
	NSString *gameDataFolderPath = (NSString *)getGameDataFolderPath(newFileNameWithNoExt); 
	if ( gameDataFolderPath ) {
		
		newFileName = [ gameDataFolderPath stringByAppendingPathComponent: newFileName]; 
		
		const char *cString = NSStringToCString(newFileName); // [newFileName cStringUsingEncoding: NSUTF8StringEncoding ]; 
		
		return cString; 
	} 
	else 
		return nil; 
}
int GL_LoadTextureFromFile(const char * inFileName, ImageInfo & outImageInfo)
{
    int errorCode = 0;
    outImageInfo.texID = 0;
    
	// convert c stirng to NSString first 
	NSString *newFileName  = [NSString stringWithUTF8String: inFileName];	
	// Check whether it is in the resource, if it is, should be no problem creating UIImage of it 
	//=  [UIImage imageWithContentsOfFile:newFileName ];
	newFileName = [newFileName lastPathComponent]; 
	NSString *extension = [newFileName pathExtension]; 
	NSString *newFileNameWithNoExtension = [newFileName stringByDeletingPathExtension]; 
	
    UIImage *uiImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:newFileNameWithNoExtension ofType:extension]];
	
	if ( !uiImage ) {
		NSString *gameDataFolderPath = (NSString *)getGameDataFolderPath(); 	
		
		if (gameDataFolderPath) {
            
			newFileName = [ gameDataFolderPath stringByAppendingPathComponent: newFileName]; 
            
        	NSLog (newFileName); 
            uiImage =  [UIImage imageWithContentsOfFile:newFileName ];
            
            ///Test send function 
            //[viewController startSend:newFileName]; 
            
		}
	}
	
	if ( uiImage ) {
		
		// Turn off this call to copy some images into photos folder in iPhone simulator. 
		//UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil);
		
		// Create OpenGL texture from uiImage
		//float width = 0;
		//float height = 0;
		//int texWidth  = 0; 
		//int texHeight = 0; 
		
		//unsigned char * imageData = nil;
        outImageInfo.texID = GL_ConvertUIImageToOpenGLTexture(uiImage, outImageInfo.originalWidth, outImageInfo.originalHeight, 
                                                              outImageInfo.texWidth, outImageInfo.texHeight, outImageInfo.image); 
        memcpy(outImageInfo.originalFilename, inFileName, 256);
        //outImageInfo.width = outImageInfo.texWidth;
        //outImageInfo.height = outImageInfo.texHeight;
		outImageInfo.bitDepth = 32;
        outImageInfo.rowBytes = outImageInfo.bitDepth/8 * outImageInfo.texWidth;
		//outImageInfo = ImageInfo(width, height, 32, width*4, imageData);
        
		//outImageInfo.texWidth = texWidth; 
		//outImageInfo.texHeight = texHeight; 
	} else {
        errorCode = 1;
    }
	
    return errorCode;
}

static UIImage *drawText(NSString* text, UIImage* image, CGPoint point)
{
    
    UIFont *font = [UIFont boldSystemFontOfSize:12];
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x, point.y, image.size.width, image.size.height);
    [[UIColor brownColor] set];
    CGContextFillRect(UIGraphicsGetCurrentContext(),
                      CGRectMake(0, (image.size.height-[text sizeWithFont:font].height),
                                 image.size.width, image.size.height));
    
   // [[UIColor whiteColor] set];
    [text drawInRect:CGRectIntegral(rect) withFont:font];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}
int GL_LoadTextureFromText(std::string inText/*const NSString *text*/,ImageInfo & outImageInfo )
{
    int errorCode = 0;
    outImageInfo.texID = 0;

    NSString * text  = [NSString stringWithUTF8String: inText.c_str()];
    
	CGContextRef ctx; 
	CGColorSpaceRef            colorSpace;     
	
	NSString *fontName = @"Helvetica-Bold"; 
	int fontSize = 62;//22;    
	
	UIFont *font = [UIFont fontWithName:fontName size:fontSize];
	// Precalculate size of text and size of font so that text fits inside placard
	CGSize textSize = [text sizeWithFont:font] ; //forWidth:320 lineBreakMode:UILineBreakModeWordWrap];
	
	int width =  textSize.width+30; 
	int height = textSize.height+15;  
	
	/////
	// Draw text first 
	colorSpace = CGColorSpaceCreateDeviceRGB();  
	ctx = CGBitmapContextCreate(NULL, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast);
    
	CGContextSetRGBFillColor(ctx, 0.0, 1.0, 0.0, 0.0f);
    //CGContextSetAlpha(ctx, 0.5f);
	CGContextSelectFont(ctx, "Helvetica-Bold", fontSize, kCGEncodingMacRoman);
	//
	CGContextSetTextDrawingMode(ctx, kCGTextFill);
    CGRect rect; 
    rect.origin.x = 0; 
    rect.origin.y = 0; 
    rect.size = textSize; 
    
	CGContextClearRect(ctx,  CGContextGetPathBoundingBox(ctx)); 
	CGContextSetRGBFillColor(ctx, 0, 0, 0, 1); // red text 
	CGContextStrokePath(ctx);
    CGContextSetBlendMode(ctx, kCGBlendModeNormal);
    size_t temp = CGBitmapContextGetBitsPerPixel(ctx); 
    CGImageAlphaInfo info = CGBitmapContextGetAlphaInfo(ctx);
	//rotate text
	//CGContextSetTextMatrix(imageContext, CGAffineTransformMakeRotation( -M_PI/4 ));
	
	//CGContextShowTextAtPoint(ctx, 4, 52, text, strlen(text));
	float xOffset = 0.5*(width - textSize.width); 
	float yOffset = 0.5*(height - textSize.height)+10; 
    
    const char *cText = NSStringToCString(text);
    
	CGContextShowTextAtPoint(ctx, xOffset, yOffset,cText, strlen(cText));
	CGImageRef imageMasked = CGBitmapContextCreateImage(ctx);
	
	UIImage *uiImage =  [UIImage imageWithCGImage:imageMasked];

	CGContextRelease(ctx);
	CGColorSpaceRelease(colorSpace);

	///////////////////////////////////
    UIImage *testImage  = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Title" ofType:@"png"]];
    CGSize size1 = testImage.size;
    CGSize size2 = uiImage.size;
    CGSize size3;
    size3.width = fmaxf(size1.width, size2.width);
    size3.height = size1.height+ size2.height;
    
    UIGraphicsBeginImageContext(size3);
    [testImage drawInRect:CGRectMake(0,0,testImage.size.width,testImage.size.height)];
    [uiImage drawInRect:CGRectMake(0,testImage.size.height,uiImage.size.width,uiImage.size.height) blendMode:kCGBlendModeNormal alpha:1.0];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    uiImage = newImage;
	if ( uiImage ) {
		
		// Turn off this call to copy some images into photos folder in iPhone simulator. 
		//UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil);
		
		// Create OpenGL texture from uiImage
        
        outImageInfo.texID = GL_ConvertUIImageToOpenGLTexture(uiImage, outImageInfo.originalWidth, outImageInfo.originalHeight, 
                                                              outImageInfo.texWidth, outImageInfo.texHeight, outImageInfo.image); 
        
        
        //outImageInfo.width = outImageInfo.texWidth;
        //outImageInfo.height = outImageInfo.texHeight;
		outImageInfo.bitDepth = 32;
        outImageInfo.rowBytes = outImageInfo.bitDepth/8 * outImageInfo.texWidth;
        
	}else {
        errorCode = 1;
    }
	
    return errorCode;
}
