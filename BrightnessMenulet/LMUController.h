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

@property id<LMUDelegate> delegate;

@property BOOL monitoring;

- (instancetype)initWithDelegate:(id<LMUDelegate>)delegate;

- (void)startMonitoring;
- (void)stopMonitoring;

@end
