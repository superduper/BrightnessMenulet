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

@end

@implementation MainMenuController

- (void)awakeFromNib{
    [self refresh];
}

- (void)refresh{
    [[self mySlider] setIntValue:[controls localBrightness]];
}

- (IBAction)sliderUpdate:(id)sender{
	[controls setBrightness: [sender intValue]];
}

@end
