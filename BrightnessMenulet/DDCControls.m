//
//  DDCControls.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 9/17/14.
//
//

#import "DDCControls.h"

@implementation DDCControls

+ (DDCControls*)singleton{
    static dispatch_once_t pred = 0;
    static DDCControls* shared;
    dispatch_once(&pred, ^{
        shared = [[self alloc] init];
    });
    
    return shared;
}

// // EDID credits to https://github.com/kfix/ddcctl
- (NSString*)EDIDString:(char*) string {
    NSString* temp = [[NSString alloc] initWithBytes:string length:13 encoding:NSASCIIStringEncoding];

    return ([temp rangeOfString:@"\n"].location != NSNotFound)
    ? [[temp componentsSeparatedByString:@"\n"] objectAtIndex:0]
    : temp;
}

- (struct DDCReadResponse)readDisplay:(CGDirectDisplayID)display_id controlValue:(int)control{
    struct DDCReadCommand read_command;
    read_command.control_id = control;

    if(ddc_read(display_id, &read_command) != 1)
        NSLog(@"readDisplay:%u withValue: failed need to retry...", display_id);

    return read_command.response;
}

- (void)changeDisplay:(CGDirectDisplayID)display_id control:(int)control withValue:(int)value{
    struct DDCWriteCommand write_command;
    write_command.control_id = control;
    write_command.new_value = value;

    if(ddc_write(display_id, &write_command) != 1)
        NSLog(@"writeDisplay:%u withValue: failed need to retry...", display_id);
}

- (void)refreshScreens{
    NSLog(@"DDCControls: Refreshing Screens");
    NSMutableArray* newScreens = [NSMutableArray array];
    
    for(NSScreen* screen in [NSScreen screens]) {
        // Must call unsignedIntValue to get val
        NSNumber* screenNumber = screen.deviceDescription[@"NSScreenNumber"];
        
        struct EDID edid = {};
        EDIDRead([screenNumber unsignedIntegerValue], &edid);
        
        NSString* name;
        NSString* serial;
        for (NSValue *value in @[[NSValue valueWithPointer:&edid.descriptor1], [NSValue valueWithPointer:&edid.descriptor2], [NSValue valueWithPointer:&edid.descriptor3], [NSValue valueWithPointer:&edid.descriptor4]]) {
            union descriptor *des = value.pointerValue;
            switch (des->text.type) {
                case 0xFF:
                    serial = [self EDIDString:des->text.data];
                    break;
                case 0xFC:
                    name = [self EDIDString:des->text.data];
                    break;
            }
        }

        // don't want to manage invalid screen or integrated LCD
        if(!name || [name isEqualToString:@"Color LCD"]) continue;
        
        NSMutableDictionary* scr = [NSMutableDictionary dictionaryWithDictionary:@{
                              Model : name,
                              ScreenNumber : screenNumber,
                              Serial : serial,
                              CurrentBrightness : @-1,
                              MaxBrightness : @-1,
                              CurrentContrast : @-1,
                              MaxContrast : @-1
                              }];
        
        [newScreens addObject:scr];
        NSLog(@"DDCControls: Found %@ - %@", name, screenNumber);
    }

    _screens = [newScreens copy];
    if([newScreens count] == 0)
        NSLog(@"DDCControls: No screens found");
    else{
        [self refreshScreenValues];
    }
}

- (void)refreshScreenValues{
    for(NSMutableDictionary* screen in _screens){
        NSUInteger screenID = [screen[ScreenNumber] unsignedIntegerValue];
        struct DDCReadResponse cBrightness = [self readDisplay:screenID controlValue:BRIGHTNESS];
        struct DDCReadResponse cContrast   = [self readDisplay:screenID controlValue:CONTRAST];
        
        [screen setObject:[NSNumber numberWithUnsignedChar:cBrightness.current_value] forKey:CurrentBrightness];
        [screen setObject:[NSNumber numberWithUnsignedChar:cBrightness.max_value]     forKey:MaxBrightness];
        [screen setObject:[NSNumber numberWithUnsignedChar:cContrast.current_value]   forKey:CurrentContrast];
        [screen setObject:[NSNumber numberWithUnsignedChar:cContrast.max_value]       forKey:MaxContrast];

        NSLog(@"%@ set BR %d CR %d", screen[Model] , cBrightness.current_value, cContrast.current_value);
    }
}

- (NSDictionary*)screenForDisplayName:(NSString*)name {
    for(NSDictionary* screen in _screens)
        if ([screen[@"Model"] isEqualToString:name])
            return screen;
    
    return nil;
}

- (NSDictionary*)screenForDisplayID:(CGDirectDisplayID)display_id {
    for(NSDictionary* screen in _screens)
        if ([screen[@"ScreenNumber"] unsignedIntegerValue] == display_id)
            return screen;
    
    return nil;
}

- (void)setScreenID:(CGDirectDisplayID)display_id brightness:(int)brightness{
    NSDictionary* screen = [self screenForDisplayID:display_id];
    if(screen)
        [self setScreen:screen brightness:brightness];
}

- (void)setScreenID:(CGDirectDisplayID)display_id contrast:(int)contrast{
    NSDictionary* screen = [self screenForDisplayID:display_id];
    if(screen)
        [self setScreen:screen contrast:contrast];
}

- (void)setScreen:(NSDictionary*)scr brightness:(int)brightness {
    CGDirectDisplayID scrID = [scr[ScreenNumber] unsignedIntegerValue];
    
    [self changeDisplay:scrID control:BRIGHTNESS withValue:brightness];
    [scr setValue:[NSNumber numberWithInt:brightness] forKey:CurrentBrightness];
    
    NSLog(@"%ud Brightness changed to %d", scrID, brightness);
}

- (void)setScreen:(NSDictionary*)scr contrast:(int)contrast {
    CGDirectDisplayID scrID = [scr[ScreenNumber] unsignedIntegerValue];
    
    [self changeDisplay:scrID control:CONTRAST withValue:contrast];
    [scr setValue:[NSNumber numberWithInt:contrast] forKey:CurrentBrightness];
    
    NSLog(@"%ud Contrast changed to %d", scrID, contrast);
}

@end
