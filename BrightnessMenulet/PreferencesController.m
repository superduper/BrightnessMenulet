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
@property IBOutlet NSWindow *preferenceWindow;

@property NSDictionary* currentScreen;
@property (weak) IBOutlet NSPopUpButton *displayPopUpButton;

@property (weak) IBOutlet NSSlider* brightCSlider;
@property (weak) IBOutlet NSTextField* brightCTextField;
@property (weak) IBOutlet NSStepper* brightCStepper;
@property (weak) IBOutlet NSSlider* contCSlider;
@property (weak) IBOutlet NSTextField* contCTextField;
@property (weak) IBOutlet NSStepper* contCStepper;

@property (strong) NSArray* brightnessOutlets;
@property (strong) NSArray* contrastOutlets;

@end

@implementation PreferencesController

- (void)showWindow{
    // Must support OSX 10.8 or up because of loadNibNamed:owner:topLevelObjects
    if(![self preferenceWindow]){
        NSLog(@"Pref Window alloc");
        [[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self topLevelObjects:nil];

        _brightnessOutlets = @[_brightCSlider, _brightCTextField, _brightCStepper];
        _contrastOutlets = @[_contCSlider, _contCTextField, _contCStepper];
    }
    
    _preferenceWindow.delegate = self;
    
    [self refreshScreenPopUpList];
    
    [self updateBrightnessControls];
    [self updateContrastControls];
    
    // does not order front?
    [[self preferenceWindow] makeKeyAndOrderFront:self];
    
    // TODO: find a better way to actually make window Key AND Front
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)updateBrightnessControls{
    NSInteger currentBrightness = [_currentScreen[CurrentBrightness] integerValue];

    for(id brightnessOutlet in _brightnessOutlets){
        if(![brightnessOutlet isKindOfClass:[NSTextField class]])
            [brightnessOutlet setMaxValue:[_currentScreen[MaxBrightness] integerValue]];

        [brightnessOutlet setIntValue:currentBrightness];
    }
}

- (void)updateContrastControls{
    NSInteger currentContrast = [_currentScreen[CurrentContrast] integerValue];

    for(id contrastOutlet in _contrastOutlets){
        if(![contrastOutlet isKindOfClass:[NSTextField class]])
            [contrastOutlet setMaxValue:[_currentScreen[MaxContrast] integerValue]];

        [contrastOutlet setIntValue:currentContrast];
    }
}

- (void)refreshScreenPopUpList{
    [_displayPopUpButton removeAllItems];
    
    if([controls.screens count] == 0){
        [_displayPopUpButton setEnabled:NO];

        // makeObjectsPerformSelector:withObject: only allows NO because it is same as nil lol...
        [_brightnessOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        [_contrastOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        
        return;
    }
    
    for(NSDictionary* scr in controls.screens)
        [_displayPopUpButton addItemWithTitle:scr[Model]];
    
    if(!_brightCStepper.enabled)
        for(id outlet in [_brightnessOutlets arrayByAddingObjectsFromArray:_contrastOutlets])
            [outlet setEnabled:YES];

    [_displayPopUpButton selectItemAtIndex:0];
    NSString* cselect = [_displayPopUpButton titleOfSelectedItem];
    _currentScreen = [controls screenForDisplayName:cselect];
    
    [self updateBrightnessControls];
    [self updateContrastControls];
}

- (IBAction)didChangeDisplayMenu:(id)sender {
    NSString* selectedItem = _displayPopUpButton.titleOfSelectedItem;
    _currentScreen = [controls screenForDisplayName:selectedItem];
    
    if(_currentScreen){
        [self updateBrightnessControls];
        [self updateContrastControls];
    }else
        NSLog(@"Error: Could not find scr for %@", selectedItem);
}
- (IBAction)pressedRefreshDisp:(id)sender {
    [self refreshScreenPopUpList];
}

#pragma mark Brightness - IBActions

- (IBAction)brightnessSlider:(id)sender{
    [controls setScreen:_currentScreen brightness:[sender intValue]];
    [_brightCTextField setIntValue:[sender intValue]];
    [_brightCStepper setIntValue:[sender intValue]];
}

- (IBAction)brightnessTextBox:(id)sender{
    if([sender intValue] > [_currentScreen[MaxBrightness] intValue])
        return;

    [controls setScreen:_currentScreen brightness:[sender intValue]];
    [_brightCSlider setIntValue:[sender intValue]];
    [_brightCStepper setIntValue:[sender intValue]];
}

- (IBAction)brightnessStepper:(id)sender{
    [controls setScreen:_currentScreen brightness:[sender intValue]];
    [_brightCSlider setIntValue:[sender intValue]];
    [_brightCTextField setIntValue:[sender intValue]];
}

#pragma mark Contrast - IBActions
- (IBAction)contrastSlider:(id)sender{
    [controls setScreen:_currentScreen contrast:[sender intValue]];
    [_contCTextField setIntValue:[sender intValue]];
    [_contCStepper setIntValue:[sender intValue]];
}

- (IBAction)contrastTextBox:(id)sender{
    if([sender intValue] > [_currentScreen[MaxContrast] intValue])
        return;

    [controls setScreen:_currentScreen contrast:[sender intValue]];
    [[self contCSlider] setIntValue:[sender intValue]];
    [_contCStepper setIntValue:[sender intValue]];
}

- (IBAction)contrastStepper:(id)sender{
    [controls setScreen:_currentScreen contrast:[sender intValue]];
    [_contCSlider setIntValue:[sender intValue]];
    [_contCTextField setIntValue:[sender intValue]];
}

#pragma Mark preferencesWindow - Delegate

- (void)windowWillClose:(NSNotification *)notification {
    _brightnessOutlets = nil;
    _contrastOutlets = nil;
    _preferenceWindow = nil;

    NSLog(@"_preferenceWindow Dealloc");
}

@end
