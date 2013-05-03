// Contributors:
//  Shirley Carter (shirley.carter66@gmail.com)

#ifndef WhoIsWho_glUtilities_h
#define WhoIsWho_glUtilities_h

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "utilities.h"

// TODO this file should be merged into renderer.h i think
const char *NSStringToCString( const NSString *thisNSString);
std::string NSStringToString(NSString *thisNSString);
enum Texture2DPixelFormat {
	kTexture2DPixelFormat_Automatic = 0,
	kTexture2DPixelFormat_RGBA8888,
	kTexture2DPixelFormat_RGBA4444,
	kTexture2DPixelFormat_RGBA5551,
	kTexture2DPixelFormat_RGB565,
	kTexture2DPixelFormat_RGB888,
	kTexture2DPixelFormat_L8,
	kTexture2DPixelFormat_A8,
	kTexture2DPixelFormat_LA88,
	kTexture2DPixelFormat_RGB_PVRTC2,
	kTexture2DPixelFormat_RGB_PVRTC4,
	kTexture2DPixelFormat_RGBA_PVRTC2,
	kTexture2DPixelFormat_RGBA_PVRTC4
};
GLuint GL_CreateOpenGLTexture(const void *data, Texture2DPixelFormat pixelFormat, NSUInteger width,  NSUInteger height);
GLuint GL_ConvertUIImageToOpenGLTexture(const UIImage *uiImage, int &imageWidth, int &imageHeight, int &width, int &height, unsigned char *&imageData);
int GL_LoadTextureFromText(std::string inText/*const NSString *text*/,ImageInfo & outImageInfo);
int GL_LoadTextureFromTextAndImage(std::string inText,std::string imageFile,ImageInfo & outImageInfo);
int GL_LoadTextureFromFile(const char * inFileName, ImageInfo & outImageInfo);
int GL_LoadTextureFromUIImage(UIImage * uiImage, ImageInfo & outImageInfo);

void *GL_GetUIImageFromFile(const char * inFileName);
NSString *getGameDataFolderPath();
NSString *getGameDataFolderPath(NSString *thisGame);
NSString *getGameFileNameNSString(std::string fileName);
extern NSString *gOriginalGameName;

#endif
