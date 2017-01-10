//
//  PreferencesController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/8/14.
//
//

#import "Screen.h"
#import "PreferencesController.h"

@interface PreferencesController () <NSWindowDelegate>

@property IBOutlet NSWindow *preferenceWindow;

@property Screen* currentScreen;
@property (weak) IBOutlet NSPopUpButton *displayPopUpButton;

// Brightness and Contrast IBOutlets
@property (weak) IBOutlet NSSlider* brightCSlider;
@property (weak) IBOutlet NSTextField* brightCTextField;
@property (weak) IBOutlet NSStepper* brightCStepper;
@property (weak) IBOutlet NSSlider* contCSlider;
@property (weak) IBOutlet NSTextField* contCTextField;
@property (weak) IBOutlet NSStepper* contCStepper;

// RGB Colors
@property (weak) IBOutlet NSSlider* redCSlider;
@property (weak) IBOutlet NSTextField* redCTextField;
@property (weak) IBOutlet NSStepper* redCStepper;
@property (weak) IBOutlet NSSlider* greenCSlider;
@property (weak) IBOutlet NSTextField* greenCTextField;
@property (weak) IBOutlet NSStepper* greenCStepper;
@property (weak) IBOutlet NSSlider* blueCSlider;
@property (weak) IBOutlet NSTextField* blueCTextField;
@property (weak) IBOutlet NSStepper* blueCStepper;

// If only OSX supported IBOutlet​Collection...
@property (strong) NSArray* brightnessOutlets;
@property (strong) NSArray* contrastOutlets;
@property (strong) NSArray* redOutlets;
@property (strong) NSArray* greenOutlets;
@property (strong) NSArray* blueOutlets;

// Auto-Brightness IBOutlets
@property (weak) IBOutlet NSButton *autoBrightOnStartupButton;

@property (weak) IBOutlet NSSlider *updateIntervalSlider;
@property (weak) IBOutlet NSTextField *updateIntTextField;
@property (weak) IBOutlet NSStepper *updateIntStepper;

@property (strong) NSArray* updateIntervalOutlets;

@end

@implementation PreferencesController

