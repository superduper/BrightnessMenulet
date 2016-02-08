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
    if((self = [super init])){
        _model = [model copy];
        self.screenNumber = screenID;
        _serial = [serial copy];

        _brightnessOutlets = [NSMutableArray array];
        _contrastOutlets = [NSMutableArray array];
    }

    return self;
}

- (void)refreshValues {
    struct DDCReadResponse cBrightness = [controls readDisplay:self.screenNumber controlValue:BRIGHTNESS];
    struct DDCReadResponse cContrast   = [controls readDisplay:self.screenNumber controlValue:CONTRAST];

    self.currentBrightness = cBrightness.current_value;
    self.maxBrightness = cBrightness.max_value;

    self.currentContrast = cContrast.current_value;
    self.maxContrast = cContrast.max_value;

    NSLog(@"Screen: %@ set BR %ld CON %ld", _model , (long)self.currentBrightness, (long)self.currentContrast);
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

@end
