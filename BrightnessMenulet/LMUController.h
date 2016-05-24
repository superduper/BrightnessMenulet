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

#import "LMUDelegate.h"

@interface LMUController : NSObject

@property (weak) id<LMUDelegate> delegate;

@property BOOL monitoring;

+ (LMUController*)singleton;

- (instancetype)init;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
