//
//  MainMenuController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import "Screen.h"
//#import "LMUController.h"
#import "MainMenuController.h"
#import "PreferencesController.h"

@interface MainMenuController ()

//@property LMUController* lmuController;
@property PreferencesController* preferencesController;

@end

@implementation MainMenuController

- (void)refreshMenuScreens {
    //_lmuController = [[LMUController alloc] init];
    
    [controls refreshScreens];

    while(!(self.itemArray[0].isSeparatorItem))                // Remove all current display menu items
        [self removeItemAtIndex:0];

    if([controls.screens count] == 0){
        NSMenuItem* noDispItem = [[NSMenuItem alloc] init];
        noDispItem.title = @"No displays found";
        
        [self insertItem:noDispItem atIndex:0];
        return;
    }
    
    for(Screen* screen in controls.screens) {
        NSString* title = [NSString stringWithFormat:@"%@", screen.model];
        NSMenuItem* scrDesc = [[NSMenuItem alloc] init];
        scrDesc.title = title;
        scrDesc.enabled = NO;

        NSSlider* slider = [[NSSlider alloc] initWithFrame:NSRectFromCGRect(CGRectMake(2, 0, 100, 20))];
        slider.target = self;
        slider.action = @selector(sliderUpdate:);
        slider.tag = screen.screenNumber;
        slider.maxValue = screen.maxBrightness;
        slider.minValue = 0;
        
        NSTextField* brightLevelLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(102, 0, 30, 19))];
        [[brightLevelLabel cell] setTitle:[NSString stringWithFormat:@"%ld", (long)screen.currentBrightness]];
        [[brightLevelLabel cell] setBezeled:NO];
        
        NSMenuItem* scrSlider = [[NSMenuItem alloc] init];
        
        NSView* view = [[NSView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 130, 20))];
        [view addSubview:slider];
        [view addSubview:brightLevelLabel];
        
        [scrSlider setView:view];
        [self insertItem:scrSlider atIndex:0];
        [self insertItem:scrDesc atIndex:0];

        NSLog(@"MainMenu: %@ - %d outlets set with BR %ld", screen.model, screen.screenNumber, (long)screen.currentBrightness);
    }
}

- (IBAction)preferences:(id)sender {
    if(!_preferencesController)
        _preferencesController = [[PreferencesController alloc] init];

    [_preferencesController showWindow];
}

- (void)sliderUpdate:(NSSlider*)slider {
    for(id view in slider.superview.subviews)
        if([view isKindOfClass:[NSTextField class]])
            [[view cell] setTitle:[NSString stringWithFormat:@"%d", [slider intValue]]];

    [[controls screenForDisplayID:slider.tag] setBrightness:[slider integerValue]];
}

- (IBAction)quit:(id)sender {
    exit(1);
}

@end
