//
//  Screen.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 1/30/16.
//
//

#import "Screen.h"

@interface Screen ()

@property (strong, readwrite) NSString* model;
@property (readwrite) CGDirectDisplayID screenNumber;
@property (strong, readwrite) NSString* serial;

@property (readwrite) NSInteger currentBrightness;
@property (readwrite) NSInteger maxBrightness;

@property (readwrite) NSInteger currentContrast;
@property (readwrite) NSInteger maxContrast;

@property (readwrite) NSInteger currentRed;
@property (readwrite) NSInteger maxRed;
@property (readwrite) NSInteger currentGreen;
@property (readwrite) NSInteger maxGreen;
@property (readwrite) NSInteger currentBlue;
@property (readwrite) NSInteger maxBlue;

@end

@implementation Screen

- (instancetype)initWithModel:(NSString*)model screenID:(CGDirectDisplayID)screenID serial:(NSString*)serial {
    if((self = [super init])){
        _model = [model copy];
        self.screenNumber = screenID;
        _serial = [serial copy];

        _brightnessOutlets = [NSMutableArray array];
        _contrastOutlets = [NSMutableArray array];
        _redOutlets = [NSMutableArray array];
        _greenOutlets = [NSMutableArray array];
        _blueOutlets = [NSMutableArray array];
    }

    return self;
}

- (void)refreshValues {
    struct DDCReadCommand cBrightness = [controls readDisplay:self.screenNumber controlValue:BRIGHTNESS];
    struct DDCReadCommand cContrast   = [controls readDisplay:self.screenNumber controlValue:CONTRAST];
    
    struct DDCReadCommand cRed   = [controls readDisplay:self.screenNumber controlValue:RED_GAIN];
    struct DDCReadCommand cGreen = [controls readDisplay:self.screenNumber controlValue:GREEN_GAIN];
    struct DDCReadCommand cBlue  = [controls readDisplay:self.screenNumber controlValue:BLUE_GAIN];

    self.currentBrightness = cBrightness.current_value;
    self.maxBrightness = cBrightness.max_value;

    self.currentContrast = cContrast.current_value;
    self.maxContrast = cContrast.max_value;
    
    self.currentRed = cRed.current_value;
    self.maxRed = cRed.max_value;
    
    self.currentGreen = cGreen.current_value;
    self.maxGreen = cGreen.max_value;
    
    self.currentBlue = cBlue.current_value;
    self.maxBlue = cBlue.max_value;

    NSLog(@"Screen: %@ set BR %ld CON %ld", _model , (long)self.currentBrightness, (long)self.currentContrast);
}

- (void)ddcReadOut {
    for(int i=0x00; i<=255; i++){
        struct DDCReadCommand response = [controls readDisplay:self.screenNumber controlValue:i];
        NSLog(@"VCP: %x - %d / %d \n", i, response.current_value, response.max_value);
    }

}

- (void)setBrightness:(NSInteger)brightness {
    if(brightness > self.maxBrightness)
        brightness = self.maxBrightness;

    [controls changeDisplay:self.screenNumber control:BRIGHTNESS withValue: brightness];
    self.currentBrightness = brightness;

    NSLog(@"Screen: %@ - %ud Brightness changed to %ld", _model, self.screenNumber, (long)self.currentBrightness);
}

