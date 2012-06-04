//
//  MidiController.m
//  MIAtab
//
//  Created by Kjartan Vestvik on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MidiController.h"
#import "SNFCoreAudioUtils.h"

@implementation MidiController

@synthesize services;

static MidiController *_sharedInstance = nil;


#pragma mark - Forward declarations

static void MIDIClientNotifyProc(const MIDINotification *message, void *refCon);
static void MIDIInputReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);


#pragma mark - Lifecycle

- (id) init {
    if ((self = [super init])) {
        
        // init the dictionary holding the discovered MIDINetworkSession services
        services = [[NSMutableDictionary alloc] initWithCapacity:8];
        
        // init the MIDI Network Session
        session = [MIDINetworkSession defaultSession];
        session.enabled = YES;
        session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
        
        // create MIDI client and ports
        CheckError (MIDIClientCreate(CFSTR("NetworkMIDI MIDI client"), MIDIClientNotifyProc, self, &client),
                    "Couldn't create MIDI client");
        
        CheckError (MIDIInputPortCreate(client, CFSTR("Input port"), MIDIInputReadProc, self, &inputPort),
                    "Couldn't create MIDI input port");
        
        CheckError(MIDIOutputPortCreate(client, CFSTR("Output Port"), &outputPort), 
                   "Couldn´t create MIDI output port");
        
        OSStatus status = MIDIPortConnectSource(inputPort, session.sourceEndpoint, self);
        if (status == noErr) {
            NSLog(@"Created MIDI client and ports");
        }
        
        // init the NetService Browser
        browser = [[NSNetServiceBrowser alloc] init];
        browser.delegate = self;
        [browser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@""];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(midiNetworkSessionUpdated:) 
                                                     name:MIDINetworkNotificationSessionDidChange 
                                                   object:nil];
    }
    return self;
}

+ (MidiController *) sharedInstance {
    @synchronized(self) {
        if (!_sharedInstance) {
            _sharedInstance = [[MidiController alloc] init];
        }
    }
    return _sharedInstance;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (inputPort)
        MIDIPortDispose(inputPort);
    inputPort = NULL;
    if (outputPort) 
        MIDIPortDispose(outputPort);
    self->outputPort = NULL;
    if (client)
        MIDIClientDispose(client);
    client = NULL;
    
    [browser release];
    [services release];
    
    [super dealloc];
}

#pragma mark - Connection management

- (void) midiNetworkSessionUpdated:(NSNotification*) notification {
    // DLog(@"Session updated: %@", notification);
    [[NSNotificationCenter defaultCenter] postNotificationName:MIDIControllerConnectionsChanged object:self];
}



@end
