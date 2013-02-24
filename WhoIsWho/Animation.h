// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Animation_h
#define Animation_h

#include <vector>

// This section has functions to set up a float variable animation over time.  The way this works is that an animation
// entry is put into a list when you call ANM_CreateFloatAnimation and for every draw frame that list is updated.
//
// use animation like this:
// ANM_CreateFloatAnimation(1, &myAnimationVariable, 0, 1, 2, InterpolationTypeSmooth);
//
// void MyDrawFunc() {
//   drawPosition.x = myAnimationVaraible;  // drawPosition.x will slide from 0 to 1 over 2 seconds
//   ...


enum InterpolationType {
	InterpolationTypeLinear,
	InterpolationTypeSmooth,
	InterpolationTypeSqrt
};

enum AnimationType {
	AnimationTypeFloat
};

struct Animation {
	AnimationType animationType;
    
	float * animationFloat;
	float startValue;
	float endValue;
    
	int startTick;
	float duration;
	InterpolationType interpolation;
	int animationID;
};


float GetTick();

bool ANM_UpdateAnimations(float inTick);
int ANM_CreateFloatAnimation(float inStartValue, float inEndValue, float inDuration,
                             InterpolationType inInterpolationType, float * inOutVariable);
bool ANM_IsRunning(int inAnimationID);
bool ANM_StopFloatAnimation(int inAnimationID);


extern int gNextAnimationID;
extern std::vector<Animation *> gAnimations;
extern int currentAnmID;



#endif
