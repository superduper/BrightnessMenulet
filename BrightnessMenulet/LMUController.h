//
//  LMUController.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 1/29/16.
//
//

#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#include <CoreFoundation/CoreFoundation.h>

@interface LMUController : NSObject

@property BOOL monitoring;

- (instancetype)init;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
