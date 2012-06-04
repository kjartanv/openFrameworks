//
//  SoundController.m
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 15.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SoundController.h"
#import "SNFCoreAudioUtils.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

#define SUCCESS 0
#define FILE_NAME @"Drummachine+synths.pd"

@interface SoundController()

- (void) setupPd;
- (void) openAndRunTestPatch;
- (OSStatus) setUpMIDI;

@end

@implementation SoundController

@synthesize netClient;
@synthesize hostList;

@synthesize isConnected;
@synthesize browser;
@synthesize connectedService;
@synthesize services;


////////////////////////////////////
// Initialize the Sound Controller
//
- (SoundController*) init
{
    self = [super init];
    
    sensorDelegate = [[[MiaSensorDelegate alloc] init] autorelease];
    NSThread* sensorThread = [[NSThread alloc] initWithTarget:sensorDelegate 
                                                     selector:@selector(update:::::::::) 
                                                       object:nil];
    //messageStruct.midiMessage = "None";
    strcpy(messageStruct.midiMessage, "None");
    [self setIsConnected:FALSE];
    
    [self setUpMIDI];
    
    [self setupPd];
    [self openAndRunTestPatch];
    
    // Start listening to motion sensor data
    [sensorThread start];  
    [sensorDelegate startAnimation];
    // Sjekk: http://stackoverflow.com/questions/4763307/iphone-starting-an-nsthread-from-a-c-object
    
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
// Getter and setter methods for struct
//

- (NSString*) getLastRecMsg
{
    NSString *string = [NSString stringWithUTF8String:messageStruct.midiMessage];
    return string;
}

-(void) setLastRecMsg:(NSString *)lastReceivedMsg
{
    //messageStruct.midiMessage = [lastReceivedMsg UTF8String];
    //char temp[64];
    strcpy(messageStruct.midiMessage, [lastReceivedMsg UTF8String]);
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
    
    // Subscribe to messages from PD
    [PdBase subscribe:@"fromPd"];
}

- (void) openAndRunTestPatch 
{
    NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *bundlePath = [mainBundle bundlePath];
    NSString *res = [PdBase openFile:FILE_NAME path:bundlePath];
    
    // selects the first instrument
    [PdBase sendFloat:1 toReceiver:@"switch_instr"];
    
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
    [PdBase sendFloat:instrument toReceiver:@"switch_instr"];
    NSLog(@"Instr switch: %d", instrument);
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

// Returns IP address of THIS device
- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

static
BOOL IsNetworkSession(MIDIEndpointRef ref)
{
    MIDIEntityRef entity = 0;
    MIDIEndpointGetEntity(ref, &entity);
    
    BOOL hasMidiRtpKey = NO;
    CFPropertyListRef properties = nil;
    OSStatus s = MIDIObjectGetProperties(entity, &properties, true);
    if (!s)
    {
        NSDictionary *dictionary = (NSDictionary*)properties;
        hasMidiRtpKey = [dictionary valueForKey:@"apple.midirtp.session"] != nil;
        CFRelease(properties);
    }
    
    return hasMidiRtpKey;
}

-(void)updateNetClient
{
    // contacts
    if (session.contacts.count != 0) {
        
        NSLog(@"contacts!");
        NSString *netString = @"Con: ";
        NSString *tempString = @"";
        for (host in session.contacts)
        {
            netString = [netString stringByAppendingString:host.name];
            NSLog(@"string: %@", netString);
            for (MIDINetworkConnection* conn in session.connections)
            {
                netString = [netString stringByAppendingString:@"-c-"];
            }
        }
        [self setNetClient:netString];
        hostList = netString;
    }
    else {
        NSLog(@"contacts count = 0");
    }
    // a connection has been made by another host
    if (session.connections.count != 0 && !isConnected) {
        [self setIsConnected:TRUE];
        NSLog(@"Connections!");
    }
    // a connection has been removed by another host
    else if (session.connections.count == 0 && isConnected) {
        [self setIsConnected:FALSE];
        NSLog(@"Connections count = 0");
    }
    NSLog(@"Connections: %u", session.connections.count);
    NSLog(@"\nnetCLient: %@", netClient);
}

// Returns the (first) host, other than itself, that can
// be connected to
-(NSString*)hostToConnect
{
    NSString *localHostName = [[UIDevice currentDevice] name];
    
    for (host in session.contacts) {
        if (![host.name isEqualToString:localHostName]) {
            return host.name;
        }
    }
    return @"None";
}

-(void)connectToHost:(NSString *)otherHost
{
    NSString *localHostName = [[UIDevice currentDevice] name];
    MIDINetworkConnection* conn;
    
    for (MIDINetworkHost *aHost in session.contacts) {
        
        if ([aHost.name isEqualToString:otherHost]) {
            NSLog(@"Found %@", otherHost);
            
            conn = [MIDINetworkConnection connectionWithHost:aHost];
            if (isConnected) {
                NSLog(@"Try to remove...");
                if([session removeConnection:conn]) {
                    NSLog(@"removed");
                    [self setIsConnected:FALSE];
                }
            } 
            else {
                [session addConnection:conn];
                [self setIsConnected:TRUE];
            }
        }
        // if another contact found that is not the given parameter, also connect to that
        else if (![aHost.name isEqualToString:otherHost] && ![aHost.name isEqualToString:localHostName]) {
            NSLog(@"Found %@", otherHost);
            
            conn = [MIDINetworkConnection connectionWithHost:aHost];
            [session addConnection:conn];
        }
    }
}

// Called from a NSThread
// Waits for some connection to be established with this app
// Not part of Bonjour/MIDI Network Session setup
- (void) waitForConnections:(id) argument {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    MIDINetworkSession *session1 = (MIDINetworkSession *)argument;
    BOOL found = NO;
    int cons = 0;
    
    while (!found) {
        NSSet *connections =[session1 connections];
        cons = [connections count];
        if (cons  > 0) {
            found = YES;
        } else {
            [NSThread sleepForTimeInterval:1];
        }
    }
    
    //[... do something with connections ....]
    [self setLastRecMsg:@"Connection ok!"];
    [self updateNetClient];
    [pool release];
}

#pragma mark MIDINetworkNotificationSessionDidChange notification
- (void)sessionDidChange:(NSNotification *)note
{
    NSLog(@"--sessionDidChange:%@", note);
    
    /*
    // populate array with all available contacts
    for (host in session.contacts) {
        [services addObject:host];
        NSLog(@"Added host:%a\n", host.name);
    }
    
    // empty the hostList string
    hostList = @"";
    
    for (host in services) {
        [hostList stringByAppendingString:host.name];
    }
    */
     
    //[self updateNetClient];
    //[mTableView reloadData];
}

#pragma mark Net Service Browser Delegate Methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didFindService:(NSNetService *)service moreComing:(BOOL)more
{
    [service retain];
    service.delegate = self;
    NSLog(@"--didFindService:%@", service.name);
    [service resolveWithTimeout:5];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)more
{
    if (service == self.connectedService)
    {
        self.isConnected = NO;
    }
    
    //MIDINetworkSession* session = [MIDINetworkSession defaultSession];
    MIDINetworkHost* toRemove = nil;
    
    for (MIDINetworkHost* theHost in session.contacts)
    {
        if ([theHost.name caseInsensitiveCompare:service.name] == NSOrderedSame)
        {
            toRemove = theHost;
            break;
        }
    }
    
    [session removeContact:toRemove];
    NSLog(@"--didRemoveService:%@", service.name);
    
    if (session.enabled)
    {
        //[mTableView reloadData];
    }
}

- (void)netServiceDidResolveAddress:(NSNetService *)service
{
    NSString *name = service.name;
    NSString *hostName = service.hostName;
    
    // Don't add the local machine
    NSString* localHostname = [[UIDevice currentDevice] name];
    
    NSRange textRange = [[hostName lowercaseString] rangeOfString:[localHostname lowercaseString]];
    
    if (textRange.location == NSNotFound)
    {
        // Now add the device....
        
        //MIDINetworkSession* session = [MIDINetworkSession defaultSession];
        MIDINetworkHost* contact = [MIDINetworkHost hostWithName:name netService:service];
        
        BOOL exists = NO;
        for (MIDINetworkHost* theHost in session.contacts)
        {
            if ([theHost.name caseInsensitiveCompare:name] == NSOrderedSame)
            {
                exists = YES;
                break;
            }
        }
        if (!exists)
        {
            [session addContact:contact];
            NSLog(@"--contact added:%@", contact.name);
            
            // add name of contact to array
            [services addObject:contact.name];
            // add name of contact to debug string
            //[hostList stringByAppendingString:contact.name];
        }
        
        if (session.enabled)
        {
            //[mTableView reloadData];
        }
    }
    
    [service release];
}

- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"Could not resolve: %@", errorDict);
}





