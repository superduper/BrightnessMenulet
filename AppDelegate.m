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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification{
    NSBundle *bundle = [NSBundle mainBundle];
    NSImage *statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon" ofType:@"png"]];
    NSImage *statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:@"icon-alt" ofType:@"png"]];
    statusImage.template = YES;
    statusHighlightImage.template = YES;
    
    
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    _statusItem.image = statusImage;
    _statusItem.alternateImage = statusHighlightImage;
    _statusItem.toolTip = @"Brightness Menulet";
    _statusItem.highlightMode = YES;
    _statusItem.menu = _mainMenu;
    
    [_mainMenu refreshMenuScreens];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification{
}

- (void)applicationDidChangeScreenParameters:(NSNotification *)notification{
    [_mainMenu refreshMenuScreens];
}

@end
