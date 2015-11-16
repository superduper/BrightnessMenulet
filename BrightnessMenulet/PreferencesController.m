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

@property (weak) IBOutlet NSOutlineView* profilesTable;

@end

@implementation PreferencesController

- (void)showWindow{
    // Must support OSX 10.8 or up because of this loadNibNamed:owner:topLevelObjects
    if(![self preferenceWindow]){
        NSLog(@"Pref Window alloc");
        [[NSBundle mainBundle] loadNibNamed:@"Preferences" owner:self topLevelObjects:nil];

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
    NSInteger currentBrightness = [_currentScreen[CurrentBrightness] integerValue];
    
    [_brightCSlider setIntValue:currentBrightness];
    [_brightCSlider setMaxValue:[_currentScreen[MaxBrightness] integerValue]];
    [_brightCTextField setIntValue:currentBrightness];
    [_brightCStepper setIntValue:currentBrightness];
    [_brightCStepper setMaxValue:[_currentScreen[MaxBrightness] integerValue]];
}

- (void)updateContrastControls{
    NSInteger currentContrast = [_currentScreen[CurrentContrast] integerValue];
    
    [_contCSlider setIntValue:currentContrast];
    [_contCSlider setMaxValue:[_currentScreen[MaxContrast] integerValue]];
    [_contCTextField setIntValue:currentContrast];
    [_contCStepper setIntValue:currentContrast];
    [_contCStepper setMaxValue:[_currentScreen[MaxContrast] integerValue]];
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
        [_displayPopUpButton addItemWithTitle:scr[Model]];
    
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
    _preferenceWindow = nil;
    NSLog(@"_preferenceWindow Dealloc");
}

#pragma Mark profilesTable - DataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    if(item) // child
        return [controls.profiles[item] count];

    return [controls.profiles count];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if([[controls.profiles allKeys] containsObject:item])
        return YES;
    
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    return item;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    if(item){
        NSDictionary* scr = controls.profiles[item][index];
        
        return [NSString stringWithString:scr[Model]];
    }
    NSArray* profiles = [controls.profiles allKeys];
    
    return [profiles objectAtIndex:index];
}

#pragma mark profilesTable - Delegate

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldEditTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification{
    NSString* selected = [_profilesTable itemAtRow:[_profilesTable selectedRow]];
    NSInteger level = [_profilesTable levelForRow:[_profilesTable selectedRow]];

    if(level == 0){
        
    }else if(level == 1){
        NSArray* profile = controls.profiles[[_profilesTable parentForItem:selected]];
        
        for(NSDictionary* scr in profile){
            if([scr[@"Model"] isEqual:selected]){   // TODO: Duplicate Model names
                [_brightPTextField setStringValue:scr[CurrentBrightness]];
                [_contPTextField setStringValue:scr[CurrentContrast]];
            }
        }

    }else
        NSLog(@"ERROR: row is too high");
}
- (IBAction)pressedProfilePlus:(id)sender {
    NSString* selected = [_profilesTable itemAtRow:[_profilesTable selectedRow]];
    NSInteger level = [_profilesTable levelForRow:[_profilesTable selectedRow]];
    
    if(level == 0){
    }else if(level == 1){
        
    }
}

- (IBAction)pressedProfileMinus:(id)sender {
    NSString* selected = [_profilesTable itemAtRow:[_profilesTable selectedRow]];
    NSInteger level = [_profilesTable levelForRow:[_profilesTable selectedRow]];
    
    if(level == 0){
        [controls.profiles removeObjectForKey:self];
        // save
    }else if(level == 1){
        
    }
}

@end
