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

@property (readonly) NSInteger currentRed;
@property (readonly) NSInteger maxRed;

@property (readonly) NSInteger currentGreen;
@property (readonly) NSInteger maxGreen;

@property (readonly) NSInteger currentBlue;
@property (readonly) NSInteger maxBlue;

@property (strong) NSMutableArray* brightnessOutlets;
@property (strong) NSMutableArray* contrastOutlets;

@property (strong) NSMutableArray* redOutlets;
@property (strong) NSMutableArray* greenOutlets;
@property (strong) NSMutableArray* blueOutlets;

- (instancetype)initWithModel:(NSString*)model screenID:(CGDirectDisplayID)screenID serial:(NSString*)serial;

- (void)refreshValues;
- (void)ddcReadOut;

- (void)setBrightnessWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setBrightness:(NSInteger)brightness byOutlet:(NSView*)outlet;

- (void)setContrastWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setContrast:(NSInteger)contrast byOutlet:(NSView*)outlet;

- (void)setRedWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setRed:(NSInteger)red byOutlet:(NSView*)outlet;
- (void)setGreenWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setGreen:(NSInteger)green byOutlet:(NSView*)outlet;
- (void)setBlueWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet;
- (void)setBlue:(NSInteger)blue byOutlet:(NSView*)outlet;

@end
