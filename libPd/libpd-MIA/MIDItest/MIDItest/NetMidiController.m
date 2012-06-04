//
//  NetMidiController.m
//  MIDItest
//
//  Created by Kjartan Vestvik on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NetMidiController.h"
#import "SNFCoreAudioUtils.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@implementation NetMidiController

@synthesize browser;
@synthesize connectedService;
@synthesize isConnected;

void MIDIClientNotifyProc(const MIDINotification *message, void *refCon);
static void MIDIInputReadProc(const MIDIPacketList *pktlist, void *readProcRefCon, void *srcConnRefCon);


-(NetMidiController*)init {
    self = [super init];
    
    [self setupMIDI];
    
    return self;
}

#pragma mark MIDINetworkNotificationSessionDidChange notification
- (void)sessionDidChange:(NSNotification *)note
{
    NSLog(@"--sessionDidChange:%@", note);
}


-(OSStatus)setupMIDI {
    
    void* callbackContext = (__bridge void*) self;
    
	CheckError (MIDIClientCreate(CFSTR("Core MIDI to System Sounds Demo"), MIDIClientNotifyProc, callbackContext, &client),
				"Couldn't create MIDI client");
	
	//Create input port
	CheckError (MIDIInputPortCreate(client, CFSTR("Input port"), MIDIInputReadProc, callbackContext, &inputPort),
				"Couldn't create MIDI input port");
	
	unsigned long sourceCount = MIDIGetNumberOfSources();
	printf ("%ld sources\n", sourceCount);
	for (int i = 0; i < sourceCount; ++i) {
        src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		CheckError(MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName),
				   "Couldn't get endpoint name");
		char endpointNameC[255];
		CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
		printf("  source %d: %s\n", i, endpointNameC);
		MIDIPortConnectSource(inputPort, src, NULL);
        
	}
    
    unsigned long destCount = MIDIGetNumberOfDestinations();
	printf ("%ld destinations\n", destCount);
    dest = MIDIGetDestination(0);
    CheckError(MIDIOutputPortCreate(client, 
                                    (CFStringRef)@"MidiMonitor Output Port", 
                                    &outputPort), "Couldn´t create output MIDI port");
    
    CFStringRef endpointDestName = NULL;
    CheckError(MIDIObjectGetStringProperty(dest, kMIDIPropertyName, &endpointDestName), "Couldn´t get enpoint dest name");
    char endpointDestNameC[255];
    CFStringGetCString(endpointDestName, endpointDestNameC, 255, kCFStringEncodingUTF8);
    
    // Enable MIDI network session
    session = [MIDINetworkSession defaultSession];
    session.enabled = YES;
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidChange:) name:MIDINetworkNotificationSessionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidChange:) name:MIDINetworkNotificationContactsDidChange object:nil];
    
    return noErr;
}


////////////////////////////
// MIDI Callbacks

void MIDIClientNotifyProc (const MIDINotification  *message, void *refCon) {
    
    NetMidiController* myNetController = (NetMidiController*)refCon;
    
	printf("MIDI Notify, messageId=%ld,", message->messageID);
    int n = myNetController->session.contacts.count;
    printf("Contacts: %u\n", n);
    if (n > 0) {
        // do something
    }
}

static void	MIDIInputReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
	
    NetMidiController* myNetController = (NetMidiController*)refCon;
	
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;	
	for (int i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
		// is it a note-on or note-off
		if ((midiCommand == 0x09) ||
			(midiCommand == 0x08)) {
			Byte note = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
			printf("R: midiCommand=%d. Note=%d, Velocity=%d\n", midiCommand, note, velocity);
			
            char temp[256];
            snprintf(temp, sizeof(temp), "%s%d%s%d%s%d",
                     "R: midiCom=", midiCommand, 
                     " Note=", note,
                     " Velo=", velocity);
            
			// send to augraph
            // TODO: fix
            /*
             CheckError(MusicDeviceMIDIEvent (myVC.auSampler,
             midiStatus,
             note,
             velocity,
             0), 
             "Couldn't send MIDI event");
             */
		}
		packet = MIDIPacketNext(packet);
	}
}



@end