- (void)showWindow {
    // Must support atleast OSX 10.8 because of loadNibNamed:owner:topLevelObjects
    if(!_preferenceWindow){
        NSLog(@"PreferencesController: Pref Window alloc");
        [[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self topLevelObjects:nil];
        
        // Save the last location (to fix a xcode bug, we have to set this here)
        _preferenceWindow.frameAutosaveName = @"PreferencesWindowLocation";
        
        _preferenceWindow.delegate = self;

        NSNumberFormatter* decFormater = [[NSNumberFormatter alloc] init];
        [decFormater setNumberStyle:NSNumberFormatterDecimalStyle];

        [_brightCTextField setFormatter:decFormater];
        [_contCTextField   setFormatter:decFormater];
        
        [_redCTextField    setFormatter:decFormater];
        [_greenCTextField  setFormatter:decFormater];
        [_blueCTextField   setFormatter:decFormater];

        _brightnessOutlets = @[_brightCSlider, _brightCTextField, _brightCStepper];
        _contrastOutlets   = @[_contCSlider, _contCTextField, _contCStepper];
        
        _redOutlets   = @[_redCSlider, _redCTextField, _redCStepper];
        _greenOutlets = @[_greenCSlider, _greenCTextField, _greenCStepper];
        _blueOutlets  = @[_blueCSlider, _blueCTextField, _blueCStepper];

        _updateIntervalOutlets = @[_updateIntervalSlider, _updateIntTextField, _updateIntStepper];

        _updateIntervalSlider.maxValue = 4.0;
        _updateIntervalSlider.minValue = 0.1;
        _updateIntStepper.maxValue = _updateIntervalSlider.maxValue;
        _updateIntStepper.minValue = _updateIntervalSlider.minValue;
        _updateIntStepper.increment = 0.5;

        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        float updateInterval = [defaults floatForKey:@"LMUUpdateInterval"];

        if(updateInterval <= 0)
            updateInterval = 0.1;

        for(id outlet in _updateIntervalOutlets)
            [outlet setFloatValue:updateInterval];
    }

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [_autoBrightOnStartupButton setState:([defaults boolForKey:@"autoBrightOnStartup"])];

    [self refreshScreenPopUpList];
    
    [self updateBrightnessControls];
    [self updateContrastControls];
    
    [self updateRedControls];
    [self updateGreenControls];
    [self updateBlueControls];

    [[self preferenceWindow] makeKeyAndOrderFront:self];    // does not order front?
    
    // TODO: find a better way to actually make window Key AND Front
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)updateBrightnessControls {
    NSInteger currentBrightness = _currentScreen.currentBrightness;

    for(id brightnessOutlet in _brightnessOutlets){
        if(![brightnessOutlet isKindOfClass:[NSTextField class]])
            [brightnessOutlet setMaxValue:_currentScreen.maxBrightness];

        [brightnessOutlet setIntValue:currentBrightness];
    }
}

- (void)updateContrastControls {
    NSInteger currentContrast = _currentScreen.currentContrast;

    for(id contrastOutlet in _contrastOutlets){
        if(![contrastOutlet isKindOfClass:[NSTextField class]])
            [contrastOutlet setMaxValue:_currentScreen.maxContrast];

        [contrastOutlet setIntValue:currentContrast];
    }
}

- (void)updateRedControls {
    NSInteger currentRed = _currentScreen.currentRed;
    
    for(id redOutlet in _redOutlets){
        if(![redOutlet isKindOfClass:[NSTextField class]])
            [redOutlet setMaxValue:_currentScreen.maxRed];
        
        [redOutlet setIntValue:currentRed];
    }
}
- (void)updateGreenControls {
    NSInteger currentGreen = _currentScreen.currentGreen;
    
    for(id greenOutlet in _greenOutlets){
        if(![greenOutlet isKindOfClass:[NSTextField class]])
            [greenOutlet setMaxValue:_currentScreen.maxGreen];
        
        [greenOutlet setIntValue:currentGreen];
    }
}

- (void)updateBlueControls {
    NSInteger currentBlue = _currentScreen.currentBlue;
    
    for(id blueOutlet in _blueOutlets){
        if(![blueOutlet isKindOfClass:[NSTextField class]])
            [blueOutlet setMaxValue:_currentScreen.maxBlue];
        
        [blueOutlet setIntValue:currentBlue];
    }
}



- (void)refreshScreenPopUpList {
    // Reset Variables
    [_displayPopUpButton removeAllItems];
    [_currentScreen.brightnessOutlets removeObjectsInArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets removeObjectsInArray:_contrastOutlets];
    
    [_currentScreen.redOutlets removeObjectsInArray:_redOutlets];
    [_currentScreen.greenOutlets removeObjectsInArray:_greenOutlets];
    [_currentScreen.blueOutlets removeObjectsInArray:_blueOutlets];
    
    if([controls.screens count] == 0){
        // no screens so disable outlets
        [_displayPopUpButton setEnabled:NO];

        // makeObjectsPerformSelector:withObject: only allows NO because it is same as nil lol...
        [_brightnessOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        [_contrastOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        [_redOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        [_greenOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        [_blueOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        return;
    }

    // Add new screens
    for(Screen* screen in controls.screens)
        [_displayPopUpButton addItemWithTitle:screen.model];
    
    if(!_brightCStepper.enabled)
        for(id outlet in [_brightnessOutlets arrayByAddingObjectsFromArray:_contrastOutlets])
            [outlet setEnabled:YES];

    [_displayPopUpButton selectItemAtIndex:0];
    NSString* cselect = [_displayPopUpButton titleOfSelectedItem];
    _currentScreen = [controls screenForDisplayName:cselect];

    // Add outlets to new _currentScreen
    [_currentScreen.brightnessOutlets addObjectsFromArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets addObjectsFromArray:_contrastOutlets];
    
    [_currentScreen.redOutlets addObjectsFromArray:_redOutlets];
    [_currentScreen.greenOutlets addObjectsFromArray:_greenOutlets];
    [_currentScreen.blueOutlets addObjectsFromArray:_blueOutlets];
    
    [self updateBrightnessControls];
    [self updateContrastControls];
    [self updateRedControls];
    [self updateGreenControls];
    [self updateBlueControls];
}

#pragma mark - Brightness and Contrast IBActions

- (IBAction)didChangeDisplayMenu:(id)sender {
    NSString* selectedItem = _displayPopUpButton.titleOfSelectedItem;

    // remove outlets from old screen
    [_currentScreen.brightnessOutlets removeObjectsInArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets removeObjectsInArray:_contrastOutlets];
    
    [_currentScreen.redOutlets removeObjectsInArray:_redOutlets];
    [_currentScreen.greenOutlets removeObjectsInArray:_greenOutlets];
    [_currentScreen.blueOutlets removeObjectsInArray:_blueOutlets];

    _currentScreen = [controls screenForDisplayName:selectedItem];

    // Add outlets to new _currentScreen
    [_currentScreen.brightnessOutlets addObjectsFromArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets addObjectsFromArray:_contrastOutlets];
    
    [_currentScreen.redOutlets addObjectsFromArray:_redOutlets];
    [_currentScreen.greenOutlets addObjectsFromArray:_greenOutlets];
    [_currentScreen.blueOutlets addObjectsFromArray:_blueOutlets];

    [self updateBrightnessControls];
    [self updateContrastControls];
    [self updateRedControls];
    [self updateGreenControls];
    [self updateBlueControls];
}

- (IBAction)pressedDebug:(NSButton *)sender {
    [_currentScreen ddcReadOut];
}

- (IBAction)pressedRefreshDisp:(id)sender {
    [self refreshScreenPopUpList];
}

- (IBAction)brightnessOutletValueChanged:(id)sender{
    [_currentScreen setBrightness:[sender integerValue] byOutlet:sender];

    NSMutableArray* dirtyOutlets = [_brightnessOutlets mutableCopy];
    [dirtyOutlets removeObject:sender];

    for(id outlet in dirtyOutlets)
        [outlet setIntegerValue:[sender integerValue]];
}

- (IBAction)contrastOutletValueChanged:(id)sender{
    [_currentScreen setContrast:[sender integerValue] byOutlet:sender];

    NSMutableArray* dirtyOutlets = [_contrastOutlets mutableCopy];
    [dirtyOutlets removeObject:sender];

    for(id outlet in dirtyOutlets)
        [outlet setIntegerValue:[sender integerValue]];
}

- (IBAction)redOutletValueChanged:(id)sender{
    [_currentScreen setRed:[sender integerValue] byOutlet:sender];
    
    NSMutableArray* dirtyOutlets = [_redOutlets mutableCopy];
    [dirtyOutlets removeObject:sender];
    
    for(id outlet in dirtyOutlets)
        [outlet setIntegerValue:[sender integerValue]];
}

- (IBAction)greenOutletValueChanged:(id)sender{
    [_currentScreen setGreen:[sender integerValue] byOutlet:sender];
    
    NSMutableArray* dirtyOutlets = [_greenOutlets mutableCopy];
    [dirtyOutlets removeObject:sender];
    
    for(id outlet in dirtyOutlets)
        [outlet setIntegerValue:[sender integerValue]];
}

- (IBAction)blueOutletValueChanged:(id)sender{
    [_currentScreen setBlue:[sender integerValue] byOutlet:sender];
    
    NSMutableArray* dirtyOutlets = [_blueOutlets mutableCopy];
    [dirtyOutlets removeObject:sender];
    
    for(id outlet in dirtyOutlets)
        [outlet setIntegerValue:[sender integerValue]];
}

#pragma mark - Auto-Brightness IBActions

- (IBAction)didToggleAutoBrightOnStartupButton:(NSButton*)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    [defaults setBool:(sender.state == NSOnState ? YES : NO) forKey:@"autoBrightOnStartup"];
}

- (IBAction)updateIntOutletValueChanged:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    float value = [sender floatValue];

    if(value > _updateIntervalSlider.maxValue)
        value = _updateIntervalSlider.maxValue;
    else if(value <= 0)
        value = 0.1;

    [defaults setFloat:value forKey:@"LMUUpdateInterval"];

    NSMutableArray* dirtyOutlets = [_updateIntervalOutlets mutableCopy];
    [dirtyOutlets removeObject:sender];

    for(id outlet in dirtyOutlets)
        [outlet setFloatValue:value];
}


#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    _brightnessOutlets = nil;
    _contrastOutlets = nil;
    _redOutlets = nil;
    _greenOutlets = nil;
    _blueOutlets = nil;
    _updateIntervalOutlets = nil;
    _preferenceWindow = nil;

    // RestartLMU Controller to apply any interval changes
    if(lmuCon.monitoring) {
        [lmuCon stopMonitoring];
        [lmuCon startMonitoring];
    }

    NSLog(@"PreferencesController: preferenceWindow Dealloc");
}

@end
