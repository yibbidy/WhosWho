// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#ifndef Animation_h
#define Animation_h

#include <vector>

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

class AnimationBase
{
public:
    virtual void Blend(float inWeight) = 0;
    virtual ~AnimationBase() {}
    
    int _startTick;
	float _duration;
	InterpolationType _interpolation;
	int _animationID;
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
        InterpolationType inInterpolationType, T * inOutVariable)
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
