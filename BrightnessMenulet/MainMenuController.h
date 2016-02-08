//
//  MainMenuController.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import <Cocoa/Cocoa.h>
#import <IOKit/graphics/IOGraphicsLib.h>

#import "LMUDelegate.h"
#import "LMUController.h"
@interface MainMenuController : NSMenu <LMUDelegate>

@property LMUController* lmuController;

- (void)refreshMenuScreens;

@end
