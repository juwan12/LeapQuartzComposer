//
//  LeapQCHelper.m
//  LeapQuartzComposer
//
//  Created by chris on 05/01/2013.
//  Copyright (c) 2013 Chris Birch. All rights reserved.
//

#import "LeapQCHelper.h"
#import "LeapObjectiveC.h"

#define NSNumberFromInt(VALUE) [[NSNumber alloc] initWithInteger:VALUE]
#define NSNumberFromDouble(VALUE) [[NSNumber alloc] initWithDouble:VALUE]
#define NSNumberFromBOOL(VALUE) [[NSNumber alloc] initWithBool:VALUE]

#define QCRepresentationOfVector(VALUE) [self leapVectorToQCCompatibleType:VALUE]
#define QCRepresentationOfPointablesArray(VALUE) [self leapPointablesToQCCompatibleArray:VALUE]
#define QCRepresentationOfPointable(VALUE) [self leapPointableToDictionary:VALUE]
@interface LeapQCHelper ()
{
    
}
@end

@implementation LeapQCHelper
@synthesize includeGestureSwipe=_includeGestureSwipe;
@synthesize includeGestureKeyTap=_includeGestureKeyTap;
@synthesize includeGestureCircle=_includeGestureCircle;
@synthesize includeGestureScreenTap=_includeGestureScreenTap;

#pragma mark -
#pragma mark Gesture properties

-(void)setIncludeGestureCircle:(BOOL)includeGestureCircle
{
    _includeGestureCircle = includeGestureCircle;
    [_leapController enableGesture:LEAP_GESTURE_TYPE_CIRCLE enable:includeGestureCircle];

}


-(void)setIncludeGestureKeyTap:(BOOL)includeGestureKeyTap
{
    _includeGestureKeyTap = includeGestureKeyTap;
    [_leapController enableGesture:LEAP_GESTURE_TYPE_KEY_TAP enable:includeGestureKeyTap];

}


-(void)setIncludeGestureScreenTap:(BOOL)includeGestureScreenTap
{
    _includeGestureScreenTap = includeGestureScreenTap;
    [_leapController enableGesture:LEAP_GESTURE_TYPE_SCREEN_TAP enable:includeGestureScreenTap];


}


-(void)setIncludeGestureSwipe:(BOOL)includeGestureSwipe
{
    _includeGestureSwipe = includeGestureSwipe;
    [_leapController enableGesture:LEAP_GESTURE_TYPE_SWIPE enable:includeGestureSwipe];
}

//-(LeapVector*)leapVectorToScreen:(LeapVector*)deviceCoordinate
//{
//    LeapPointable* pointable = [[LeapPointable alloc] init];
//}

-(NSDictionary*) leapGestureToDictionary:(const LeapGesture*)gesture
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];

    
    [dictionary setObject:NSNumberFromInt(gesture.type) forKey:LEAP_GESTURE_TYPE];
    [dictionary setObject:NSNumberFromInt(gesture.state) forKey:LEAP_GESTURE_STATE];
    
