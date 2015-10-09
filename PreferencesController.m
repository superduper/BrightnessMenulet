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

@property (weak) IBOutlet NSTextField *brightPTextField;
@property (weak) IBOutlet NSTextField *contPTextField;

@property (weak) IBOutlet NSTableView* profilesTable;

@end

@implementation PreferencesController

- (instancetype)init {
    if((self = [super init])){
        
    }
    
    return self;
}

- (void)showWindow{
    // Must support OSX 10.8 or up because of this loadNibNamed:owner:topLevelObjects
    if(![self preferenceWindow]){
        NSLog(@"Pref Window alloc");
        [[NSBundle mainBundle] loadNibNamed:@"Preferences"
                                      owner:self
                            topLevelObjects:nil];

        [_profilesTable reloadData];
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
    int currentBrightness = [_currentScreen[@"BRIGHTNESS"] intValue];
    
    [_brightCSlider setIntValue:currentBrightness];
    [_brightCTextField setIntValue:currentBrightness];
    [_brightCStepper setIntValue:currentBrightness];
}

- (void)updateContrastControls{
    int currentContrast = [_currentScreen[@"CONTRAST"] intValue];
    
    [_contCSlider setIntValue:currentContrast];
    [_contCTextField setIntValue:currentContrast];
    [_contCStepper setIntValue:currentContrast];
}

- (void)refreshScreenPopUpList{
    [_displayPopUpButton removeAllItems];
    
    if([controls.screens count] == 0){
        [_displayPopUpButton setEnabled:NO];
        
        [_brightCSlider setEnabled:NO];
        [_brightCTextField setEnabled:NO];
        [_brightCStepper setEnabled:NO];
        [_contCSlider setEnabled:NO];
        [_contCTextField setEnabled:NO];
        [_contCStepper setEnabled:NO];
        
        return;
    }
    
    for(NSDictionary* scr in controls.screens)
        [_displayPopUpButton addItemWithTitle:scr[@"Model"]];
    
    if(!_brightCStepper.enabled){
        [_brightCSlider setEnabled:YES];
        [_brightCTextField setEnabled:YES];
        [_brightCStepper setEnabled:YES];
        [_contCSlider setEnabled:YES];
        [_contCTextField setEnabled:YES];
        [_contCStepper setEnabled:YES];
    }

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
    }else{
        NSLog(@"Error: Could not find scr for %@", selectedItem);
    }
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
    _preferenceWindow = nil;
    NSLog(@"_preferenceWindow Dealloc");
}

#pragma Mark profilesTable - DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    
    return [[controls.profiles allKeys] count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    return [[NSTextFieldCell alloc] init];
}

#pragma mark profilesTable - Delegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *result = [tableView makeViewWithIdentifier:@"cell" owner:self];
    
    NSArray* arr = [controls.profiles allKeys];
    [result.textField setStringValue:arr[row]];

    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
//    NSInteger row = _profilesTable.selectedRow;
//    NSArray* keys = [controls.profiles allKeys];
//    NSDictionary* preset = [controls.profiles objectForKey:[keys objectAtIndex:row]][@"0"];
//    
//    [_brightPTextField setStringValue:[preset objectForKey:@"BRIGHTNESS"]];
//    [_contPTextField setStringValue:[preset objectForKey:@"CONTRAST"]];
}

@end
