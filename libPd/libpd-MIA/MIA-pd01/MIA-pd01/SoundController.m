//
//  SoundController.m
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundController.h"
#import "SNFCoreAudioUtils.h"

#define SUCCESS 0
#define FILE_NAME @"2synths.pd"

@interface SoundController()

- (void) setupPd;
- (void) openAndRunTestPatch;
- (OSStatus) setUpMIDI;

@end


@implementation SoundController

@synthesize notePitch;


////////////////////////////////////
// Initialize the Sound Controller
//
- (SoundController*) init
{
    self = [super init];
    
    [self setUpMIDI];
    
    [self setupPd];
    [self openAndRunTestPatch];
    
    // debug
    BOOL result = [PdBase exists:@"fromPd"];
    if(result){
        NSLog(@"fromPd exists");
    } else {
        NSLog(@"fromPd exists not");
    }
    
    return self;
}


/////////////////////////////////////
// Setup PureData
//
- (void) setupPd
{
#if TARGET_IPHONE_SIMULATOR	
	int ticksPerBuffer = 8;  // No other value seems to work with the simulator.
#else
    int ticksPerBuffer = 32;
#endif
	
    // initialize PureData
    pdAudio = [[PdAudio alloc] initWithSampleRate:44100.0
                                andTicksPerBuffer:ticksPerBuffer
                         andNumberOfInputChannels:2
                        andNumberOfOutputChannels:2];
    
    // This class conforms to PdReceiverDelegate, because it is the delegate for PdBase
    // Set the delegate so this object can receive messages from PureData
    [PdBase setDelegate:self];
    
    // Subscribe messages from
    [PdBase subscribe:@"fromPd"];
}

- (void) openAndRunTestPatch 
{
    NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *bundlePath = [mainBundle bundlePath];
    NSString *res = [PdBase openFile:FILE_NAME path:bundlePath];
    
    [pdAudio play];
}



/////////////////////////////////////////
// Send methods to send messages to PD

// Temporary method to switch between the two instruments 
// in the PD-patch "audio_out"
- (void)switchInstrument
{
    [PdBase sendBangToReceiver:@"switch_instr"];
    NSLog(@"Instr switch!");
}

// This method should be implemented to select an instrument
- (void)selectInstrument:(int)instrument
{
    
}

- (void)sendNote:(int)note 
{
    
    if(![PdBase sendNoteOn:1 pitch:note velocity:127])
        NSLog(@"sendNoteOn failed");
}

- (void)playNote
{
    [PdBase sendBangToReceiver:@"playNote"];
}

- (void)updatePitch:(int)pitch
{
    //notePitch = pitch;
    [PdBase sendFloat:pitch toReceiver:@"notePitch"];
}



/////////////////////////////////////////
// Delegate methods for receiving messages from PD
//
- (void)receivePrint:(NSString *)message {
    NSLog(@"Print received: %@", message);
}

- (void)receiveBangFromSource:(NSString *)source {
    NSLog(@"Bang from source: %@", source);
}

- (void)receiveFloat:(float)received fromSource:(NSString *)source {
    NSLog(@"Float received: %f from source: %@", received, source);
}


#pragma mark - midi

//////////////////////////////////////////
//                  MIDI
// These methods handles setup of MIDI connections,
//  a readproc for incoming MIDI messages and 
//  a notifyproc for MIDI notifications
//

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon);
static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon);

-(OSStatus) setUpMIDI {
	
	//MIDIClientRef client;
	void* callbackContext = (__bridge void*) self;
	CheckError (MIDIClientCreate(CFSTR("Core MIDI to System Sounds Demo"), MyMIDINotifyProc, callbackContext, &client),
				"Couldn't create MIDI client");
	
	//MIDIPortRef inPort;
	CheckError (MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, callbackContext, &inPort),
				"Couldn't create MIDI input port");
	
	unsigned long sourceCount = MIDIGetNumberOfSources();
	printf ("%ld sources\n", sourceCount);
	for (int i = 0; i < sourceCount; ++i) {
		//MIDIEndpointRef src = MIDIGetSource(i);
        src = MIDIGetSource(i);
		CFStringRef endpointName = NULL;
		CheckError(MIDIObjectGetStringProperty(src, kMIDIPropertyName, &endpointName),
				   "Couldn't get endpoint name");
		char endpointNameC[255];
		CFStringGetCString(endpointName, endpointNameC, 255, kCFStringEncodingUTF8);
		printf("  source %d: %s\n", i, endpointNameC);
		MIDIPortConnectSource(inPort, src, NULL);
	}
    
    unsigned long destCount = MIDIGetNumberOfDestinations();
	printf ("%ld destinations\n", destCount);
    dest = MIDIGetDestination(0);
    CheckError(MIDIOutputPortCreate(client, 
                                    (CFStringRef)@"MidiMonitor Output Port", 
                                    &outPort), "Couldn´t create output MIDI port");
    
    
	return noErr;
	
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
	printf("MIDI Notify, messageId=%ld,", message->messageID);
}

static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
	// TODO: fix this
    //HelloWorldAUViewController *myVC = (__bridge HelloWorldAUViewController*) refCon;
	
	MIDIPacket *packet = (MIDIPacket *)pktlist->packet;	
	for (int i=0; i < pktlist->numPackets; i++) {
		Byte midiStatus = packet->data[0];
		Byte midiCommand = midiStatus >> 4;
		// is it a note-on or note-off
		if ((midiCommand == 0x09) ||
			(midiCommand == 0x08)) {
			Byte note = packet->data[1] & 0x7F;
			Byte velocity = packet->data[2] & 0x7F;
			printf("midiCommand=%d. Note=%d, Velocity=%d\n", midiCommand, note, velocity);
			
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