//    NSLog(@"State is %d",gesture.state);
    
    [dictionary setObject:NSNumberFromDouble(gesture.durationSeconds) forKey:LEAP_GESTURE_DURATION_SECONDS];

    //Now add properties to the output for each of the specific types
    //of gesture
    switch (gesture.type)
    {
        case LEAP_GESTURE_TYPE_CIRCLE:
        {
//            NSLog(@"Circle");
            LeapCircleGesture *circleGesture = (LeapCircleGesture *)gesture;
            // Calculate the angle swept since the last frame
            float sweptAngle = 0;
            BOOL clockwise;
            
            if ([[[circleGesture pointable] direction] angleTo:[circleGesture normal]] <= LEAP_PI/4)
            {
                clockwise = YES;
            } else
            {
                clockwise = NO;
            }
//            if(circleGesture.state != LEAP_GESTURE_STATE_START)
//            {
//                LeapCircleGesture *previousUpdate = (LeapCircleGesture *)[[_leapController frame:1] gesture:gesture.id];
//                sweptAngle = (circleGesture.progress - previousUpdate.progress) * 2 * LEAP_PI;
//                sweptAngle *= LEAP_RAD_TO_DEG;             
//            }
            
            const LeapVector* center=circleGesture.center;
            const LeapVector* normal=circleGesture.normal;
            float radius = circleGesture.radius;
            
            if (_useScreenCoords)
            {
                radius = [self scaleRadiusToScreen:radius];
            }

            [dictionary setObject:NSNumberFromDouble(circleGesture.progress) forKey:LEAP_GESTURE_CIRCLE_PROGRESS];
            [dictionary setObject:NSNumberFromDouble(radius) forKey:LEAP_GESTURE_CIRCLE_RADIUS];
            [dictionary setObject:QCRepresentationOfVector(center) forKey:LEAP_GESTURE_CIRCLE_CENTER];
            [dictionary setObject:QCRepresentationOfVector(normal) forKey:LEAP_GESTURE_CIRCLE_NORMAL];
            [dictionary setObject:NSNumberFromDouble(sweptAngle) forKey:LEAP_GESTURE_CIRCLE_SWEPT_ANGLE];
            [dictionary setObject:NSNumberFromBOOL(clockwise) forKey:LEAP_GESTURE_CIRCLE_CLOCKWISE];
            
//            NSLog(@"Circle id: %d, %@, progress: %f, radius %f, angle: %f degrees",
//                  circleGesture.id, [Sample stringForState:gesture.state],
//                  circleGesture.progress, circleGesture.radius, sweptAngle * LEAP_RAD_TO_DEG);
            break;
        }
        case LEAP_GESTURE_TYPE_SWIPE:
        {
            LeapSwipeGesture *swipeGesture = (LeapSwipeGesture *)gesture;
        
//            NSLog(@"Swipe");
            
            [dictionary setObject:QCRepresentationOfVector(swipeGesture.position) forKey:LEAP_GESTURE_SWIPE_POSITION];
            [dictionary setObject:QCRepresentationOfVector(swipeGesture.startPosition) forKey:LEAP_GESTURE_SWIPE_START_POSITION];
            [dictionary setObject:QCRepresentationOfVector(swipeGesture.direction) forKey:LEAP_GESTURE_SWIPE_DIRECTION];
            [dictionary setObject:NSNumberFromDouble(swipeGesture.speed) forKey:LEAP_GESTURE_SWIPE_SPEED];
            
            break;
        }
        case LEAP_GESTURE_TYPE_KEY_TAP:
        {
//            NSLog(@"Key tap");
            LeapKeyTapGesture *keyTapGesture = (LeapKeyTapGesture *)gesture;
            [dictionary setObject:QCRepresentationOfVector(keyTapGesture.position) forKey:LEAP_GESTURE_KEY_TAP_POSITION];
            [dictionary setObject:QCRepresentationOfVector(keyTapGesture.direction) forKey:LEAP_GESTURE_KEY_TAP_DIRECTION];
            [dictionary setObject:NSNumberFromDouble(keyTapGesture.progress) forKey:LEAP_GESTURE_KEY_TAP_PROGRESS];
//            [dictionary setObject:QCRepresentationOfPointable(keyTapGesture.pointable) forKey:LEAP_GESTURE_KEY_TAP_POINTABLE];

            break;
        }
        case LEAP_GESTURE_TYPE_SCREEN_TAP:
        {
            LeapScreenTapGesture *screenTapGesture = (LeapScreenTapGesture *)gesture;
//            NSLog(@"Screen tap");
            [dictionary setObject:QCRepresentationOfVector(screenTapGesture.position) forKey:LEAP_GESTURE_SCREEN_TAP_POSITION];
            [dictionary setObject:QCRepresentationOfVector(screenTapGesture.direction) forKey:LEAP_GESTURE_SCREEN_TAP_DIRECTION];
            [dictionary setObject:NSNumberFromDouble(screenTapGesture.progress) forKey:LEAP_GESTURE_SCREEN_TAP_PROGRESS];
//            [dictionary setObject:QCRepresentationOfPointable(screenTapGesture.pointable) forKey:LEAP_GESTURE_SCREEN_TAP_POINTABLE];
            break;
        }
        default:
            return nil;
    }
    
    
    //NSLog(@"%@",dictionary);

    
    
    return dictionary;
}


#pragma mark -
#pragma mark Leap Entities to Dictionaries

