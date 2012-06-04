//
//  MidiController.h
//  MIAtab
//
//  Created by Kjartan Vestvik on 28.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMIDI/CoreMIDI.h>

#define MIDIControllerConnectionsChanged @"MIDIControllerConnectionsChanged"

@interface MidiController : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate> {

    NSMutableDictionary* services;
    MIDINetworkSession *session;
    NSNetServiceBrowser* browser;

    MIDIClientRef client;
    MIDIPortRef inputPort;
    MIDIPortRef outputPort;

}

@property (nonatomic, readonly) NSMutableDictionary* services;

+ (MidiController*) sharedInstance;

@end
