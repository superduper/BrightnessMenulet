//
//  DDCControls.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//

#import <Foundation/Foundation.h>
#import "ddc.h"

#define Model @"Model"
#define ScreenNumber @"ScreenNumber"
#define Serial @"Serial"
#define CurrentBrightness @"CURRENTBRIGHTNESS"
#define MaxBrightness @"MAXBRIGHTNESS"
#define CurrentContrast @"CURRENTCONTRAST"
#define MaxContrast @"MAXCONTRAST"

@interface DDCControls : NSObject

@property NSArray* screens;
@property NSMutableDictionary* profiles;

+ (DDCControls*)singleton;

- (id)init;

- (void)refreshScreens;
- (void)refreshScreenValues;

- (void)applyProfile:(NSString*)profile;

- (NSDictionary*)screenForDisplayName:(NSString*)name;
- (NSDictionary*)screenForDisplayID:(CGDirectDisplayID)display_id;

- (void)setScreenID:(CGDirectDisplayID)display_id brightness:(int)brightness;
- (void)setScreenID:(CGDirectDisplayID)display_id contrast:(int)contrast;

- (void)setScreen:(NSDictionary*)scr brightness:(int)brightness;
- (void)setScreen:(NSDictionary*)scr contrast:(int)contrast;

@end
