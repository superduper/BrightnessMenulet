//
//  DDCControls.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//

#import "DDCControls.h"

@interface DDCControls ()

@end

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
    // TODO: Lower data requests to display
    if(self = [super init]){
        [self refreshLocalValues];
        
        NSString *thePath = [[NSBundle mainBundle] pathForResource:@"userPresets" ofType:@"plist"];
        _presets = [[NSMutableDictionary alloc] initWithContentsOfFile:thePath];
    }
    
    return self;
}

- (void)readOut{
    for(int i=0x00; i<=0xFF; i++)
        printf("%x - %x\n", i, [self readControlValue:i]);
    
    exit(1);
}

- (void)refreshLocalValues{
    [self setNumberOfDisplays:number_of_displays()];
    [self setLocalBrightness:[self readControlValue:BRIGHTNESS]];
    [self setLocalContrast:[self readControlValue:CONTRAST]];
}

- (void)handleClickedPreset:(NSString*)preset{
    NSDictionary* presetInfo;
    
    if((presetInfo = _presets[preset])){
        for(NSString* display in presetInfo){
            NSDictionary* settings = presetInfo[display];
            
            for(NSString* setting in settings){
                if([setting isEqualToString:@"BRIGHTNESS"])
                    [self setBrightness:[settings[setting] intValue]];
                else if([setting isEqualToString:@"CONTRAST"])
                    [self setContrast:[settings[setting] intValue]];
                else
                    NSLog(@"Error: Invalid setting key - %@", setting);
            }
            
        }
    }else
        NSLog(@"Unknown preset %@", preset);
}

- (void)setBrightness:(int)brightness{
	[self changeControl:BRIGHTNESS withValue:brightness];
    [self setLocalBrightness:brightness];
    
    NSLog(@"Brightness changed to %d", brightness);
}

- (void)setContrast:(int)contrast{
	[self changeControl:CONTRAST withValue:contrast];
    [self setLocalContrast:contrast];
    
    NSLog(@"Contrast changed to %d", contrast);
}

- (void)setPreset:(int)preset{
    /*
     Relevent to Dell U2414h
     Standard:
     Multimedia:
     Movie: (Hue Sat availible)  0xDC - 3
     Game:   (Hue Sat availible) 0XDC - 5
     Paper:
     Color Temp 5000K, 5700K, 6500K, 7500K, 9300K and 10000K
     sRGB: Emulates 72 % NTSC color.
     Custom Color:
    */
    [self changeControl:0x0C withValue:preset];
}

// Better to pass by string preset name for flexibility
- (void)setColorPresetByString:(NSString *)presetString{
    if([presetString isEqualToString:@"Standard"])
        [self setPreset:0x01];
    else if([presetString isEqualToString:@"sRGB"])
        [self changeControl:0x14 withValue:0x01];
    else
        NSLog(@"unknown presetString: %@", presetString);
}

- (int)getColorPreset{
    return [self readControlValue:0x0C];
}

- (void)setOSDLock:(int)lock{
    // 01 - lock disabled, 02 - lock enabled
    [self changeControl:ON_SCREEN_DISPLAY withValue:lock];
}
- (int)getOSDLock{
    return [self readControlValue:ON_SCREEN_DISPLAY];
}

- (void)setRed:(int)newRed{
    [self changeControl:RED_GAIN withValue:newRed];
}
- (int)getRed{
    return [self readControlValue:RED_GAIN];
}

- (void)setGreen:(int)newGreen{
    [self changeControl:GREEN_GAIN withValue:newGreen];
}
- (int)getGreen{
    return [self readControlValue:GREEN_GAIN];
}

- (void)setBlue:(int)newBlue{
    [self changeControl:BLUE_GAIN withValue:newBlue];
}
- (int)getBlue{
    return [self readControlValue:BLUE_GAIN];
}

@end

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
