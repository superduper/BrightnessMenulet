//
//  PreferencesController.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/8/14.
//
//

#import <Cocoa/Cocoa.h>

@interface PreferencesController : NSWindowController

- (void)showWindow;

- (void)updateBrightnessControls;
- (void)updateContrastControls;
- (void)updateRGBControls;
- (void)updateRedControls;
- (void)updateGreenControls;
- (void)updateBlueControls;

@end
