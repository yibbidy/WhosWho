// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Animation_h
#define Animation_h

#include <vector>
#include <string>

// This section has functions to set up a float variable animation over time.  The way this works is that an animation
// entry is put into a list when you call ANM_CreateFloatAnimation and for every draw frame that list is updated.
//
// use animation like this:
// AnimationSystem.CreateFloatAnimation(1, &myAnimationVariable, 0, 1, 2, InterpolationTypeSmooth);
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

float GetTick();

typedef void (* AnimationCompletedCallback)(const std::string & inArgs);

class AnimationBase
{
public:
    AnimationBase();
    virtual ~AnimationBase() {}
    virtual void Blend(float inWeight) = 0;
    
    
    int _startTick;
	float _duration;
	InterpolationType _interpolation;
	int _animationID;
    AnimationCompletedCallback _completed;
    std::string _completedArgs;
};

template<typename T>
class Animation : public AnimationBase
{
public:
    virtual void Blend(float inWeight) { *(_animationFloat) = (1-inWeight)*_startValue + inWeight*_endValue; }
    T * _animationFloat;
	T _startValue;
	T _endValue;
};


class AnimationSystem
{
public:
    static bool UpdateAnimations(float inTick);
    
    template<typename T> static int CreateFloatAnimation(T inStartValue, T inEndValue, float inDuration,
        InterpolationType inInterpolationType, T * inOutVariable,
        AnimationCompletedCallback inCompleted = 0, const char * inCompletedArgs = 0)
    // Call this function to create an animation.  By that I mean that after calling this, the variable *inOutVariable
    // will go from inStartValue to inEndValue in inDuration seconds.  You should use your variable, *inOutVariable,
    // in some drawing code.  The camera transitions (switching from one ring to the next) use this function.  You
    // don't have to delete your animation - that will happen automatically when it finishes.
    {
        Animation<T> * a = new Animation<T>();
        a->_animationID = AnimationSystem::_nextAnimationID++;
        a->_animationFloat = inOutVariable;
        a->_startValue = inStartValue;
        a->_endValue = inEndValue;
        a->_startTick = GetTick();
        a->_duration = inDuration;
        a->_interpolation = inInterpolationType;
        a->_completed = inCompleted;
        if( inCompletedArgs )
            a->_completedArgs = inCompletedArgs;
        AnimationSystem::_animations.push_back(a);
        
        return a->_animationID;
    }
    
    static bool IsRunning(int inAnimationID);
    static bool StopFloatAnimation(int inAnimationID);
    
    
private:
    static AnimationBase * GetAnimation(int inAnimationID);
    static bool UpdateAnimation(float inTick, AnimationBase & inOutAnimation);

    static int _nextAnimationID;
    static std::vector<AnimationBase *> _animations;
};


#endif
