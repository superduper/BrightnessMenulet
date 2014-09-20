#import "AppController.h"
#include <IOKit/graphics/IOGraphicsLib.h>

#define controls [self controls]

@implementation AppController

const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);

- (void)awakeFromNib{
	//Create the NSStatusBar and set its length
	statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
	
	
	//Used to detect where our files are
	NSBundle *bundle = [NSBundle mainBundle];
	
	//Allocates and loads the images into the application which will be used for our NSStatusItem
	statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
	statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
	
	//Sets the images in our NSStatusItem
	[statusItem setImage:statusImage];
	[statusItem setAlternateImage:statusHighlightImage];
	
	//Tells the NSStatusItem what menu to load
	[statusItem setMenu:statusMenu];
	//Sets the tooptip for our item
	[statusItem setToolTip:@"Brightness Menulet"];
    
    //initialize DDCControls
    [self setControls:[[DDCControls alloc] init]];
    //[controls readOut];
    
	//Enables highlighting
	[statusItem setHighlightMode:YES];
	[mySlider becomeFirstResponder];
    
    // initialize labels
    [mySlider setIntValue:[controls currentBrightness]];
    [self updateBrightContrastLabel];
    [self updateInfoMenu];
    int lock = [controls getOSDLock];
    if(lock == 2)
        [[statusMenu itemWithTag:2] setState:NSOffState];
    else
        [[statusMenu itemWithTag:2] setState:NSOnState];
}


- (IBAction)sliderUpdate:(id)sender{
    int newValue = [sender intValue];
	[controls setBrightness: newValue];
    [self updateBrightContrastLabel];
}
/*
- (void)increaseBrightness:(id)sender{
    if([controls currentBrightness] <= 95)
        [controls setBrightness:[controls currentBrightness] + 5];
    else
        [controls setBrightness:100];
    [mySlider setIntValue:[controls currentBrightness]];
}

- (void)decreaseBrightness:(id)sender{
    if([controls currentBrightness] >= 5)
        [controls setBrightness:[controls currentBrightness] - 5];
    else
        [controls setBrightness:0];
    [mySlider setIntValue:[controls currentBrightness]];
}
*/
- (void)updateBrightContrastLabel{
    NSString *format = [NSString stringWithFormat:@"B: %d - C: %d", [controls currentBrightness], [controls currentContrast]];
    [[statusMenu itemWithTag:1] setTitle:format];
}

- (void)updateInfoMenu{
    // TODO: Preset name other than number
    NSMenu *infoMenu = [[statusMenu itemAtIndex:4] submenu];
    NSString *format = [NSString stringWithFormat:@"Preset: %d", [controls getPreset]];
    [[infoMenu itemWithTag:3] setTitle:format];
    
    format = [NSString stringWithFormat:@"Red: %d", [controls getRed]];
    [[infoMenu itemWithTag:4] setTitle:format];
    
    format = [NSString stringWithFormat:@"Green: %d", [controls getGreen]];
    [[infoMenu itemWithTag:5] setTitle:format];
    
    format = [NSString stringWithFormat:@"Blue: %d", [controls getBlue]];
    [[infoMenu itemWithTag:6] setTitle:format];
}

- (IBAction)normalBrightness:(id)sender{
    [controls setBrightness:20];
    [mySlider setIntValue:[controls currentBrightness]];
}

- (IBAction)lowBrightness:(id)sender{
    [controls setBrightness:0];
    [mySlider setIntValue:[controls currentBrightness]];
}

- (IBAction)standardColor:(id)sender{
    [controls setPreset:1];                 // Sets to standard preset
    [self updateInfoMenu];
}

- (IBAction)sRGB:(id)sender{
    [controls changeControl:0x14 withValue:1];
    [self updateInfoMenu];
}

- (IBAction)toggleOSDLock:(id)sender{
    [controls setOSDLock: ([controls getOSDLock] == 1 ? 2 : 1)];
    if([controls getOSDLock] == 2)
        [[statusMenu itemWithTag:2] setState:NSOffState];
    else
        [[statusMenu itemWithTag:2] setState:NSOnState];
}

- (IBAction)exit:(id)sender{
	exit(1);
}

@end