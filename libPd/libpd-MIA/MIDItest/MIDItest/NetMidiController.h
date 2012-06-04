//
//  NetMidiController.h
//  MIDItest
//
//  Created by Kjartan Vestvik on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>	

@interface NetMidiController : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate> {
    
    NSNetServiceBrowser* browser;
    NSNetService* connectedService;
    BOOL isConnected;
    
    MIDINetworkSession* session;
    MIDINetworkHost* host;
    MIDIClientRef client;
    MIDIPortRef inputPort;
    MIDIPortRef outputPort;
    MIDIEndpointRef src;
    MIDIEndpointRef dest;
}

@property (readwrite, retain) NSNetServiceBrowser* browser;
@property (readwrite, retain) NSNetService* connectedService;
@property (readwrite, assign) BOOL isConnected;

-(NetMidiController*) init;
-(OSStatus) setupMIDI;

@end
