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

#import "VirtualKeyCodes.h"
#import <Carbon/Carbon.h>

@interface MainMenuController () {
    EventHotKeyRef hotKeyRef;
}

@property PreferencesController* preferencesController;

@property (weak) IBOutlet NSMenuItem *autoBrightnessItem;

@property (assign, nonatomic) BOOL darkModeOn;
@end


@implementation MainMenuController

- (void)refreshMenuScreens {
    [controls refreshScreens];

    while(!(self.itemArray[0].isSeparatorItem))                // Remove all current display menu items
        [self removeItemAtIndex:0];

    if([controls.screens count] == 0){
        // No screen connected, so disable outlets
        NSMenuItem* noDispItem = [[NSMenuItem alloc] init];
        noDispItem.title = @"No displays found";
        
        [self insertItem:noDispItem atIndex:0];

        if(lmuCon.monitoring)
            [lmuCon stopMonitoring];
        return;
    }
    
    // No LMU available
    if(!lmuCon.available) {
        if(self.autoBrightnessItem) {
            [self removeItem:self.autoBrightnessItem];
            NSLog(@"Remove 'Auto-Brightness' menu item");
        }
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
        brightLevelLabel.backgroundColor = [NSColor clearColor];
        brightLevelLabel.alignment = NSTextAlignmentLeft;
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
        [lmuCon startMonitoring];
    }else{
        [sender setState:NSOffState];
        [lmuCon stopMonitoring];
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
    //exit(1);
    [[NSApplication sharedApplication] terminate:self];
}

#pragma mark - LMUDelegate

- (void)LMUControllerDidStartMonitoring {
    [_autoBrightnessItem setState:NSOnState];
}

- (void)LMUControllerDidStopMonitoring {
    [_autoBrightnessItem setState:NSOffState];
}

#pragma mark - Global HotKeys
-(void)registerHotKeys
{
    //EventHotKeyRef hotKeyRef;
    if (!hotKeyRef) {
        NSLog(@"Register HotKeys");
        
        EventHotKeyID hotKeyID;
        EventTypeSpec eventType;
        eventType.eventClass=kEventClassKeyboard;
        eventType.eventKind=kEventHotKeyPressed;
        
        InstallApplicationEventHandler(&OnHotKeyEvent, 1, &eventType, (void *)CFBridgingRetain(self), NULL);
        
        hotKeyID.signature='htk1';
        hotKeyID.id=1;
        RegisterEventHotKey(kVK_ANSI_T, cmdKey+optionKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        
        hotKeyID.signature='htk2';
        hotKeyID.id=2;
        RegisterEventHotKey(kVK_BrightnessUp, 0, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        
        hotKeyID.signature='htk3';
        hotKeyID.id=3;
        RegisterEventHotKey(kVK_BrightnessDown, 0, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        
        hotKeyID.signature='htk4';
        hotKeyID.id=4;
        RegisterEventHotKey(kVK_BrightnessUp, cmdKey+optionKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
        
        hotKeyID.signature='htk5';
        hotKeyID.id=5;
        RegisterEventHotKey(kVK_BrightnessDown, cmdKey+optionKey, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
    }
}

- (void)unregisterHotKeys {
    if (hotKeyRef) {
        NSLog(@"Unregister HotKeys");
        UnregisterEventHotKey(hotKeyRef);
        hotKeyRef = 0;
    }
}

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
    EventHotKeyID hkCom;
    
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
    MainMenuController *app = (__bridge MainMenuController *)userData;
    
    int l = hkCom.id;
    
    switch (l) {
        case 1:
            NSLog(@"Capture COMMAND + OPTION + T");
            [app helloWorld];
            break;
        case 2:
            NSLog(@"Capture BRIGHTNESS_UP");
            if ([controls.screens count] < 1) return 0;
            [controls.screens[0] setBrightnessRelativeToValue:@"5+"];
            break;
        case 3:
            NSLog(@"Capture BRIGHTNESS_DOWN");
            if ([controls.screens count] < 1) return 0;
            [controls.screens[0] setBrightnessRelativeToValue:@"5-"];
            break;
        case 4:
            NSLog(@"Capture COMMAND + OPTION + BRIGHTNESS_UP");
            for(Screen* screen in controls.screens) {
                [[controls screenForDisplayID:screen.screenNumber] setBrightnessRelativeToValue:@"5+"];
            }
            break;
        case 5:
            NSLog(@"Capture COMMAND + OPTION + BRIGHTNESS_DOWN");
            for(Screen* screen in controls.screens) {
                [[controls screenForDisplayID:screen.screenNumber] setBrightnessRelativeToValue:@"5-"];
            }
            break;
    }
    
    return noErr;
}

- (void)helloWorld {
    NSLog(@"Hello World");
}

@end
