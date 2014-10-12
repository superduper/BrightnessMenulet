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

+ (DDCControls *)singleton{
    static dispatch_once_t pred = 0;
    static DDCControls *shared;
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

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

- (id)init{
    if(self = [super init]){
        // TODO: Lower data requests to display
        [self setLocalBrightness:[self readControlValue:BRIGHTNESS]];
        [self setLocalContrast:[self readControlValue:CONTRAST]];
    }
    
    return self;
}

- (void)readOut{
    for(int i=0x00; i<=255; i++)
        printf("%x - %x\n", i, [self readControlValue:i]);
    exit(1);
}

/* Not only to Dell U2414h
 
 12 - Color presets (1 standard, 2 gaming ...)
 
 60h - Input Source
 
 D6 - Power
 01h - on
 02h - Off stand by
 03h - Off suspend
 04h - Off
 ￼￼￼￼05h - Power off the display – functionally equivalent to turning off power using the “power button”
 */

- (void)refreshLocalValues{
    [self setLocalBrightness:[self readControlValue:BRIGHTNESS]];
    [self setLocalContrast:[self readControlValue:CONTRAST]];
}

// TODO: check whether controls were actually set
- (void)setBrightness:(int)brightness{
	[self changeControl:0x10 withValue:brightness];
    [self setLocalBrightness:brightness];
}

- (void)setContrast:(int)contrast{
	[self changeControl:0x12 withValue:contrast];
    [self setLocalContrast:contrast];
}

- (void)setPreset:(int)preset{
    /*
     Standard:
     Multimedia:
     Movie: (Hue Sat availible)  0xDC - 3
     Game:   (Hue Sat availible) 0XDC - 5
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
    [self changeControl:0x16 withValue:newRed];
}
- (int)getRed{
    return [self readControlValue:0x16];
}

- (void)setGreen:(int)newGreen{
    [self changeControl:0x18 withValue:newGreen];
}
- (int)getGreen{
    return [self readControlValue:0x18];
}

- (void)setBlue:(int)newBlue{
    [self changeControl:0x1A withValue:newBlue];
}
- (int)getBlue{
    return [self readControlValue:0x1A];
}

@end
