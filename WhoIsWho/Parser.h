//
//  Parser.h
//  WhoIsWho
//
//  Created by Justin Hutchison on 2/23/13.
// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Parser_h
#define Parser_h

#include <string>

namespace who
{
    
class WhoParser
{
public:
    static bool PRS_Command(const char * inStr, int & inOutPos);
    
private:
    static void EatWhitespace(const char * inStr, int & inOutPos);
    static std::string Word(const char * inStr, int & inOutPos);
    static bool KeyValue(const char * inKey, const char * inStr, int & inOutPos, std::string & outValue);
    static bool ZoomToRing(const char * inStr, int & inOutPos);
    static bool ZoomToPhoto(const char * inStr, int & inOutPos);
    static bool IncrementCurrentRing(const char * inStr, int & inOutPos);
    static bool DecrementCurrentRing(const char * inStr, int & inOutPos);
    static bool SetCurrentPhoto(const char * inStr, int & inOutPos);
    static bool DecrementCurrentPhoto(const char * inStr, int & inOutPos);
    static bool AddImageFromText(const char * inStr, int & inOutPos);
    static bool AddImageFromFile(const char * inStr, int & inOutPos);
    static bool AddPhotoToRing(const char * inStr, int & inOutPos);
    static bool AddMaskToPhoto(const char * inStr, int & inOutPos);
    static bool NewBackRing(const char * inStr, int & inOutPos);
    static bool DeleteBackRing(const char * inStr, int &inOutPos);
    
};

}

#endif // #ifndef Parser_h

