//
//  SoundController.h
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>
#import <CoreMIDI/MIDINetworkSession.h>
#import "PdAudio.h"
#import "PdBase.h"
#import "MiaSensorDelegate.h"

typedef struct {
    char midiMessage[256];
    int tall;
} MessageStruct;


@interface SoundController : NSObject <PdReceiverDelegate, NSNetServiceDelegate, 
                                NSNetServiceBrowserDelegate> {
    
    PdAudio *pdAudio;   // PdAudio object that acts as glue between LibPd and CoreAudio
    
    MiaSensorDelegate *sensorDelegate;
    
    MIDINetworkHost *host;
    MIDINetworkSession *session;
    MIDIClientRef client;
    MIDIPortRef inPort;
    MIDIPortRef outPort;
    MIDIEndpointRef src;
    MIDIEndpointRef dest;
    
    MessageStruct messageStruct;
    
    NSString *netClient;
    NSString *hostList;
    
    // Bonjour sevice browser
    BOOL isConnected;
    NSNetServiceBrowser* browser;
    NSNetService* connectedService;
    NSMutableArray* services;
    
}

@property (retain) NSString *netClient;
@property (retain) NSString *hostList;

@property (readwrite, assign) BOOL isConnected;
@property (readwrite, retain) NSNetServiceBrowser* browser;
@property (readwrite, retain) NSNetService* connectedService;
@property (readwrite, retain) NSMutableArray* services;

- (SoundController*) init;
- (void) sendNote:(int)note;
- (void) playNote;
- (void) switchInstrument;
- (void) selectInstrument:(int)instrument;
- (void) updatePitch:(int)pitch;

/// Send a MIDI byte stream to every connected MIDI port
- (void) sendNotes;
- (void) sendBytes:(const UInt8*)bytes size:(UInt32)size;
- (void) sendPacketList:(const MIDIPacketList *)packetList;
- (void) setLastRecMsg:(NSString *)lastReceivedMsg;
- (NSString*) getLastRecMsg;
- (void) updateNetClient;
- (void) connectToHost:(NSString*)otherHost;
- (NSString*) hostToConnect;


@end
