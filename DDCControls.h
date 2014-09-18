//
//  DDCControls.h
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//

#import <Foundation/Foundation.h>

@interface DDCControls : NSObject

- (int)readControlValue:(int)control;
- (void)changeControl:(int)control withValue:(int)value;

- (void)setBrightness:(int)brightness;
- (int)currentBrightness;

- (void)setContrast:(int)contrast;
- (int)currentContrast;

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
