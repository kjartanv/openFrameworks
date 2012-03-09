//
//  MIA_pd01ViewController.h
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundController.h"

@class SoundController;

@interface MIA_pd01ViewController : UIViewController {
    
    UISegmentedControl *instSelector;
    UISlider *pitchSlider;
    UIButton *playButton;
    UIButton *netButton;
    UIButton *connButton;
    UITextView *debugView;
    UITextField *netField;
    
    SoundController *soundController;
    NSString *previousMsg;
    NSString *hostToConnect;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *instSelector;
@property (nonatomic, retain) IBOutlet UISlider *pitchSlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;
@property (nonatomic, retain) IBOutlet UIButton *netButton;
@property (nonatomic, retain) IBOutlet UIButton *connButton;
@property (nonatomic, retain) IBOutlet UITextView *debugView;
@property (nonatomic, retain) IBOutlet UITextField *netField;

@property (nonatomic, retain) SoundController *soundController;
@property (retain) NSString *previousMsg;
@property (retain) NSString *hostToConnect;

-(void) addString:(NSString*)string;
-(IBAction)instSelectorChanged:(UISegmentedControl *)sender;
-(IBAction)pitchSliderChanged:(UISlider*)slider;
-(IBAction)playNote:(id)sender;
-(IBAction)showContact:(id)sender;
-(IBAction)connect:(id)sender;

- (void) displayMidiRec: (NSTimer *) timer;	

@end
