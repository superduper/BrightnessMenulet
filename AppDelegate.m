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
    // Menu values will be updated when menu will actually be opened
    [controls refreshLocalValues];
}

- (void)menuWillOpen:(NSMenu *)menu{
    // Before openning menu, should refresh values
    
    // http://stackoverflow.com/questions/7017281/performselector-may-cause-a-leak-because-its-selector-is-unknown
    SEL selector = NSSelectorFromString(@"refresh");
    IMP imp = [menu methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;
    func(menu, selector);
}

@end
