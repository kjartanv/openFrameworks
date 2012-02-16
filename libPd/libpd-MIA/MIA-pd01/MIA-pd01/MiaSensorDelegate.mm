//
//  MiaSensorDelegate.c
//  MIA
//
//  Created by Joakim Bording on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MiaSensorDelegate.h"
#import <CoreMotion/CoreMotion.h>

@implementation MiaSensorDelegate

-(MiaSensorDelegate*) init {
	self = [super init];
    
	return self;
}

- (void) update: (double) roll 
                :(double) pitch
                :(double) yaw
                :(double) rollRate
                :(double) pitchRate
                :(double) yawRate
                :(double) accelX
                :(double) accelY
                :(double) accelZ
{
    //motionHandler->update(roll,pitch,yaw,rollRate,pitchRate,yawRate,accelX,accelY,accelZ);
}

- (void) startAnimation
{
	if (!sensorsRunning)
	{
        // Create our CMMotionManager instance
		if (motionManager == nil) {
			motionManager = [[CMMotionManager alloc] init];
		}
		
		// Turn on the appropriate type of data
		motionManager.deviceMotionUpdateInterval = 0.04;
        
        if(motionManager.deviceMotionAvailable){
            NSLog(@"Device Motion Available - Started");
            
            //motionHandler->start();
            
        	[motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler: ^(CMDeviceMotion *motion, NSError *error){
               [self performSelectorOnMainThread:@selector(handleDeviceMotion:) withObject:motion waitUntilDone:YES];
             
             }];
            
            sensorsRunning = TRUE;
            
        } else {
            NSLog(@"No device motion on device - FAILED!");  
            //motionHandler->stop();
            sensorsRunning = FALSE;    
        }
		
    }
}

- (void)stopAnimation
{
	if (sensorsRunning)
	{
		[motionManager stopDeviceMotionUpdates];
		[motionManager release];
        motionManager = nil;
		sensorsRunning = FALSE;
        //motionHandler->stop();        
	}
}

- (void)handleDeviceMotion:(CMDeviceMotion*)motion{
    
    CMAttitude *attitude = motion.attitude; 
    // ATTITUDE / APPARATETS STILLING
    // .roll .pitc .yaw i radianer (double) relative til omgivelsene
    // (.rotationMatrix eller .quaternion er alternative metoder å se stilling på)
    // http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMAttitude_Class/Reference/Reference.html#//apple_ref/occ/cl/CMAttitude
    
    CMRotationRate rotation = motion.rotationRate; 
    // ROTATION / ENDRINGEN AV APPARATETS STILLING
    // .x .y .z i radianer per sekund (double)
    // http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMGyroData_Class/Reference/Reference.html#//apple_ref/c/tdef/CMRotationRate
    
    CMAcceleration acceleration = motion.userAcceleration; 
    // ACCELERATION / BRUKER INDUSER AKSELLERASJON
    // .x .y .z i G-krefter (double) relativ til apparatet med gravitasjonen trukket fra (0,0,0 i ro)
    // http://developer.apple.com/library/ios/#documentation/CoreMotion/Reference/CMDeviceMotion_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40009942
    
    //NSLog(@"KALL 1 = %f", 0.0f);
    [self update: attitude.roll : attitude.pitch : attitude.yaw : rotation.x : rotation.y : rotation.z : acceleration.x : acceleration.y : acceleration.z]; 
    /*
    
    float accelerationThreshold = 0.2; // or whatever is appropriate - play around with different values
    CMAcceleration userAcceleration = motion.userAcceleration;
    
    float rotationRateThreshold = 7.0;
    CMRotationRate rotationRate = motion.rotationRate;
    
    if ((rotationRate.x) > rotationRateThreshold) {
        if (fabs(userAcceleration.x) > accelerationThreshold || fabs(userAcceleration.y) > accelerationThreshold || fabs(userAcceleration.z) > accelerationThreshold) {
            
            NSLog(@"rotation rate = [Pitch: %f, Roll: %f, Yaw: %f]", attitude.pitch, attitude.roll, attitude.yaw);
            NSLog(@"motion.rotationRate = %f", rotationRate.x);
            [self update];
            
        }
    }
     */
}

- (void) dealloc
{
	[self stopAnimation];
    //motionHandler = nil;
	[super dealloc];
}


@end