//
//  MainMenuController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import "MainMenuController.h"
#import "PreferencesController.h"

@interface MainMenuController ()

@property PreferencesController *preferencesController;

@end

@implementation MainMenuController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super initWithCoder:aDecoder]){
        [self loadProfiles];
    }
    
    return self;
}

- (void)loadProfiles{
    NSArray* profiles = [[controls profiles] allKeys];
    profiles = [profiles sortedArrayUsingSelector:@selector(compare:)];
    
    for(NSInteger i = [profiles count]-1; i >= 0; i--){
        NSString* profileTitle = profiles[i];
        NSMenuItem* profileMenuItem = [[NSMenuItem alloc] init];
        profileMenuItem.title = profileTitle;
        profileMenuItem.target = self;
        profileMenuItem.action = @selector(pressedDisplayProfile:);
        
        [self insertItem:profileMenuItem atIndex:[self indexOfItem:[self itemWithTitle:@"Profiles"]]+1];
    }
}

- (void)refreshMenuScreens{
    [controls refreshScreens];

    while(!(self.itemArray[0].isSeparatorItem))                // Remove all current display menu items
        [self removeItemAtIndex:0];

    if([controls.screens count] == 0){
        NSMenuItem* noDispItem = [[NSMenuItem alloc] init];
        noDispItem.title = @"No displays found";
        
        [self insertItem:noDispItem atIndex:0];
        return;
    }
    
    for(NSDictionary* scr in controls.screens){
        NSString* title = [NSString stringWithFormat:@"%@", scr[@"Model"]];
        NSMenuItem* scrDesc = [[NSMenuItem alloc] init];
        scrDesc.title = title;
        scrDesc.enabled = NO;
        
        NSSlider* slider = [[NSSlider alloc] initWithFrame:NSRectFromCGRect(CGRectMake(2, 0, 100, 20))];
        slider.target = self;
        slider.action = @selector(sliderUpdate:);
        slider.tag = [scr[@"ScreenNumber"] integerValue];
        slider.maxValue = 100;                          // TODO: Detect max
        slider.minValue = 0;
        
        NSTextField* brightLevelLabel = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(102, 0, 30, 19))];
        [[brightLevelLabel cell] setTitle:[NSString stringWithFormat:@"%@", scr[@"BRIGHTNESS"]]];
        [[brightLevelLabel cell] setBezeled:NO];
        
        NSMenuItem* scrSlider = [[NSMenuItem alloc] init];
        
        NSView* view = [[NSView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 130, 20))];
        [view addSubview:slider];
        [view addSubview:brightLevelLabel];
        
        [scrSlider setView:view];
        [self insertItem:scrSlider atIndex:0];
        [self insertItem:scrDesc atIndex:0];

        NSLog(@"%@ outlets set with %@ %@", scr[@"Model"], scr[@"BRIGHTNESS"], scr[@"CONTRAST"]);
    }
}

- (IBAction)preferences:(id)sender{
    if(_preferencesController == nil)
        _preferencesController = [[PreferencesController alloc] init];

    [_preferencesController showWindow];
}

- (void)sliderUpdate:(id)sender{
    NSSlider* slider = sender;              // slider tag contains displayid
    
    // change brightness value label
    for(id view in slider.superview.subviews)
        if([view isKindOfClass:[NSTextField class]])
            [[view cell] setTitle:[NSString stringWithFormat:@"%d", [slider intValue]]];
    
    [controls setScreenID:[slider tag] brightness:[slider intValue]];
}

- (void)pressedDisplayProfile:(id)sender {
    NSMenuItem* item = (NSMenuItem*)sender;
    NSLog(@"Applying profile: %@", item.title);
    
    [controls applyProfile:item.title];
    [self refreshMenuScreens];              //TODO: should just change values instead remakeing Menuitems
}

- (IBAction)quit:(id)sender {
    exit(1);
}


@end