-(NSDictionary*) leapScreenToDictionary:(const LeapScreen*)screen
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];

    [dictionary setObject:[self leapVectorToQCCompatibleType:screen.horizontalAxis] forKey:LEAP_SCREEN_AXIS_HORIZONTAL];
    [dictionary setObject:[self leapVectorToQCCompatibleType:screen.verticalAxis] forKey:LEAP_SCREEN_AXIS_VERTICAL];
    [dictionary setObject:[self leapVectorToQCCompatibleType:screen.bottomLeftCorner] forKey:LEAP_SCREEN_BOTTOM_LEFT_CORNER];
    [dictionary setObject:[self leapVectorToQCCompatibleType:screen.normal] forKey:LEAP_SCREEN_NORMAL];
    

    [dictionary setObject:[[NSNumber alloc] initWithInt:screen.widthPixels] forKey:LEAP_SCREEN_WIDTH];
    [dictionary setObject:[[NSNumber alloc] initWithInt:screen.heightPixels] forKey:LEAP_SCREEN_HEIGHT];
    [dictionary setObject:[[NSNumber alloc] initWithBool:screen.isValid] forKey:LEAP_IS_VALUD];
    
    
    return dictionary;
}



-(NSDictionary*) leapFrameToDictionary:(const LeapFrame*)frame
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[NSNumber alloc] initWithLongLong:frame.id] forKey:LEAP_ID];
    [dictionary setObject:[[NSNumber alloc] initWithLongLong:frame.timestamp] forKey:@"timestamp"];
    
//    if (frame.hands)
//    {
//        //get an array containing the hand dictionaries
//        NSArray* qcHands = [self leapHandsToQCCompatibleArray:frame.hands];
//        [dictionary setObject:qcHands forKey:LEAP_HANDS];
//    }
//    
//    if (frame.fingers)
//    {
//        //get an array containing the finger dictionaries
//        NSArray* qcFingers = [self leapFingersToQCCompatibleArray:frame.fingers];
//        [dictionary setObject:qcFingers forKey:LEAP_FINGERS];
//    }
    
//    if (frame.pointables)
//    {
//        //get an array containing the pointables dictionaries
//        NSArray* qcPointables = [self leapPointablesToQCCompatibleArray:frame.pointables];
//        [dictionary setObject:qcPointables forKey:LEAP_POINTABLES];
//    }
//
//    if (frame.tools)
//    {
//        //get an array containing the tools dictionaries
//        NSArray* qcTools = [self leapPointablesToQCCompatibleArray:frame.tools];
//        [dictionary setObject:qcTools forKey:LEAP_TOOLS];
//    }
    
    
    return dictionary;
    
}
//
//-(LeapVector*)topRightCornerFromBottomLeftCorner:(const LeapVector*)bottomLeft
//{
//    float x=0,y=0,z=0;
//    
//    x=bottomLeft.x*-1;
//    y=bottomLeft.y*-1;
//    z=bottomLeft.z*-1;
//    
//    return [[LeapVector alloc] initWithX:x y:y z:z];
//}

-(void)logVector:(LeapVector*) vector withTitle:(NSString*)title
{
    NSLog(@"%@ x = %.2f, y = %.2f, z = %.2f",title,vector.x,vector.y,vector.z);
}

/**
 * Given a width represented in float form, will return a float that is scaled and clamped at -1 to 1
 */
-(float)scaleWidthToScreen:(float)value
{
    LeapScreen* screen = [_leapController.locatedScreens objectAtIndex:_calibratedScreenIndex];
    
    LeapVector* bottomLeftCorner = screen.bottomLeftCorner;

    float screenTotalWidth = fabs(bottomLeftCorner.x) * 2;
    
    float x = value / screenTotalWidth;
    
    return x;
}

/**
 * Given a length represented in float form, will return a float that is scaled and clamped at 0 to 1
 */
-(float)scaleLengthToScreen:(float)value
{
    LeapScreen* screen = [_leapController.locatedScreens objectAtIndex:_calibratedScreenIndex];
    
    LeapVector* bottomLeftCorner = screen.bottomLeftCorner;
    
    float screenTotalDepth = fabs(bottomLeftCorner.z) * 2;
    
    float z = value / screenTotalDepth;
    
    return z;
}

/**
 * Given a radius represented in float form, will return a float that is scaled and clamped at 0 to 1
 */
-(float)scaleRadiusToScreen:(float)value
{
    LeapScreen* screen = [_leapController.locatedScreens objectAtIndex:_calibratedScreenIndex];
    
    LeapVector* bottomLeftCorner = screen.bottomLeftCorner;
    
    float aspect = (float)screen.widthPixels / (float)screen.heightPixels;
    
    float screenTotalDepth = fabs(bottomLeftCorner.z) * 2;
    
    float z = value / screenTotalDepth;
    
    return z * aspect;
}

