//
//  MIDItestViewController.h
//  MIDItest
//
//  Created by Kjartan Vestvik on 19.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetMidiController.h"

@interface MIDItestViewController : UIViewController {
    NetMidiController* midiController;
    
}

@property (nonatomic, retain) NetMidiController* midiController;



@end