//////////////////////////////////////////
//                  MIDI
// These methods handles setup of MIDI connections,
//  a readproc for incoming MIDI messages and 
//  a notifyproc for MIDI notifications
//

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon);
static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon);

-(OSStatus) setUpMIDI {
	
	void* callbackContext = (__bridge void*) self;
    
	CheckError (MIDIClientCreate(CFSTR("Core MIDI to System Sounds Demo"), MyMIDINotifyProc, callbackContext, &client),
				"Couldn't create MIDI client");
	
	//Create input port
	CheckError (MIDIInputPortCreate(client, CFSTR("Input port"), MyMIDIReadProc, callbackContext, &inPort),
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
		MIDIPortConnectSource(inPort, src, NULL);
        
        strcpy(messageStruct.midiMessage, endpointNameC);
        
	}
    
    unsigned long destCount = MIDIGetNumberOfDestinations();
	printf ("%ld destinations\n", destCount);
    dest = MIDIGetDestination(0);
    CheckError(MIDIOutputPortCreate(client, 
                                    (CFStringRef)@"MidiMonitor Output Port", 
                                    &outPort), "Couldn´t create output MIDI port");
    
    CFStringRef endpointDestName = NULL;
    CheckError(MIDIObjectGetStringProperty(dest, kMIDIPropertyName, &endpointDestName), "Couldn´t get enpoint dest name");
    char endpointDestNameC[255];
    CFStringGetCString(endpointDestName, endpointDestNameC, 255, kCFStringEncodingUTF8);
    //strcpy(messageStruct.midiMessage, endpointDestNameC);
    
    // Enable MIDI network session
    session = [MIDINetworkSession defaultSession];
    session.enabled = YES;
    session.connectionPolicy = MIDINetworkConnectionPolicy_Anyone;
    
    [self setNetClient:@"Empty"];
    
    if (IsNetworkSession(dest)) {
        NSString *netName = [session networkName]; // name of device (iPod)
        NSLog(netName);
        strcpy(messageStruct.midiMessage, "Network session ok!");
        
    }
    
    // Waits for others to connect
    //[NSThread detachNewThreadSelector:@selector(waitForConnections:) toTarget:self withObject:session];
    
    /////////////////////////////////////////////////////////
    // Bonjour setup (from Molten: MIDIController.m)
    NSMutableSet* set = [[NSMutableSet alloc] initWithSet:session.contacts];
    for (MIDINetworkHost* theHost in set)
    {
        [session removeContact:theHost];        // why??
    }
    [set release];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidChange:) name:MIDINetworkNotificationSessionDidChange object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionDidChange:) name:MIDINetworkNotificationContactsDidChange object:nil];
    
    // Start Bonjour browser
    services = [[NSMutableArray alloc] init];
    browser = [[NSNetServiceBrowser alloc] init];
    browser.delegate = self;
    [browser searchForServicesOfType:MIDINetworkBonjourServiceType inDomain:@""];
    
	return noErr;
}

