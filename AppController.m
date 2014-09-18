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
    
	[mySlider setIntValue:[controls currentBrightness]];
	//Enables highlighting
	[statusItem setHighlightMode:YES];
	
	[mySlider becomeFirstResponder];

}


- (IBAction)sliderUpdate:(id)sender{
	[controls setBrightness:[sender intValue]];
    [self updateBrightContrastLabel];
}

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

- (void)updateBrightContrastLabel{
    //while([[NSApp mainMenu] highlightedItem] != nil){
        NSString *format = [NSString stringWithFormat:@"B: %d - C: %d", [controls currentBrightness], [controls currentContrast]];
        [[[NSApp mainMenu] itemWithTag:1] setTitle:format];
    //}
}

- (void)updateInfoMenu{
    // TODO: Preset name other than number
    NSString *format = [NSString stringWithFormat:@"Preset: %d", [controls getPreset]];
    [[[NSApp mainMenu] itemWithTag:3] setTitle:format];
    
    format = [NSString stringWithFormat:@"Red: %d", [controls getRed]];
    [[[NSApp mainMenu] itemWithTag:4] setTitle:format];
    
    format = [NSString stringWithFormat:@"Green: %d", [controls getGreen]];
    [[[NSApp mainMenu] itemWithTag:5] setTitle:format];
    
    format = [NSString stringWithFormat:@"Blue: %d", [controls getBlue]];
    [[[NSApp mainMenu] itemWithTag:6] setTitle:format];
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
    [controls setPreset:0];
}

- (IBAction)sRGB:(id)sender{
    [controls setPreset:7];
}

- (IBAction)toggleOSDLock:(id)sender{
    [controls setOSDLock: ([controls getOSDLock] == 1 ? 2 : 1)];
    [[[NSApp mainMenu] itemWithTag:2] setState:[controls getOSDLock]+1];
}

- (IBAction)exit:(id)sender{
	exit(1);
}

@end