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

@property (strong) NSMutableArray* brightnessOutlets;
@property (strong) NSMutableArray* contrastOutlets;

@property (strong, readonly) NSString* currentAutoAttribute;


- (instancetype)initWithModel:(NSString*)model screenID:(CGDirectDisplayID)screenID serial:(NSString*)serial;

- (void)refreshValues;
- (void)ddcReadOut;

- (void)setBrightnessWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setBrightness:(NSInteger)brightness byOutlet:(NSView*)outlet;

- (void)setContrastWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setContrast:(NSInteger)contrast byOutlet:(NSView*)outlet;

- (void)setAutoAttribute:(NSString*)attribute;

@end
