//
//  LMUController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 1/29/16.
//
//

#import "LMUController.h"
#include <math.h>

@interface LMUController ()

@property CFRunLoopTimerRef updateTimer;

@property (weak) NSTimer* callbackTimer;

@end

@implementation LMUController

+ (LMUController*)singleton{
    static dispatch_once_t pred = 0;
    static LMUController* shared;
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });

    return shared;
}

- (instancetype)init {
    return self;
}

- (void)startMonitoring {
    // Check if timer already exists of if any screens exist
    if(_callbackTimer && ([controls.screens count] == 0)) return;

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];

    // NSTimer objects cannot be reused after invalidation
    _callbackTimer = [NSTimer scheduledTimerWithTimeInterval:[defaults floatForKey:@"LMUUpdateInterval"]
                                                      target:self
                                                    selector:@selector(updateTimerCallBack)
                                                    userInfo:nil
                                                     repeats:YES];
    self.monitoring = YES;
    [_delegate LMUControllerDidStartMonitoring];
    
    NSLog(@"LMUController: Started Monitoring");
}

- (void)stopMonitoring {
    [_callbackTimer invalidate];
    _callbackTimer = nil;

    self.monitoring = NO;
    [_delegate LMUControllerDidStopMonitoring];
    NSLog(@"LMUController: Stopped Monitoring");
}

- (float) getSystemBrightness {
    
    io_iterator_t iterator;
    kern_return_t result = IOServiceGetMatchingServices(kIOMasterPortDefault,
                                                        IOServiceMatching("IODisplayConnect"),
                                                        &iterator);
    
    // If we were successful
    if (result == kIOReturnSuccess)
    {
        io_object_t service;
        while ((service = IOIteratorNext(iterator))) {
            
            float level;
            IODisplayGetFloatParameter(service, kNilOptions, CFSTR(kIODisplayBrightnessKey), &level);
            // Let the object go
            IOObjectRelease(service);
            
            return level;
        }
    }
}

- (float)getScale {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults floatForKey:@"LMUScale"];
}

- (void)updateTimerCallBack {

    float value = self.getSystemBrightness;
    int newPercent = fmin(value * 100 * self.getScale, 100.0);
    NSLog(@"\nnewPercent: %i\nvalue: %f\ngetScale: %f", newPercent, value, self.getScale);
    
    for(Screen* screen in controls.screens) {
        
        [self doUpdate:screen:newPercent];
        
        
    }
}

- (void)doUpdate: (Screen*)screen :(int)percent {
    
    if ([screen.currentAutoAttribute isEqualToString:@"BR"])
        [screen setBrightnessWithPercentage:percent byOutlet:nil];
    else
        [screen setContrastWithPercentage:percent byOutlet:nil];
}

/*+ (bool) monitoring {
    if (self.monitoring == YES)
        return YES;
    else
        return NO;
}*/

@end
