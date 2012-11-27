#import "ddc.h"
#import "AppController.h"
#include <IOKit/graphics/IOGraphicsLib.h>


@implementation AppController
const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);

- (void) awakeFromNib{
	
	//Create the NSStatusBar and set its length
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
	
	
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
		
	[mySlider setIntValue:[self get_brightness]];
	//Enables highlighting
	[statusItem setHighlightMode:YES];
	
	[mySlider becomeFirstResponder];
		
}


- (int) get_brightness {
	struct DDCReadCommand read_command;
	read_command.control_id = 0x10;
    
	ddc_read(0, &read_command);
	return ((int)read_command.response.current_value);
}

- (void) set_brightness:(int) new_brightness {
	struct DDCWriteCommand write_command;
	write_command.control_id = 0x10;
	write_command.new_value = new_brightness;
	ddc_write(0, &write_command);
}

- (void) dealloc {
	//Releases the 2 images we loaded into memory
	[statusImage release];
	[statusHighlightImage release];
	[super dealloc];
}


-(IBAction)sliderUpdate:(id)sender{
	int value = [sender intValue];
    NSLog(@"Got brightness %d", value);
	[self set_brightness:value];

}

-(IBAction)exit:(id)sender{
	NSLog(@"goodvnye there!");
	exit(1);
}


@end