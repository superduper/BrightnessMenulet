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
@interface MainMenuController : NSMenu <LMUDelegate>

- (void)refreshMenuScreens;

@end
