#import <Cocoa/Cocoa.h>

@interface AppController : NSResponder {
	/* Our outlets which allow us to access the interface */
	IBOutlet NSMenu *statusMenu;
	
	/* The other stuff :P */
	NSStatusItem *statusItem;
	NSImage *statusImage;
	NSImage *statusHighlightImage;
	IBOutlet id *mySlider;
}

/* Our IBAction which will call the helloWorld method when our connected Menu Item is pressed */
-(IBAction)sliderUpdate:(id)sender;
- (void) set_brightness:(int)new_brightness;
- (int) get_brightness;

@end