void MyMIDINotifyProc (const MIDINotification  *message, void *refCon) {
    
    SoundController* mySoundController = (SoundController*)refCon;

	printf("MIDI Notify, messageId=%ld,", message->messageID);
    int n = mySoundController->session.contacts.count;
    printf("Contacts: %u\n", n);
    if (n > 0) {
        // do something
    }
}

static void	MyMIDIReadProc(const MIDIPacketList *pktlist, void *refCon, void *connRefCon) {
	
    SoundController* mySoundController = (SoundController*)refCon;
	
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
            //mySoundController->messageStruct.midiMessage = temp;
            strcpy(mySoundController->messageStruct.midiMessage, temp);
            
            //printf(" Msg: %s\n", mySoundController->messageStruct.midiMessage);
            
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

// Generates a random note number
UInt8 RandomNoteNumber() { return rand() / (RAND_MAX / 127); }

- (void) sendNotes {
    
    //const UInt8 note      = RandomNoteNumber();
    const UInt8 note      = 37;
    const UInt8 noteOn[]  = { 0x99, note, 127 };
    const UInt8 noteOff[] = { 0x89, note, 0   };
    
    [self sendBytes:noteOn size:sizeof(noteOn)];
    [NSThread sleepForTimeInterval:0.1];
    [self sendBytes:noteOff size:sizeof(noteOff)];
}

- (void) sendBytes:(const UInt8*)bytes size:(UInt32)size
{
    //NSLog(@"%s(%u bytes to core MIDI)", __func__, unsigned(size));
    assert(size < 65536);
    Byte packetBuffer[size+100];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet     = MIDIPacketListInit(packetList);
    packet = MIDIPacketListAdd(packetList, sizeof(packetBuffer), packet, 0, size, bytes);
    
    [self sendPacketList:packetList];
}

- (void) sendPacketList:(const MIDIPacketList *)packetList
{
    // DEBUG
    MIDIPacket *packet = (MIDIPacket *)packetList->packet;
    Byte midiStatus = packet->data[0];
    Byte midiCommand = midiStatus >> 4;
    // is it a note-on or note-off
    if ((midiCommand == 0x09) ||
        (midiCommand == 0x08)) {
        Byte note = packet->data[1] & 0x7F;
        Byte velocity = packet->data[2] & 0x7F;
        
        NSString *comStr = [NSString stringWithFormat:@"S: midiCommand=%d. Note=%d, Velocity=%d\n", 
                            midiCommand, note, velocity];
        //strcpy(messageStruct.midiMessage, "Send1");
        [self setLastRecMsg:comStr];
        
        //printf("midiCommand=%d. Note=%d, Velocity=%d\n", midiCommand, note, velocity);
    }
    
    CheckError(MIDISend(outPort, dest, packetList), "Error sending MIDI data");
}


- (void) dealloc
{
	[sensorDelegate stopAnimation];
    [sensorDelegate dealloc];
    [browser dealloc];
    [services dealloc];
    
	[super dealloc];
}




@end
