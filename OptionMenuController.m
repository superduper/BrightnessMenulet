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

- (void)updateBrightContrastLabels;

- (IBAction)preferences:(id)sender;
- (IBAction)sliderUpdate:(id)sender;
- (IBAction)normalBrightness:(id)sender;
- (IBAction)lowBrightness:(id)sender;
- (IBAction)standardColor:(id)sender;
- (IBAction)sRGB:(id)sender;
- (IBAction)toggleOSDLock:(id)sender;
- (IBAction)exit:(id)sender;

@end

@implementation OptionMenuController

- (void)awakeFromNib{
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    [self updateBrightContrastLabels];
        
    int lock = [controls getOSDLock];
    if(lock == 2)
        [[self itemWithTag:2] setState:NSOffState];
    else
        [[self itemWithTag:2] setState:NSOnState];
}

- (void)refresh{
    [self updateBrightContrastLabels];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
}

- (void)updateBrightContrastLabels{
    NSString *format = [NSString stringWithFormat:@"B: %d - C: %d", [controls localBrightness], [controls localContrast]];
    [[self brightnessContrastLabel] setTitle:format];
    
    [[self preferencesController] updateBrightnessControls];
    [[self preferencesController] updateContrastControls];
}

- (IBAction)preferences:(id)sender{
    if([self preferencesController] == nil)
        [self setPreferencesController:[[PreferencesController alloc] init]];
    
    [[self preferencesController] showWindow];
}

- (IBAction)sliderUpdate:(id)sender{
    [controls setBrightness:[sender intValue]];
    [self updateBrightContrastLabels];
}

// These are my own prefered settings for my Dell U2414h
// TODO: Add custom presets capability
- (IBAction)normalBrightness:(id)sender{
    [controls setBrightness:20];
    [controls setContrast:75];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    [self updateBrightContrastLabels];
}

- (IBAction)lowBrightness:(id)sender{
    [controls setBrightness:0];
    [controls setContrast:75];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    [self updateBrightContrastLabels];
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
