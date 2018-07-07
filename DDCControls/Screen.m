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

@end

@implementation Screen

- (instancetype)initWithModel:(NSString*)model screenID:(CGDirectDisplayID)screenID serial:(NSString*)serial {
    if ((self = [super init])) {
        _model = [model copy];
        _screenNumber = screenID;
        _serial = [serial copy];

        _brightnessOutlets = [NSMutableArray array];
        _contrastOutlets = [NSMutableArray array];
    }

    return self;
}

- (void)refreshValues {
    struct DDCReadCommand cBrightness = [controls readDisplay:self.screenNumber controlValue:BRIGHTNESS];
    struct DDCReadCommand cContrast   = [controls readDisplay:self.screenNumber controlValue:CONTRAST];

    if (!cBrightness.success && !cContrast.success)
        return;

    self.currentBrightness = cBrightness.current_value;
    self.maxBrightness = cBrightness.max_value;

    self.currentContrast = cContrast.current_value;
    self.maxContrast = cContrast.max_value;

    [self updateBrightnessOutlets:_brightnessOutlets];
    [self updateContrastOutlets:_contrastOutlets];

    NSLog(@"Screen: %@ outlets set to BR %ld / CON %ld", _model , (long)self.currentBrightness, (long)self.currentContrast);
}

- (void)ddcReadOut {
    for (int i=0x00; i<=255; i++) {
        struct DDCReadCommand response = [controls readDisplay:self.screenNumber controlValue:i];
        NSLog(@"VCP: %x - %d / %d \n", i, response.current_value, response.max_value);
    }
}

- (void)setBrightness:(NSInteger)brightness {
    if (brightness > self.maxBrightness)
        brightness = self.maxBrightness;

    [controls changeDisplay:self.screenNumber control:BRIGHTNESS withValue:(int)brightness];
    self.currentBrightness = brightness;

#ifdef DEBUG
    NSLog(@"Screen: %@ - %ud Brightness changed to %ld", _model, self.screenNumber, (long)self.currentBrightness);
#endif
}

- (void)setBrightnessWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setBrightness:((self.maxBrightness) * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setBrightness:(NSInteger)brightness byOutlet:(NSView*)outlet {
    if (brightness == self.currentBrightness)
        return;
    else
        [self setBrightness:brightness];

    NSMutableArray* dirtyOutlets = [_brightnessOutlets mutableCopy];
    if (outlet)
        [dirtyOutlets removeObject:outlet];

    [self updateBrightnessOutlets:dirtyOutlets];
}

- (void)updateBrightnessOutlets:(NSArray*)outlets {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id outlet in outlets) {
            if (![outlet isKindOfClass:[NSTextField class]])
                [outlet setMaxValue:self.maxBrightness];
            
            [outlet setIntegerValue:self.currentBrightness];
        }
    });
}

- (void)setContrast:(NSInteger)contrast {
    if (contrast > self.maxContrast)
        contrast = self.maxContrast;

    [controls changeDisplay:self.screenNumber control:CONTRAST withValue:(int)contrast];
    self.currentContrast = contrast;

#ifdef DEBUG
    NSLog(@"Screen: %@ - %ud Contrast changed to %ld", _model, self.screenNumber, (long)self.currentContrast);
#endif
}

- (void)setContrastWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setContrast:(self.maxContrast * ((double)(percentage)/100)) byOutlet:outlet];
}

- (void)setContrast:(NSInteger)contrast byOutlet:(NSView*)outlet {
    if (contrast == self.currentContrast)
        return;
    else
        [self setContrast:contrast];

    NSMutableArray* dirtyOutlets = [_contrastOutlets mutableCopy];
    if (outlet)
        [dirtyOutlets removeObject:outlet];

    [self updateContrastOutlets:dirtyOutlets];
}

- (void)updateContrastOutlets:(NSArray*)outlets {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (id outlet in outlets) {
            if (![outlet isKindOfClass:[NSTextField class]])
                [outlet setMaxValue:self.maxContrast];
            
            [outlet setIntegerValue:self.currentContrast];
        }
    });
}

@end
