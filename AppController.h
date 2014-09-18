#import <Cocoa/Cocoa.h>
#import "DDCControls.h"

@interface AppController : NSResponder {
	/* Our outlets which allow us to access the interface */
	IBOutlet NSMenu *statusMenu;
	
	NSStatusItem *statusItem;
	NSImage *statusImage;
	NSImage *statusHighlightImage;
	IBOutlet id mySlider;
}

@property (weak) DDCControls *controls;

- (IBAction)sliderUpdate:(id)sender;
- (void)updateBrightContrastLabel;

- (IBAction)increaseBrightness:(id)sender;
- (IBAction)decreaseBrightness:(id)sender;

- (IBAction)normalBrightness:(id)sender;
- (IBAction)lowBrightness:(id)sender;

@end