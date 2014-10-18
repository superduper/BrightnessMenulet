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

@property IBOutlet MainMenuController *mainMenu;
@property IBOutlet OptionMenuController *optionMenu;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    NSBundle *bundle = [NSBundle mainBundle];
    
    [self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength]];
    NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    NSImage *statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    
    [[self statusItem] setImage:statusImage];
    [[self statusItem] setAlternateImage:statusHighlightImage];
    [[self statusItem] setToolTip:@"Brightness Menulet"];
    [[self statusItem] setHighlightMode:YES];
    [[self statusItem] setMenu:[self optionMenu]];
    
    // Set self as Delegate to be able to use menuWillOpen:
    [[self mainMenu] setDelegate:self];
    [[self optionMenu] setDelegate:self];
    
    // TODO: Figure out how to use option key to change menu (NSAlternateKeyMask)
}

- (void)applicationWillTerminate:(NSNotification *)aNotification{
    
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification{
    // Ideas: force change display parameters when connected to prefered settings?
}

- (void)menuWillOpen:(NSMenu *)menu{
    // Before openning menu, should refresh values
    // only if number of displays is more than 1
    // calling a refresh here removes any inaccurate readings
    
    // TODO: Check when an actual external display is connected
    // this will not suffice as when internal laptop screens are closed,
    // external monitor will be the only one display
    // if([controls numberOfDisplays] > 1)
        
    // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    
    [controls refreshLocalValues];
    
    // Refresh labels
    SEL selector = NSSelectorFromString(@"refresh");
    IMP imp = [menu methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(menu, selector);
}

@end
