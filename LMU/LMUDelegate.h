//
//  LMUDelegate.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 2/7/16.
//
//

#import <Foundation/Foundation.h>

@protocol LMUDelegate

- (void)LMUControllerDidStartMonitoring;
- (void)LMUControllerDidStopMonitoring;

@end

