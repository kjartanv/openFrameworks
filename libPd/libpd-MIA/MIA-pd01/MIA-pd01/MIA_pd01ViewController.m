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
@synthesize soundController = _soundController;


-(IBAction)instSelectorChanged:(UISegmentedControl *)sender
{
    //int instr = sender.selectedSegmentIndex;
    
    [self.soundController switchInstrument];
}

-(IBAction)pitchSliderChanged:(UISlider *)slider
{
    //self.soundController.notePitch = (int)slider.value;
    
    [self.soundController updatePitch:(int)slider.value];
}

-(IBAction)playNote:(id)sender
{
    [self.soundController playNote];
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
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
