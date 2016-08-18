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

@property (strong) IBOutlet MainMenuController *mainMenu;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Set Menulet Icon
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    NSImage *statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    statusImage.template = YES; // Set icon as template for dark mode
    statusHighlightImage.template = YES;

    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = statusImage;
    _statusItem.alternateImage = statusHighlightImage;
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
    NSLog(@"AppDelegate: DidChangeScreenParameters");

    [_mainMenu refreshMenuScreens];
}

- (void) bindShortcuts {
    int step = 6;
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

@end
