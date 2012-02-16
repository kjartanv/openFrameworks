//
//  SoundController.h
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import "PdAudio.h"
#import "PdBase.h"
#import "MiaSensorDelegate.h"


@interface SoundController : NSObject <PdReceiverDelegate> {
    
    PdAudio *pdAudio;   // PdAudio object that acts as glue between LibPd and CoreAudio
    
    MiaSensorDelegate *sensorDelegate;
    
    MIDIClientRef client;
    MIDIPortRef inPort;
    MIDIPortRef outPort;
    MIDIEndpointRef src;
    MIDIEndpointRef dest;
    
    
}


- (SoundController*) init;
- (void) sendNote:(int)note;
- (void) playNote;
- (void) switchInstrument;
- (void) selectInstrument:(int)instrument;
- (void) updatePitch:(int)pitch;

@end
