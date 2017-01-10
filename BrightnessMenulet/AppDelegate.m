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

- (void)awakeFromNib
{
    NSLog(@"%@ %@",
          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
          [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]);
    
    if ([[NSRunningApplication runningApplicationsWithBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]] count] > 1) {
        NSLog(@"... is already running!");
        [NSApp terminate:nil];
    }
    
    // just to be shure, that we didn't miss something super fancy
    [super awakeFromNib];
}


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

    // LMU
    [LMUController singleton];
    lmuCon.delegate = _mainMenu;
    

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    if(![[[defaults dictionaryRepresentation] allKeys] containsObject:@"LMUUpdateInterval"])
        [defaults setFloat:0.5 forKey:@"LMUUpdateInterval"];

    if([defaults boolForKey:@"autoBrightOnStartup"])
        [lmuCon startMonitoring];
    
    // Unregister hotkeys
    [_mainMenu registerHotKeys];
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification {
    NSLog(@"AppDelegate: DidChangeScreenParameters");

    // BUG: May crash if displays are connected/disconnected quickly so lets try waiting
    [NSTimer scheduledTimerWithTimeInterval:2.0f
                                     target:_mainMenu
                                   selector:@selector(refreshMenuScreens)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Unregister hotkeys
    [_mainMenu unregisterHotKeys];
}

@end
