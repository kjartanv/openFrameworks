//
//  MIA_pd01ViewController.m
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MIA_pd01ViewController.h"

@implementation MIA_pd01ViewController

@synthesize instSelector;
@synthesize pitchSlider;
@synthesize playButton;
@synthesize netButton;
@synthesize connButton;
@synthesize debugView;
@synthesize netField;
@synthesize soundController = _soundController;
@synthesize previousMsg;
@synthesize hostToConnect;


-(IBAction)instSelectorChanged:(UISegmentedControl *)sender
{
    // Convert to index starting at 1 instead of 0
    int instr = sender.selectedSegmentIndex + 1;
    [self.soundController selectInstrument:instr];
    
    // old method
    //[self.soundController switchInstrument];
}

-(IBAction)pitchSliderChanged:(UISlider *)slider
{
    //self.soundController.notePitch = (int)slider.value;
    
    [self.soundController updatePitch:(int)slider.value];
}

-(IBAction)playNote:(id)sender
{
    [self.soundController playNote];
    [self.soundController sendNotes];
}

-(IBAction)showContact:(id)sender
{
    [self.soundController updateNetClient];
    [self setHostToConnect:[self.soundController hostToConnect]];
    //netField.text = [self.soundController hostToConnect];
    netField.text = [self.soundController hostList];
    
}

-(IBAction)connect:(id)sender
{
    [self.soundController connectToHost:[self hostToConnect]];
}


- (void) addString:(NSString*)string
{
    NSString *newText = [debugView.text stringByAppendingFormat:@"\n%@", string];
    debugView.text = newText;
    
    if (newText.length)
        [debugView scrollRangeToVisible:(NSRange){newText.length-1, 1}];
}


// Timer callback method
// to update the textView with info about
// received MIDI data
- (void) displayMidiRec:(NSTimer *)timer {

    NSString *receivedMsg = [NSString string];
    receivedMsg = [[timer userInfo] getLastRecMsg];
    if (![receivedMsg isEqualToString:previousMsg]) {
        [self addString:receivedMsg];
        
        [self setPreviousMsg:receivedMsg];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SoundController *newSoundController = [[SoundController alloc] init];
    self.soundController = newSoundController;
    [newSoundController release];
    
    debugView.text = nil;
    //previousMsg = @"Message 1";
    //NSValue* val = [NSValue valueWithPointer:self.soundController.messageStruct];
    [NSTimer scheduledTimerWithTimeInterval:0.3
									 target:self
								   selector:@selector(displayMidiRec:)
								   userInfo:self.soundController
									repeats: YES];

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [soundController release];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}



/*
- (void) openAndRunTestPatch
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	[PdBase openFile:@"audio_out.pd" path:documentsDirectory];
	[PdBase computeAudio:YES];
	[pdAudio play];	
}

- (void) copyDemoPatchesToUserDomain
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *fileError;
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *bundlePath = [mainBundle bundlePath];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSArray *bundleFiles = [fm contentsOfDirectoryAtPath:bundlePath error:&fileError];
	
	for( NSString *patchFile in bundleFiles )
	{
		if ([[patchFile pathExtension] isEqualToString:patchFileTypeExtension ])
		{
			NSString *bundlePatchFilePath = [bundlePath stringByAppendingPathComponent:patchFile]; 
			NSString *documentsPatchFilePath = [documentsDirectory stringByAppendingPathComponent:patchFile];
			
			if ([fm fileExistsAtPath:bundlePatchFilePath]) 
			{
				if( ![fm fileExistsAtPath:documentsPatchFilePath] )
					if( ![fm copyItemAtPath:bundlePatchFilePath toPath: documentsPatchFilePath error:&fileError] )
						NSLog(@"Error copying demo patch:%@", [fileError localizedDescription]);
			} 
		}
	}
}
 */


@end
