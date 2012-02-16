//
//  MiaSensorDelegate.h
//  MIA
//
//  Created by Joakim Bording on 11.01.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>


@interface MiaSensorDelegate : NSObject{
    @private
    BOOL sensorsRunning;
    CMMotionManager* motionManager;
}


- (MiaSensorDelegate*) init;

- (void)update:(double) roll 
              :(double) pitch
              :(double) yaw
              :(double) rollRate
              :(double) pitchRate
              :(double) yawRate
              :(double) accelX
              :(double) accelY
              :(double) accelZ;
- (void) startAnimation;
- (void) stopAnimation;
- (void) handleDeviceMotion:(CMDeviceMotion*)motion;

@end