float magnitude(LeapVector* vector)
{
    
    return sqrtf(vector.x*vector.x + vector.y*vector.y + vector.z*vector.z);
}


/**
 * Given a leap vector in device coordinates will return a vector that is scaled to screen coords
 */
-(LeapVector*)scalePointableToScreen:(const LeapPointable*)pointable
{
    LeapScreen* screen = [_leapController.locatedScreens objectAtIndex:_calibratedScreenIndex];
    
    LeapVector* vector = [screen intersect:pointable normalize:YES clampRatio:1];
    
    LeapVector* bLC = screen.bottomLeftCorner;
    
    float screenDepthMM = fabs(screen.bottomLeftCorner.z) *2;
    
    float x=vector.x,y=vector.y,z=pointable.tipPosition.z;
    
    //get a value scaled from 0 to 1
    z  /= screenDepthMM;
    
    z *=  _zScale;
    
    //x /= screen.widthPixels;
    //y /= screen.heightPixels;
    
    x = x * 2 - 1;//_qcWidth - (_qcWidth /2);
    y = y * _qcHeight - (_qcHeight /2);
    //z = z * 2 - 1;
    
    //NSLog(@"x: %.2f y: %.2f z: %.2f",x,y,z);
    
    
    return [[LeapVector alloc] initWithX:x y:y z:z];
    //
    //    float x =deviceCoordinates.x ,y=deviceCoordinates.y ,z=deviceCoordinates.z;
    //
    //    LeapVector* bLC = screen.bottomLeftCorner;
    //
    //    float screenWidthMM = fabs(bLC.x) * 2;
    //    float screenHeightMM =  magnitude(screen.verticalAxis);
    //    float screenDepthMM = fabs(screen.bottomLeftCorner.z) *2;
    //
    //    //take into account screen location
    //    y-= bLC.y;
    //    x -= bLC.x;
    //    z -= bLC.z;
    //
    //
    //    //Scale to screen coordinates
    //    x /= screenWidthMM;
    //    y /= screenHeightMM;
    //    z /= screenDepthMM;
    //
    //
    //    x = x * 2 -1;
    //    y = y  -1;
    //    
    //    
    //    LeapVector* sV = [[LeapVector alloc] initWithX:x y:y z:z];
    //    
    //    return sV;
}


/**
 * Given a leap vector in device coordinates will return a vector that is scaled to screen coords
 */
-(LeapVector*)scaleCoordinateToScreen:(const LeapVector*)deviceCoordinates
{
    LeapScreen* screen = [_leapController.locatedScreens objectAtIndex:_calibratedScreenIndex];

    LeapVector* vector = [screen project:deviceCoordinates normalize:YES clampRatio:1];
    
    LeapVector* bLC = screen.bottomLeftCorner;

    float screenDepthMM = fabs(screen.bottomLeftCorner.z) *2;

    float x=vector.x,y=vector.y,z=deviceCoordinates.z;
    
    //get a value scaled from 0 to 1
    z  /= screenDepthMM;
    
    z *= _zScale;
    
    //x /= screen.widthPixels;
    //y /= screen.heightPixels;
    
    x = x * 2 - 1;//_qcWidth - (_qcWidth /2);
    y = y * 2-1;//_qcHeight - (_qcHeight /2);
    //z = z * 2 - 1;
    
    //NSLog(@"x: %.2f y: %.2f z: %.2f",x,y,z);

    
    return [[LeapVector alloc] initWithX:x y:y z:z];
//    
//    float x =deviceCoordinates.x ,y=deviceCoordinates.y ,z=deviceCoordinates.z;
//    
//    LeapVector* bLC = screen.bottomLeftCorner;
//    
//    float screenWidthMM = fabs(bLC.x) * 2;
//    float screenHeightMM =  magnitude(screen.verticalAxis);
//    float screenDepthMM = fabs(screen.bottomLeftCorner.z) *2;
//    
//    //take into account screen location
//    y-= bLC.y;
//    x -= bLC.x;
//    z -= bLC.z;
//    
//
//    //Scale to screen coordinates
//    x /= screenWidthMM;
//    y /= screenHeightMM;
//    z /= screenDepthMM;
//    
//    
//    x = x * 2 -1;
//    y = y  -1;
//    
//    
//    LeapVector* sV = [[LeapVector alloc] initWithX:x y:y z:z];
//    
//    return sV;
}


