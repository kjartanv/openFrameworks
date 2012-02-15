//
//  MIA_pd01ViewController.h
//  MIA-pd01
//
//  Created by Kjartan Vestvik on 14.02.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SoundController.h"

@interface MIA_pd01ViewController : UIViewController {
    
    UISegmentedControl *instSelector;
    UISlider *pitchSlider;
    UIButton *playButton;
    
    SoundController *soundController;
}

@property (nonatomic, retain) IBOutlet UISegmentedControl *instSelector;
@property (nonatomic, retain) IBOutlet UISlider *pitchSlider;
@property (nonatomic, retain) IBOutlet UIButton *playButton;

@property (nonatomic, retain) SoundController *soundController;


-(IBAction)instSelectorChanged:(UISegmentedControl *)sender;
-(IBAction)pitchSliderChanged:(UISlider*)slider;
-(IBAction)playNote:(id)sender;

@end
