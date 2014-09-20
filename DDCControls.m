//
//  DDCControls.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//
#import "ddc.h"
#import "DDCControls.h"

@implementation DDCControls

- (int)readControlValue:(int)control{
	struct DDCReadCommand read_command;
	read_command.control_id = control;
    
	ddc_read(0, &read_command);
	return ((int)read_command.response.current_value);
}

- (void)changeControl:(int)control withValue:(int)value{
	struct DDCWriteCommand write_command;
	write_command.control_id = control;
	write_command.new_value = value;
	ddc_write(0, &write_command);
}

- (void)readOut{
    for(int i=0x00; i<=255; i++)
        printf("%x - %d\n", i, [self readControlValue:i]);
    exit(1);
}

/* Corresponding to Dell U2414h
 
 12 - Color presets (1 standard, 2 gaming ...)
 0xB0 or 0XCA OSD Lock
 
 D6 - Power
 01h - on
 ￼￼￼
 02h - Off stand by
 ￼
 03h - Off suspend
 ￼￼
 04h - Off
 ￼￼￼￼05h - Power off the display – functionally equivalent to turning off power using the “power button”
 */

- (int)currentBrightness{
	return [self readControlValue:BRIGHTNESS];
}

- (void)setBrightness:(int)brightness{
	[self changeControl:0x10 withValue:brightness];
}

- (int)currentContrast{
	return [self readControlValue:CONTRAST];
}

- (void)setContrast:(int)contrast{
	[self changeControl:0x12 withValue:contrast];
}

- (void)setPreset:(int)preset{
    /*
     Standard:
     Multimedia:
     Movie: (Hue Sat availible)
     Game:   (Hue Sat availible)
     Paper:
     Color Temp 5000K, 5700K, 6500K, 7500K, 9300K and 10000K
     sRGB: Emulates 72 % NTSC color.
     Custom Color:
    */
    [self changeControl:12 withValue:preset];
}

- (int)getPreset{
    return [self readControlValue:12];
}

- (void)setOSDLock:(int)lock{
    // 1 - lock disabled, 2 - lock enabled
    [self changeControl:0xCA withValue:lock];
}

- (int)getOSDLock{
    return [self readControlValue:0xCA];
}

- (void)setRed:(int)newRed{
    [self changeControl:22 withValue:newRed];
}
- (int)getRed{
    return [self readControlValue:22];
}

- (void)setBlue:(int)newBlue{
    [self changeControl:24 withValue:newBlue];
}
- (int)getBlue{
    return [self readControlValue:24];
}

- (void)setGreen:(int)newGreen{
    [self changeControl:26 withValue:newGreen];
}
- (int)getGreen{
    return [self readControlValue:26];
}

@end
