//
//  MainMenuController.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import <Cocoa/Cocoa.h>
#include <IOKit/graphics/IOGraphicsLib.h>

@interface MainMenuController : NSMenu

@property IBOutlet NSSlider *mySlider;

- (void)refresh;

- (IBAction)sliderUpdate:(id)sender;
- (IBAction)exit:(id)sender;

@end
