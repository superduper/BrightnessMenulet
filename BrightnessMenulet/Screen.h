//
//  Screen.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 1/30/16.
//
//

#import <Foundation/Foundation.h>
#import "ddc.h"

@interface Screen : NSObject

@property (strong, readonly) NSString* model;
@property (readonly) CGDirectDisplayID screenNumber;
@property (strong, readonly) NSString* serial;

@property (readonly) NSInteger currentBrightness;
@property (readonly) NSInteger maxBrightness;

@property (readonly) NSInteger currentContrast;
@property (readonly) NSInteger maxContrast;

// Weak array

- (instancetype)initWithModel:(NSString*)model screenID:(CGDirectDisplayID)screenID serial:(NSString*)serial;

- (void)refreshValues;

- (void)setBrightness:(NSInteger)brightness;
- (void)setContrast:(NSInteger)contrast;

@end
