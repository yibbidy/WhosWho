// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#include "Animation.h"
#include "glm/glm.hpp"
#include "utilities.h"

// TODO these variables should have a home.. better than global space
int AnimationSystem::_nextAnimationID = 1;

std::vector<Animation *> AnimationSystem::_animations;


// TODO ANM_ functinos should be in a class

bool AnimationSystem::UpdateAnimation(float inTick, Animation & inOutAnimation)
// this function is called to update an animation variable
// returns true if animation still running
{
	Animation & a = inOutAnimation;
    
	float t = (inTick - a.startTick) / a.duration;
	t = glm::min(glm::max(t, 0.0f), 1.0f);
    
	if( a.interpolation == InterpolationTypeSmooth ) {
		t = 3*t*t - 2*t*t*t;
	} else if( a.interpolation == InterpolationTypeSqrt ) {
		t = sqrt(t);
	}
	
	if( a.animationType == AnimationTypeFloat ) {
		*(a.animationFloat) = (1-t)*a.startValue + t*a.endValue;
	}
	
	return t < 1;
}

bool AnimationSystem::UpdateAnimations(float inTick) {
    
    bool anyAnimations = !_animations.empty();
    for_i( _animations.size() )
    // each animation will get updated and if it completes then we
    // will remove it from the list of animations
    {
        Animation * a = _animations[i];
        
        if( !UpdateAnimation(inTick, *a) ) {
            delete a;
            if( i < _animations.size()-1 ) {
                _animations[i] = _animations.back();
                i--;
            }
            _animations.resize(_animations.size()-1);
        }
    }
    
    return anyAnimations;
    
}

int AnimationSystem::CreateFloatAnimation(float inStartValue, float inEndValue, float inDuration,
                             InterpolationType inInterpolationType, float * inOutVariable)
// Call this function to create an animation.  By that I mean that after calling this, the variable *inOutVariable
// will go from inStartValue to inEndValue in inDuration seconds.  You should use your variable, *inOutVariable,
// in some drawing code.  The camera transitions (switching from one ring to the next) use this function.  You
// don't have to delete your animation - that will happen automatically when it finishes.
{
	Animation * a = new Animation();
	a->animationID = _nextAnimationID++;
	a->animationType = AnimationTypeFloat;
	a->animationFloat = inOutVariable;
	a->startValue = inStartValue;
	a->endValue = inEndValue;
	a->startTick = GetTick();
	a->duration = inDuration;
	a->interpolation = inInterpolationType;
    _animations.push_back(a);
    
    return a->animationID;
}

Animation * AnimationSystem::GetAnimation(int inAnimationID) {
    for_i( _animations.size() ) {
        Animation * a = _animations[i];
        if( a->animationID == inAnimationID ) {
            return a;
        }
    }
    return 0;
}

bool AnimationSystem::IsRunning(int inAnimationID)
// This function tells you whether inAnimationID is a running animation.  inAnimationID is the ID that was used in ANM_CreateFloatAnimation.
{
    return GetAnimation(inAnimationID) != 0;
}

bool AnimationSystem::StopFloatAnimation(int inAnimationID)
// This function terminates an animation specified by inAnimationID.  inAnimationID should be a valid ID that was used in ANM_CreateFloatAnimation.
{
	for_i( _animations.size() ) {
		if( _animations[i]->animationID == inAnimationID ) {
			delete _animations[i];
			if( i < _animations.size()-1 ) {
				_animations[i] = _animations.back();
			}
			_animations.resize(_animations.size()-1);
			return true;
		}
	}
	return false;
}
