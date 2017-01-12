//
//  DDCControls.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//

#import <Foundation/Foundation.h>
#import "ddc.h"

#import "Screen.h"

@interface DDCControls : NSObject

@property NSArray* screens;
@property NSMutableDictionary* profiles;

+ (DDCControls*)singleton;

- (NSString*)EDIDString:(char*) string;
- (struct DDCReadCommand)readDisplay:(CGDirectDisplayID)display_id controlValue:(int)control;
- (void)changeDisplay:(CGDirectDisplayID)display_id control:(int)control withValue:(int)value;

- (void)refreshScreens;
- (void)refreshScreenValues;

- (Screen*)screenForDisplayName:(NSString*)name;
- (Screen*)screenForDisplayID:(CGDirectDisplayID)display_id;

@end
