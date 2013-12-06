// Contributors:
//  Justin Hutchison (yibbidy@gmail.com)

#include "Animation.h"
#include "glm/glm.hpp"
#include "utilities.h"

int AnimationSystem::_nextAnimationID = 1;


std::vector<AnimationBase *> AnimationSystem::animations;

//======== AnimationBase

AnimationBase::AnimationBase()
{
    startTick = 0;
    duration = 0;
    interpolation = InterpolationTypeLinear;
    _animationID = 0;
    _completed = 0;
}

//========== AnimationSystem

bool AnimationSystem::UpdateAnimation(float inTick, AnimationBase & inOutAnimation)
// this function is called to update an animation variable
// returns true if animation still running
{
	AnimationBase & a = inOutAnimation;
    
	float t = (inTick - a.startTick) / a.duration;
	t = glm::min(glm::max(t, 0.0f), 1.0f);
    
	if( a.interpolation == InterpolationTypeSmooth ) {
		t = 3*t*t - 2*t*t*t;
	} else if( a.interpolation == InterpolationTypeSqrt ) {
		t = sqrt(t);
	}
	
    a.Blend(t);
	
	return t < 1;
}

bool AnimationSystem::UpdateAnimations(float inTick) {
    
    bool anyAnimations = !animations.empty();
    for_i( animations.size() )
    // each animation will get updated and if it completes then we
    // will remove it from the list of animations
    {
        AnimationBase * a = animations[i];

        if( !UpdateAnimation(inTick, *a) ) {
            if( a->_completed )
                (*a->_completed)(a->_completedArgs);
            
            delete a;
            if( i < animations.size()-1 ) {
                animations[i] = animations.back();
                i--;
            }
            animations.resize(animations.size()-1);
        }
    }
    
    return anyAnimations;
    
}



AnimationBase * AnimationSystem::GetAnimation(int inAnimationID) {
    for_i( animations.size() ) {
        AnimationBase * a = animations[i];

        if( a->_animationID == inAnimationID ) {
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
	for_i( animations.size() ) {
		if( animations[i]->_animationID == inAnimationID ) {
			delete animations[i];
			if( i < animations.size()-1 ) {
				animations[i] = animations.back();
			}
			animations.resize(animations.size()-1);
			return true;
		}
	}
	return false;
}
