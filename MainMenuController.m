//
//  MainMenuController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import "MainMenuController.h"

@interface MainMenuController ()

@property IBOutlet NSSlider *mySlider;

- (IBAction)sliderUpdate:(id)sender;
- (IBAction)exit:(id)sender;

@end

@implementation MainMenuController

- (void)awakeFromNib{
    [self refresh];
}

- (void)refresh{
    [[self mySlider] setIntValue:[controls localBrightness]];
}

- (IBAction)sliderUpdate:(id)sender{
    int newValue = [sender intValue];
	[controls setBrightness: newValue];
}

- (IBAction)exit:(id)sender{
	exit(1);
}

@end