-(NSDictionary*) leapHandToDictionary:(const LeapHand*)hand
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[NSNumber alloc] initWithInteger:hand.id] forKey:LEAP_ID];

    if (_includeFingersInHand)
    {
        NSArray* items = hand.fingers;
        //get an array
        NSArray* dict = [self leapPointablesToQCCompatibleArray:items];
        [dictionary setObject:dict forKey:LEAP_FINGERS];
    }

    
    if (_includePointablesInHand)
    {
        NSArray* items = hand.pointables;
        //get an array
        NSArray* dict = [self leapPointablesToQCCompatibleArray:items];
        [dictionary setObject:dict forKey:LEAP_POINTABLES];
    }
    
    if (_includeToolsInHand)
    {
        NSArray* items = hand.tools;
        //get an array
        NSArray* dict = [self leapPointablesToQCCompatibleArray:items];
        [dictionary setObject:dict forKey:LEAP_TOOLS];
    }
   

    //The following things may or may not exist so we need to test for each one before sending it
    //otherwise these things will be wrongly reported as being 0
    
    //Make sure the hand has a palm ray
    if (hand.palmPosition)
    {
        const LeapVector* palmPos = hand.palmPosition;
        
        [dictionary setObject:[self leapVectorToQCCompatibleType: palmPos] forKey:@"palmPosition"];
    }
    //make sure it has a velocity vector
    if(hand.palmVelocity)
    {
        [dictionary setObject:[self leapVectorToQCCompatibleType:hand.palmVelocity] forKey:@"palmVelocity"];
    }
    //make sure it has a normal vector
    if(hand.palmNormal)
    {
        [dictionary setObject:[self leapVectorToQCCompatibleType:hand.palmNormal] forKey:@"palmNormal"];
    }
    
    if(hand.direction)
    {
        [dictionary setObject:[self leapVectorToQCCompatibleType:hand.direction] forKey:@"direction"];
    }
    
    if(hand.sphereCenter)
    {
        const LeapVector* sphereCenter = hand.sphereCenter;
        
        [dictionary setObject:[self leapVectorToQCCompatibleType:sphereCenter] forKey:@"sphereCenter"];
    }
    
    float sphereRadius = hand.sphereRadius;
    
    if (_useScreenCoords)
    {
        sphereRadius = [self scaleRadiusToScreen:sphereRadius];
    }

    [dictionary setObject:[NSNumber numberWithFloat:sphereRadius] forKey:@"sphereRadius"];
    [dictionary setObject:[NSNumber numberWithBool:hand.isValid] forKey:@"isValid"];
    
    
    return dictionary;
}


-(LeapVector*)screenVectorForPointable:(const LeapPointable*)pointable
{
    //  float x=vector.x,y=vector.y,z=vector.z;
    LeapScreen* screen = [_leapController.locatedScreens objectAtIndex:_calibratedScreenIndex];
    LeapVector* tipPosition=pointable.tipPosition;
    float x=tipPosition.x,y=tipPosition.y,z=0;
    LeapVector* screenCoordForZ = [self scaleCoordinateToScreen:tipPosition];
    
    //[self logVector:deviceCoordinates withTitle:@"Coordinate Device"];
    //[self logVector:screenCoordForZ withTitle:@"Coordinate scaled"];

    //tipPosition = [self scaleCoordinateToScreen2:tipPosition];
    

    tipPosition = [screen intersect:pointable normalize:YES clampRatio:1 ];
    
    x = tipPosition.x;
    y = tipPosition.y;
    z = tipPosition.z;
    
//    x = tipPosition.x * 2 -1 ;//* screen.widthPixels;
//    y = tipPosition.y * 2 - 1; //* screen.heightPixels;
//    z = screenCoordForZ.z;
//    
   // x /=
    
    //NSLog(@"X: %.2f Y: %.2f Z: %.2f",x,y,z);
    tipPosition = [[LeapVector alloc] initWithX:x y:y z:z];
    
    return tipPosition;
}

