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
    [DDCControls singleton];
    NSBundle *bundle = [NSBundle mainBundle];
    
    [self setStatusItem:[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength]];
    NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    NSImage *statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    
    [[self statusItem] setImage:statusImage];
    [[self statusItem] setAlternateImage:statusHighlightImage];
    [[self statusItem] setToolTip:@"Brightness Menulet"];
    [[self statusItem] setHighlightMode:YES];
    
    // TODO: Figure out how to use option key to change menu
    [[self statusItem] setMenu:[self optionMenu]];
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification{
    
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification{
    [[self mainMenu] refresh];
    [[self optionMenu] refresh];
}

@end
