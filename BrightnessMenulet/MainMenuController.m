//
//  MainMenuController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import "Screen.h"

#import "MainMenuController.h"
#import "PreferencesController.h"

@interface MainMenuController ()

@property PreferencesController* preferencesController;

@property (weak) IBOutlet NSMenuItem *autoBrightnessItem;

@end

@implementation MainMenuController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if((self = [super initWithCoder:aDecoder])){
    }

    return self;
}

- (void)refreshMenuScreens {
    [controls refreshScreens];

    while(!(self.itemArray[0].isSeparatorItem))                // Remove all current display menu items
        [self removeItemAtIndex:0];

    if([controls.screens count] == 0){
        // No screen connected, so disable outlets
        NSMenuItem* noDispItem = [[NSMenuItem alloc] init];
        noDispItem.title = @"No displays found";
        
        [self insertItem:noDispItem atIndex:0];
        [_lmuController stopMonitoring];
        return;
    }

    // add new outlets for screens
    for(Screen* screen in controls.screens){
        NSString* title = [NSString stringWithFormat:@"%@", screen.model];
        NSMenuItem* scrDesc = [[NSMenuItem alloc] init];
        scrDesc.title = title;
        scrDesc.enabled = NO;

        NSSlider* slider = [[NSSlider alloc] initWithFrame:NSRectFromCGRect(CGRectMake(18, 0, 100, 20))];
        slider.target = self;
        slider.action = @selector(sliderUpdate:);
        slider.tag = screen.screenNumber;
        slider.minValue = 0;
        slider.maxValue = screen.maxBrightness;
        slider.integerValue = screen.currentBrightness;
        
        NSTextField* brightLevelLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(118, 0, 30, 19))];
        [[brightLevelLabel cell] setTitle:[NSString stringWithFormat:@"%ld", (long)screen.currentBrightness]];
        [[brightLevelLabel cell] setBezeled:NO];
        
        NSMenuItem* scrSlider = [[NSMenuItem alloc] init];
        
        NSView* view = [[NSView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 140, 20))];
        [view addSubview:slider];
        [view addSubview:brightLevelLabel];
        
        [scrSlider setView:view];
        [self insertItem:scrSlider atIndex:0];
        [self insertItem:scrDesc atIndex:0];

        NSLog(@"MainMenu: %@ - %d outlets set with BR %ld", screen.model, screen.screenNumber, (long)screen.currentBrightness);

        [screen.brightnessOutlets addObjectsFromArray:@[ slider, brightLevelLabel ]];
    }
}

- (IBAction)toggledAutoBrightness:(NSMenuItem*)sender {
    if(sender.state == NSOffState){
        [sender setState:NSOnState];
        [_lmuController startMonitoring];
    }else{
        [sender setState:NSOffState];
        [_lmuController stopMonitoring];
    }
}

- (IBAction)preferences:(id)sender {
    if(!_preferencesController)
        _preferencesController = [[PreferencesController alloc] init];

    [_preferencesController showWindow];
}

- (void)sliderUpdate:(NSSlider*)slider {
    [[controls screenForDisplayID:slider.tag] setBrightness:[slider integerValue] byOutlet:slider];
}

- (IBAction)quit:(id)sender {
    exit(1);
}

#pragma mark - LMUDelegate

- (void)LMUControllerDidStartMonitoring {
    [_autoBrightnessItem setState:NSOnState];
}

- (void)LMUControllerDidStopMonitoring {
    [_autoBrightnessItem setState:NSOffState];
}

@end
