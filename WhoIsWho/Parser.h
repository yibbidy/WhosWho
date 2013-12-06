//
//  Parser.h
//  WhoIsWho
//
//  Created by Justin Hutchison on 2/23/13.
// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Parser_h
#define Parser_h

#include "Animation.h"
#include <string>
#include <map>

namespace who
{
    
class WhoParser
{
public:
    static bool PRS_Command(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    
private:
    static void EatWhitespace(const char * inStr, int & inOutPos);
    static std::string Word(const char * inStr, int & inOutPos, char inDelim=0);
    static bool KeyValue(const char * inKey, const char * inStr, int & inOutPos, std::string & outValue);
    static std::map<std::string, std::string> KeyValues(const char * inStr, int & inOutPos);
    static void AnimationCompleted(const char * inStr, int & inOutPos, AnimationCompletedCallback & outCompleted, std::string & outArgs);

    static bool ZoomToRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool ZoomToPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool IncrementCurrentRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool DecrementCurrentRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool SetCurrentPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool DecrementCurrentPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool AddImageFromText(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool AddImageFromTextAndImage(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool AddImageFromFile(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool AddPhotoToRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool AddMaskToPhoto(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool NewBackRing(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool DeleteRingsAfter(const char * inStr, int &inOutPos, std::ostream & inErrorStream);

    static bool NewDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool AddPhotoToDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool ShowDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream);
    static bool HideDrawer(const char * inStr, int & inOutPos, std::ostream & inErrorStream);

    static bool DisplayControlsForRing(const char * inStr, int &inOutPos, std::ostream & inErrorStream);
};

}

#endif // #ifndef Parser_h