- (void)setBrightnessWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setBrightness:((self.maxBrightness) * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setBrightness:(NSInteger)brightness byOutlet:(NSView*)outlet {
    if(brightness == self.currentBrightness)
        return;
    else
        [self setBrightness:brightness];

    NSMutableArray* dirtyOutlets = [_brightnessOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];

    for(id dirtyOutlet in dirtyOutlets)
        [dirtyOutlet setIntegerValue:self.currentBrightness];
}

- (void)setBrightnessRelativeToValue:(NSString *)value {
    // relative setting: read, calculate, then write
    NSString *value_num = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+"]];
    NSString *formula = [NSString stringWithFormat:@"%ld %@ %@", (long)self.currentBrightness, [value substringFromIndex:value.length - 1], value_num];
    NSExpression *exp = [NSExpression expressionWithFormat:formula];
    NSNumber *value_set = [exp expressionValueWithObject:nil context:nil];
    
    if ((value_set.intValue > self.maxContrast) || (value_set.intValue < 0)) return;
    
    [controls changeDisplay:self.screenNumber control:BRIGHTNESS withValue: value_set.intValue];
    self.currentBrightness = value_set.intValue;

    // update the sliders, this fails with multiple screens
    for(id outlet in _brightnessOutlets) [outlet setIntegerValue:self.currentBrightness];
    
    NSLog(@"Screen: %@ - %ud Brightness changed to %ld", _model, self.screenNumber, (long)self.currentBrightness);
}

- (void)setContrast:(NSInteger)contrast {
    if(contrast > self.maxContrast)
        contrast = self.maxContrast;

    [controls changeDisplay:self.screenNumber control:CONTRAST withValue: contrast];
    self.currentContrast = contrast;

    NSLog(@"Screen: %@ - %ud Contrast changed to %ld", _model, self.screenNumber, (long)self.currentContrast);
}

- (void)setContrastWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setContrast:(self.maxContrast * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setContrast:(NSInteger)contrast byOutlet:(NSView*)outlet {
    if(contrast == self.currentContrast)
        return;
    else
        [self setContrast:contrast];

    NSMutableArray* dirtyOutlets = [_contrastOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];

    for(id dirtyOutlet in dirtyOutlets)
        [dirtyOutlet setIntegerValue:self.currentContrast];
}

- (void)setContrastRelativeToValue:(NSString *)value {
    // relative setting: read, calculate, then write
    NSString *value_num = [value stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-+"]];
    NSString *formula = [NSString stringWithFormat:@"%ld %@ %@", (long)self.currentContrast, [value substringFromIndex:value.length - 1], value_num];
    NSExpression *exp = [NSExpression expressionWithFormat:formula];
    NSNumber *value_set = [exp expressionValueWithObject:nil context:nil];
    
    if ((value_set.intValue > self.maxContrast) || (value_set.intValue < 0)) return;
    
    [controls changeDisplay:self.screenNumber control:CONTRAST withValue: value_set.intValue];
    self.currentContrast = value_set.intValue;
    
    
    // update the sliders, this fails with multiple screens
    for(id outlet in _contrastOutlets) [outlet setIntegerValue:self.currentContrast];
    
    NSLog(@"Screen: %@ - %ud Contrast changed to %ld", _model, self.screenNumber, (long)self.currentContrast);
}



- (void)setRed:(NSInteger)red {
    if(red > self.maxRed)
        red = self.maxRed;
    
    [controls changeDisplay:self.screenNumber control:RED_GAIN withValue: red];
    self.currentRed = red;
    
    NSLog(@"Screen: %@ - %ud Red changed to %ld", _model, self.screenNumber, (long)self.currentRed);
}

- (void)setRedWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setRed:(self.maxRed * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setRed:(NSInteger)red byOutlet:(NSView*)outlet {
    if(red == self.currentRed)
        return;
    else
        [self setRed:red];
    
    NSMutableArray* dirtyOutlets = [_redOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];
    
    for(id dirtyOutlet in dirtyOutlets)
        [dirtyOutlet setIntegerValue:self.currentRed];
}


- (void)setGreen:(NSInteger)green {
    if(green > self.maxGreen)
        green = self.maxGreen;
    
    [controls changeDisplay:self.screenNumber control:GREEN_GAIN withValue: green];
    self.currentGreen = green;
    
    NSLog(@"Screen: %@ - %ud Green changed to %ld", _model, self.screenNumber, (long)self.currentGreen);
}

- (void)setGreenWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setGreen:(self.maxGreen * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setGreen:(NSInteger)green byOutlet:(NSView*)outlet {
    if(green == self.currentGreen)
        return;
    else
        [self setGreen:green];
    
    NSMutableArray* dirtyOutlets = [_greenOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];
    
    for(id dirtyOutlet in dirtyOutlets)
        [dirtyOutlet setIntegerValue:self.currentGreen];
}


- (void)setBlue:(NSInteger)blue {
    if(blue > self.maxBlue)
        blue = self.maxBlue;
    
    [controls changeDisplay:self.screenNumber control:BLUE_GAIN withValue: blue];
    self.currentBlue = blue;
    
    NSLog(@"Screen: %@ - %ud Blue changed to %ld", _model, self.screenNumber, (long)self.currentBlue);
}

- (void)setBlueWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setBlue:(self.maxBlue * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setBlue:(NSInteger)blue byOutlet:(NSView*)outlet {
    if(blue == self.currentBlue)
        return;
    else
        [self setBlue:blue];
    
    NSMutableArray* dirtyOutlets = [_blueOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];
    
    for(id dirtyOutlet in dirtyOutlets)
        [dirtyOutlet setIntegerValue:self.currentBlue];
}

@end
