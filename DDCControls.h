//
//  DDCControls.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//

#import <Foundation/Foundation.h>

@interface DDCControls : NSObject

@property int localBrightness;                                   // Used as a local record of brightness/contrast
@property int localContrast;                                     // in order to lower data requests to displays

+ (DDCControls *)singleton;

- (int)readControlValue:(int)control;
- (void)changeControl:(int)control withValue:(int)value;

- (id)init;

- (void)readOut;

- (void)refreshLocalValues;

- (void)setBrightness:(int)brightness;
- (void)setContrast:(int)contrast;

- (void)setPreset:(int)preset;
- (int)getPreset;

- (void)setOSDLock:(int)lock;
- (int)getOSDLock;

- (void)setRed:(int)newRed;
- (int)getRed;

- (void)setBlue:(int)newBlue;
- (int)getBlue;

- (void)setGreen:(int)newGreen;
- (int)getGreen;


@end
