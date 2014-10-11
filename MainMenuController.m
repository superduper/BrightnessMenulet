//
//  MainMenuController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import "MainMenuController.h"

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