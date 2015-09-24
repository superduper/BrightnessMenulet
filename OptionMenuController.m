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

@end

@implementation OptionMenuController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]){
        [self loadPresets];
    }
    
    return self;
}

- (void)loadPresets{
    NSArray* presets = [[controls presets] allKeys];
    presets = [presets sortedArrayUsingSelector:@selector(compare:)];
    
    for(NSInteger i = [presets count]-1; i >= 0; i--){
        NSString* presetTitle = presets[i];
        NSMenuItem* presetMenuItem = [[NSMenuItem alloc] init];
        [presetMenuItem setTitle:presetTitle];
        [presetMenuItem setTarget:self];
        [presetMenuItem setAction:@selector(pressedDisplayPreset:)];
        
        [self insertItem:presetMenuItem atIndex:3];
    }
}

- (void)awakeFromNib{
    [self refresh];
}

- (void)refresh{
    [self updateBrightContrastLabels];
    
    int lock = [controls getOSDLock];
    if(lock == 2)
        [[self itemWithTag:2] setState:NSOffState];
    else
        [[self itemWithTag:2] setState:NSOnState];
}

- (void)updateBrightContrastLabels{
    NSString *format = [NSString stringWithFormat:@"B: %d - C: %d", [controls localBrightness], [controls localContrast]];
    [[self brightnessContrastLabel] setTitle:format];
    [[self brightnessSlider] setIntValue:[controls localBrightness]];
    
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

- (IBAction)pressedDisplayPreset:(id)sender {
    NSMenuItem* item = (NSMenuItem*)sender;
    NSLog(@"pressed %@",[item title]);
    
    [controls handleClickedPreset:[item title]];
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