-(NSDictionary*) leapPointableToDictionary:(const LeapPointable*)pointable
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[NSNumber alloc] initWithInteger:pointable.id] forKey:LEAP_ID];
    
    const LeapVector* tipPosition = pointable.tipPosition;
    float pointableWidth = pointable.width;
    float pointableLength = pointable.length;
    
    if(_useScreenCoords)
    {
        pointableWidth = [self scaleWidthToScreen: pointable.width];
        pointableLength =  [self scaleLengthToScreen:pointable.length];
        
    }
    
    if(pointable.tipPosition)
    {
        LeapVector* vec = nil;//[self scalePointableToScreen:pointable];
        vec = [self scaleCoordinateToScreen:tipPosition];
        [dictionary setObject:[self leapVectorToDictionary:vec] forKey:@"tipPosition"];
    }
    
    if(pointable.tipVelocity)
    {
        [dictionary setObject:[self leapVectorToQCCompatibleType:pointable.tipVelocity] forKey:@"tipVelocity"];
    }
    
    if(pointable.direction)
    {
        [dictionary setObject:[self leapVectorToQCCompatibleType:pointable.direction] forKey:@"direction"];
    }
    
    [dictionary setObject:[[NSNumber alloc] initWithFloat:pointableWidth] forKey:@"width"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:pointableLength] forKey:@"length"];
    
    [dictionary setObject:[[NSNumber alloc] initWithBool:pointable.isFinger] forKey:@"isFinger"];
    [dictionary setObject:[[NSNumber alloc] initWithBool:pointable.isTool] forKey:@"isTool"];
    [dictionary setObject:[[NSNumber alloc] initWithBool:pointable.isValid] forKey:@"isValid"];
    
    
    return dictionary;
}


#pragma mark -
#pragma mark Array output functions

-(NSArray*) leapScreensToQCCompatibleArray:(const NSArray*)screens
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    for (LeapScreen* screen in screens)
    {
        [array addObject:[self leapScreenToDictionary:screen]];
    }
    
    return array;
}


-(NSArray*) leapHandsToQCCompatibleArray:(const NSArray*)hands
{
    NSMutableArray* handsArray = [[NSMutableArray alloc] init];
    
    for(LeapHand* hand in hands)
    {
        NSDictionary* handDictionary =  [self leapHandToDictionary:hand];
        [handsArray addObject:handDictionary];
    }
    
    return handsArray;
}


-(NSArray*) leapPointablesToQCCompatibleArray:(const NSArray*)pointables
{
    NSMutableArray* fingersArray = [[NSMutableArray alloc] init];
    
    for(LeapPointable* pointable in pointables)
    {
        NSDictionary* fingerDictionary =  [self leapPointableToDictionary:pointable];
        [fingersArray addObject:fingerDictionary];
    }
    
    return fingersArray;
}

/**
 * Based on the configuration of this instances properties, returns YES or NO depeding on whether
 * user code wishes each type of gesture to be included in the ouput
 */
-(BOOL)shouldIncludeGestureInArray:(LeapGesture*)gesture
{
    switch(gesture.type)
    {
        case LEAP_GESTURE_TYPE_CIRCLE:
        {
            return _includeGestureCircle;
        }
        case LEAP_GESTURE_TYPE_KEY_TAP:
        {
            return _includeGestureKeyTap;
        }
        case LEAP_GESTURE_TYPE_SCREEN_TAP:
        {
            return _includeGestureScreenTap;
        }
        case LEAP_GESTURE_TYPE_SWIPE:
        {
            return _includeGestureSwipe;
        }
        case LEAP_GESTURE_TYPE_INVALID:
        {
            return NO;
        }
    }

    return NO;

}




