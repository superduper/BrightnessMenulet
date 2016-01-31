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

@property (weak) IBOutlet NSSlider* brightCSlider;
@property (weak) IBOutlet NSTextField* brightCTextField;
@property (weak) IBOutlet NSStepper* brightCStepper;
@property (weak) IBOutlet NSSlider* contCSlider;
@property (weak) IBOutlet NSTextField* contCTextField;
@property (weak) IBOutlet NSStepper* contCStepper;

// If only OSX supported IBOutlet​Collection...
@property (strong) NSArray* brightnessOutlets;
@property (strong) NSArray* contrastOutlets;

@end

@implementation PreferencesController

- (void)showWindow {
    // Must support atleast OSX 10.8 because of loadNibNamed:owner:topLevelObjects
    if(!_preferenceWindow){
        NSLog(@"PreferencesController: Pref Window alloc");
        [[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self topLevelObjects:nil];

        _preferenceWindow.delegate = self;

        NSNumberFormatter* decFormater = [[NSNumberFormatter alloc] init];
        [decFormater setNumberStyle:NSNumberFormatterDecimalStyle];

        [_brightCTextField setFormatter:decFormater];
        [_contCTextField setFormatter:decFormater];

        _brightnessOutlets = @[_brightCSlider, _brightCTextField, _brightCStepper];
        _contrastOutlets = @[_contCSlider, _contCTextField, _contCStepper];
    }

    [self refreshScreenPopUpList];
    
    [self updateBrightnessControls];
    [self updateContrastControls];

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

- (void)refreshScreenPopUpList {
    // Reset Variables
    [_displayPopUpButton removeAllItems];
    [_currentScreen.brightnessOutlets removeObjectsInArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets removeObjectsInArray:_contrastOutlets];
    
    if([controls.screens count] == 0){
        // no screens so disable outlets
        [_displayPopUpButton setEnabled:NO];

        // makeObjectsPerformSelector:withObject: only allows NO because it is same as nil lol...
        [_brightnessOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        [_contrastOutlets makeObjectsPerformSelector:@selector(setEnabled:) withObject:NO];
        
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
    
    [self updateBrightnessControls];
    [self updateContrastControls];
}

- (IBAction)didChangeDisplayMenu:(id)sender {
    NSString* selectedItem = _displayPopUpButton.titleOfSelectedItem;

    // remove outlets from old screen
    [_currentScreen.brightnessOutlets removeObjectsInArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets removeObjectsInArray:_contrastOutlets];

    _currentScreen = [controls screenForDisplayName:selectedItem];

    // Add outlets to new _currentScreen
    [_currentScreen.brightnessOutlets addObjectsFromArray:_brightnessOutlets];
    [_currentScreen.contrastOutlets addObjectsFromArray:_contrastOutlets];

    [self updateBrightnessControls];
    [self updateContrastControls];
}

- (IBAction)pressedRefreshDisp:(id)sender {
    [self refreshScreenPopUpList];
}

#pragma mark - IBActions

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

#pragma mark - NSWindowDelegate

- (void)windowWillClose:(NSNotification *)notification {
    _brightnessOutlets = nil;
    _contrastOutlets = nil;
    _preferenceWindow = nil;

    NSLog(@"PreferencesController: preferenceWindow Dealloc");
}

@end
