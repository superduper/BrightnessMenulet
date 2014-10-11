//
//  PreferencesController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/8/14.
//
//

#import "PreferencesController.h"

@interface PreferencesController ()

// If only OSX supported IBOutlet​Collection...

@property IBOutlet NSSlider *brightnessSlider;
@property IBOutlet NSTextField *brightnessTextField;
@property IBOutlet NSStepper *brightnessStepper;
@property IBOutlet NSSlider *contrastSlider;
@property IBOutlet NSTextField *contrastTextField;
@property IBOutlet NSStepper *contrastStepper;
@property IBOutlet NSSlider *redSlider;
@property IBOutlet NSTextField *redTextField;
@property IBOutlet NSStepper *redStepper;
@property IBOutlet NSSlider *greenSlider;
@property IBOutlet NSTextField *greenTextField;
@property IBOutlet NSStepper *greenStepper;
@property IBOutlet NSSlider *blueSlider;
@property IBOutlet NSTextField *blueTextField;
@property IBOutlet NSStepper *blueStepper;

@property IBOutlet NSWindow *preferenceWindow;

@end

@implementation PreferencesController

- (void)windowDidLoad {
    [super windowDidLoad];
}

- (void)showWindow{
    if(![self preferenceWindow])
        [NSBundle loadNibNamed:@"Preferences" owner:self];
    
    [[self preferenceWindow] setTitle:@"Brightness Menulet"];
    
    [self updateBrightnessControls];
    [self updateContrastControls];
    [self updateRedControls];
    [self updateGreenControls];
    [self updateBlueControls];
    
    [[self preferenceWindow] makeKeyAndOrderFront:self];
}

- (void)updateBrightnessControls{
    int currentBrightness = [controls localBrightness];
    [[self brightnessSlider] setIntValue:currentBrightness];
    [[self brightnessTextField] setIntValue:currentBrightness];
    [[self brightnessStepper] setIntValue:currentBrightness];
}

- (void)updateContrastControls{
    int currentContrast = [controls localContrast];
    [[self contrastSlider] setIntValue:currentContrast];
    [[self contrastTextField] setIntValue:currentContrast];
    [[self contrastStepper] setIntValue:currentContrast];
}

- (void)updateRedControls{
    int currentRed = [controls getRed];
    [[self redSlider] setIntValue:currentRed];
    [[self redTextField] setIntValue:currentRed];
    [[self redStepper] setIntValue:currentRed];
}

- (void)updateGreenControls{
    int currentGreen = [controls getGreen];
    [[self greenSlider] setIntValue:currentGreen];
    [[self greenTextField] setIntValue:currentGreen];
    [[self greenStepper] setIntValue:currentGreen];
}

- (void)updateBlueControls{
    int currentBlue = [controls getBlue];
    [[self blueSlider] setIntValue:currentBlue];
    [[self blueTextField] setIntValue:currentBlue];
    [[self blueStepper] setIntValue:currentBlue];
}

#pragma mark Brightness - IBActions

- (IBAction)brightnessSlider:(id)sender{
    [controls setBrightness:[sender intValue]];
    [self updateBrightnessControls];
}

- (IBAction)brightnessTextBox:(id)sender{
    [controls setBrightness:[sender intValue]];
    [self updateBrightnessControls];
}

- (IBAction)brightnessStepper:(id)sender{
    [controls setBrightness:[sender intValue]];
    [self updateBrightnessControls];
}

#pragma mark Contrast - IBActions

- (IBAction)contrastSlider:(id)sender{
    [controls setContrast:[sender intValue]];
    [self updateContrastControls];
}

- (IBAction)contrastTextBox:(id)sender{
    [controls setContrast:[sender intValue]];
    [self updateContrastControls];
}

- (IBAction)contrastStepper:(id)sender{
    [controls setContrast:[sender intValue]];
    [self updateContrastControls];
}

#pragma mark RGB - IBActions

- (IBAction)redSlider:(id)sender{
    [controls setRed:[sender intValue]];
    [self updateRedControls];
}

- (IBAction)redTextBox:(id)sender{
    [controls setRed:[sender intValue]];
    [self updateRedControls];
}

- (IBAction)redStepper:(id)sender{
    [controls setRed:[sender intValue]];
    [self updateRedControls];
}

- (IBAction)greenSlider:(id)sender{
    [controls setGreen:[sender intValue]];
    [[self greenTextField] setIntValue:[sender intValue]];
}

- (IBAction)greenTextBox:(id)sender{
    [controls setGreen:[sender intValue]];
    [[self greenTextField] setIntValue:[sender intValue]];
}

- (IBAction)greenStepper:(id)sender{
    [controls setGreen:[sender intValue]];
    [[self greenTextField] setIntValue:[sender intValue]];
}

- (IBAction)blueSlider:(id)sender{
    [controls setBlue:[sender intValue]];
    [[self blueTextField] setIntValue:[sender intValue]];
}

- (IBAction)blueTextBox:(id)sender{
    [controls setBlue:[sender intValue]];
    [[self blueTextField] setIntValue:[sender intValue]];
}

- (IBAction)blueStepper:(id)sender{
    [controls setBlue:[sender intValue]];
    [[self blueTextField] setIntValue:[sender intValue]];
}

@end