-(void) processLeapGesturesSinceLastFrame:(const NSArray*)gestures andOnlyOneFrame:(const NSArray*)gesturesSingleFrame
{
    //we need to create arrays to hold the different type of gestures
    //since we need to expose each type of gesture to the correct ouputPort
    NSMutableArray* swipeArray = [[NSMutableArray alloc] init];
    NSMutableArray* circleArray = [[NSMutableArray alloc] init];
    NSMutableArray* keyTapArray = [[NSMutableArray alloc] init];
    NSMutableArray* screenTapArray = [[NSMutableArray alloc] init];

    //Set instance properties
    
    _frameGestureSwipes = nil;
    _frameGestureCircles = nil;
    _frameGestureScreenTaps = nil;
    _frameGestureKeyTaps = nil;

    for(LeapGesture* gesture in gestures)
    {
        //Only include this gesture if user code has told us it wants it.
        //*see inputPorts for more info about how this helper is used.
        if ([self shouldIncludeGestureInArray:gesture])
        {
            //create a leap compatible dictionary to add to an array
            NSDictionary* gestureDictionary =  [self leapGestureToDictionary:gesture];
            
            //Now we need to decide which array to put this gesture in
            switch(gesture.type)
            {
                
                case LEAP_GESTURE_TYPE_KEY_TAP:
                {
                    [keyTapArray addObject:gestureDictionary];
                    break;
                }
                case LEAP_GESTURE_TYPE_SCREEN_TAP:
                {
                    [screenTapArray addObject:gestureDictionary];
                    break;
                }
                
                case LEAP_GESTURE_TYPE_INVALID:
                {
                    NSLog(@"Invalid type of gesture");
                    break;
                }
            }
        }
        
    }

    for(LeapGesture* gesture in gesturesSingleFrame)
    {
        //Only include this gesture if user code has told us it wants it.
        //*see inputPorts for more info about how this helper is used.
        if ([self shouldIncludeGestureInArray:gesture])
        {
            //create a leap compatible dictionary to add to an array
            NSDictionary* gestureDictionary =  [self leapGestureToDictionary:gesture];
            
            //Now we need to decide which array to put this gesture in
            switch(gesture.type)
            {
                case LEAP_GESTURE_TYPE_CIRCLE:
                {
                    [circleArray addObject:gestureDictionary];
                    break;
                }
                case LEAP_GESTURE_TYPE_SWIPE:
                {
                    [swipeArray addObject:gestureDictionary];
                    break;
                }
                case LEAP_GESTURE_TYPE_INVALID:
                {
                    NSLog(@"Invalid type of gesture");
                    break;
                }
            }
        }
        
    }

    static int swipe=0,circle=0,tap=0,keyTap=0;
    
    //Now set outputs if needed
    if(swipeArray.count)
    {
        _frameGestureSwipes = swipeArray;
    }
    
    if (circleArray.count)
    {
        _frameGestureCircles = circleArray;
    }
    
    if (screenTapArray.count)
    {
        _frameGestureScreenTaps = screenTapArray;
    }
    
    if (keyTapArray.count)
    {
        _frameGestureKeyTaps = keyTapArray;
    }
    
    
    NSLog(@"circle %i - swipe %i - screenTap %i - keyTap %i",circle,swipe,tap,keyTap);

    
}


#pragma mark -
#pragma mark Vector stuff


-(id)leapVectorToQCCompatibleType:(const LeapVector*)vector
{
    if(_useScreenCoords)
    {
        vector = [self scaleCoordinateToScreen:vector];
    }

    
    
    if (_outputVectorsAsDictionaries)
    {
        return [self leapVectorToDictionary:vector];
    }
    else
    {
        return [self leapVectorToArray:vector];
    }
}



-(NSArray*) leapVectorToArray:(const LeapVector*)vector
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    
    [array addObject:[[NSNumber alloc] initWithFloat:vector.x]];
    [array addObject:[[NSNumber alloc] initWithFloat:vector.y]];
    [array addObject:[[NSNumber alloc] initWithFloat:vector.z]];
    
    if (_outputYawPitchRoll)
    {
        [array addObject:[[NSNumber alloc] initWithFloat:vector.yaw]];
        [array addObject:[[NSNumber alloc] initWithFloat:vector.pitch]];
        [array addObject:[[NSNumber alloc] initWithFloat:vector.roll]];
    }
    
    return array;
}


-(NSDictionary*) leapVectorToDictionary:(const LeapVector*)vector
{
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    
    [dictionary setObject:[[NSNumber alloc] initWithFloat:vector.x] forKey:@"x"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:vector.y] forKey:@"y"];
    [dictionary setObject:[[NSNumber alloc] initWithFloat:vector.z] forKey:@"z"];
    
    if (_outputYawPitchRoll)
    {
        [dictionary setObject:[[NSNumber alloc] initWithFloat:vector.yaw] forKey:@"yaw"];
        [dictionary setObject:[[NSNumber alloc] initWithFloat:vector.pitch] forKey:@"pitch"];
        [dictionary setObject:[[NSNumber alloc] initWithFloat:vector.roll] forKey:@"roll"];

    }
    
    
    return dictionary;
}

@end
