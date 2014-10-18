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

@property IBOutlet NSComboBox *colorPresetComboBox;

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

- (IBAction)brightnessSlider:(id)sender;
- (IBAction)brightnessTextBox:(id)sender;
- (IBAction)brightnessStepper:(id)sender;

- (IBAction)contrastSlider:(id)sender;
- (IBAction)contrastTextBox:(id)sender;
- (IBAction)contrastStepper:(id)sender;

- (IBAction)redSlider:(id)sender;
- (IBAction)redTextBox:(id)sender;
- (IBAction)redStepper:(id)sender;

- (IBAction)greenSlider:(id)sender;
- (IBAction)greenTextBox:(id)sender;
- (IBAction)greenStepper:(id)sender;

- (IBAction)blueSlider:(id)sender;
- (IBAction)blueTextBox:(id)sender;
- (IBAction)blueStepper:(id)sender;

@end

@implementation PreferencesController

- (void)showWindow{
    // Must support OSX 10.8 or up because of this loadNibNamed:owner:topLevelObjects
    if(![self preferenceWindow]){
        [[NSBundle mainBundle] loadNibNamed:@"Preferences"
                                      owner:self
                            topLevelObjects:nil];
        
        // colorPreset Combobox options initilized here
        NSArray *arr = [NSArray arrayWithObjects:@"Standard", @"sRGB", nil];
        [[self colorPresetComboBox] removeAllItems];
        [[self colorPresetComboBox] addItemsWithObjectValues:arr];
    }
    
    [self updateBrightnessControls];
    [self updateContrastControls];
    [self updateRGBControls];
    
    // TODO: does not order front?
    [[self preferenceWindow] makeKeyAndOrderFront:self];
    
    // TODO: find a better way to actually make window Key AND Front
    [NSApp activateIgnoringOtherApps:YES];
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
- (void)updateRGBControls{
    [self updateRedControls];
    [self updateGreenControls];
    [self updateBlueControls];
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

#pragma mark Preset - IBActions
- (IBAction)changedPreset:(id)sender{
    [controls performSelector:@selector(setColorPresetByString:) withObject:[sender stringValue]];
    
    // Certian parameters may need to be refreshed
    [self updateBrightnessControls];
    [self updateContrastControls];
    [self updateRGBControls];
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
