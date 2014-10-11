//
//  OptionMenuController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/9/14.
//
//

#import "OptionMenuController.h"

@interface OptionMenuController ()

@property PreferencesController *preferencesController;

@property IBOutlet NSSlider *brightnessSlider;
@property IBOutlet NSMenuItem *brightnessContrastLabel;

@end

@implementation OptionMenuController

- (void)awakeFromNib{
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    [self updateBrightContrastLabel];
        
    int lock = [controls getOSDLock];
    if(lock == 2)
        [[self itemWithTag:2] setState:NSOffState];
    else
        [[self itemWithTag:2] setState:NSOnState];
}

- (void)refresh{
    [self updateBrightContrastLabel];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
}

- (void)updateBrightContrastLabel{
    NSString *format = [NSString stringWithFormat:@"B: %d - C: %d", [controls localBrightness], [controls localContrast]];
    [[self brightnessContrastLabel] setTitle:format];
}

- (IBAction)preferences:(id)sender{
    if([self preferencesController] == nil){
        [self setPreferencesController:[[PreferencesController alloc] init]];
    }
    
    [[self preferencesController] showWindow];
}

- (IBAction)sliderUpdate:(id)sender{
    int newValue = [sender intValue];
    [controls setBrightness: newValue];
    [self updateBrightContrastLabel];
}

- (IBAction)normalBrightness:(id)sender{
    [controls setBrightness:20];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    [self updateBrightContrastLabel];
}

- (IBAction)lowBrightness:(id)sender{
    [controls setBrightness:0];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    [self updateBrightContrastLabel];
}

- (IBAction)standardColor:(id)sender{
    [controls setPreset:1];                 // Sets to standard preset
}

- (IBAction)sRGB:(id)sender{
    [controls changeControl:0x14 withValue:1];
}

- (IBAction)toggleOSDLock:(id)sender{
    [controls setOSDLock: ([controls getOSDLock] == 1 ? 2 : 1)];
    if([controls getOSDLock] == 2)
        [[self itemWithTag:2] setState:NSOffState];
    else
        [[self itemWithTag:2] setState:NSOnState];
}

- (IBAction)exit:(id)sender{
    exit(1);
}

@end
