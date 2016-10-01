//
//  AppDelegate.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 10/10/14.
//
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property NSStatusItem *statusItem;
@property NSImage *statusImage;
@property NSImage *statusHighlightImage;
@property NSImage *statusImage2;
@property NSImage *statusHighlightImage2;

@property (strong) IBOutlet MainMenuController *mainMenu;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Set Menulet Icon
    NSBundle *bundle = [NSBundle mainBundle];
    _statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    _statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    _statusImage2 = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon2" ofType:@"png"]];
    _statusHighlightImage2 = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon2-alt" ofType:@"png"]];
    _statusImage.template = YES; // Set icon as template for dark mode
    _statusImage2.template = YES;

    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = _statusImage;
    _statusItem.alternateImage = _statusHighlightImage;
    _statusItem.toolTip = @"Brightness Menulet";
    _statusItem.highlightMode = YES;
    _statusItem.menu = _mainMenu;

    // init _mainMenu
    [_mainMenu refreshMenuScreens];
    _mainMenu.delegate = _mainMenu;

    lmuCon.delegate = _mainMenu;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"LMUUpdateInterval"])
        [defaults setFloat:0.5 forKey:@"LMUUpdateInterval"];

    if([defaults boolForKey:@"autoBrightOnStartup"])
        [lmuCon startMonitoring];
    
    [self bindShortcuts];
    
    NSLog(@"%@ DEFAULTS = %@", [self class], [defaults persistentDomainForName:[[NSBundle mainBundle] bundleIdentifier]]);
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification {

    [_mainMenu refreshMenuScreens];
    
}

- (void) bindShortcuts {
    int step = 5;
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:@"ShortcutBrighter"
     toAction:^{
         lmuCon.stopMonitoring;
         for(Screen* screen in controls.screens) {
             if ([screen.currentAutoAttribute isEqualToString:@"BR"]) {
                 int percent = ((double)screen.currentBrightness/(double)screen.maxBrightness)*100.0;
                 [screen setBrightnessWithPercentage:percent+step byOutlet:nil];
             } else {
                 int percent = ((double)screen.currentContrast/(double)screen.maxContrast)*100.0;
                 NSLog(@"percent: %d", percent);
                 [screen setContrastWithPercentage:percent+step byOutlet:nil];
             }
         }
     }];
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:@"ShortcutDarker"
     toAction:^{
         lmuCon.stopMonitoring;
         for(Screen* screen in controls.screens) {
             if ([screen.currentAutoAttribute isEqualToString:@"BR"]) {
                 int percent = ((double)screen.currentBrightness/(double)screen.maxBrightness)*100.0;
                 [screen setBrightnessWithPercentage:percent-step byOutlet:nil];
             } else {
                 int percent = ((double)screen.currentContrast/(double)screen.maxContrast)*100.0;
                 NSLog(@"percent: %d", percent);
                 [screen setContrastWithPercentage:percent-step byOutlet:nil];
             }
         }
     }];
    [[MASShortcutBinder sharedBinder]
     bindShortcutWithDefaultsKey:@"ShortcutToggleFollow"
     toAction:^{
         if (lmuCon.monitoring == YES)
             lmuCon.stopMonitoring;
         else
             lmuCon.startMonitoring;
     }];
}

- (void)statusImageHighlighted {
       [_statusItem setImage:_statusImage2];
       [_statusItem setAlternateImage:_statusHighlightImage2];
}

- (void)statusImageNotHighlighted {
        [_statusItem setImage: _statusImage];
        [_statusItem setAlternateImage: _statusHighlightImage];
}

@end
