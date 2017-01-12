//
//  Screen.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 1/30/16.
//
//

#import "Screen.h"

#define CLAMP(x, low, high) ({\
__typeof__(x) __x = (x); \
__typeof__(low) __low = (low);\
__typeof__(high) __high = (high);\
__x > __high ? __high : (__x < __low ? __low : __x);\
})

@interface Screen ()

@property (strong, readwrite) NSString* model;
@property (readwrite) CGDirectDisplayID screenNumber;
@property (strong, readwrite) NSString* serial;

@property (readwrite) NSInteger currentBrightness;
@property (readwrite) NSInteger maxBrightness;

@property (readwrite) NSInteger currentContrast;
@property (readwrite) NSInteger maxContrast;

@property (strong, readwrite) NSString* currentAutoAttribute;


@end

@implementation Screen

- (instancetype)initWithModel:(NSString*)model screenID:(CGDirectDisplayID)screenID serial:(NSString*)serial {
    if((self = [super init])){
        _model = [model copy];
        self.screenNumber = screenID;
        _serial = [serial copy];

        _brightnessOutlets = [NSMutableArray array];
        _contrastOutlets = [NSMutableArray array];
        
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        if([[[defaults dictionaryRepresentation] allKeys] containsObject:[NSString stringWithFormat: @"autoAttribute_%@", self.model]]){
            _currentAutoAttribute = [defaults stringForKey:[NSString stringWithFormat: @"autoAttribute_%@", self.model]];
        } else {
            [defaults setObject:@"BR" forKey:[NSString stringWithFormat: @"autoAttribute_%@", self.model]];
            _currentAutoAttribute = @"BR";
        }
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
    [self setBrightness:(self.maxBrightness * ((double)(CLAMP(percentage,0,100))/100)) byOutlet:outlet];
}

- (void)setBrightness:(NSInteger)brightness byOutlet:(NSView*)outlet {
    if(brightness == self.currentBrightness)
        return;
    else
        [self setBrightness:brightness];

    NSMutableArray* dirtyOutlets = [_brightnessOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];

    [self updateBrightnessOutlets:dirtyOutlets];
}

- (void)updateBrightnessOutlets:(NSArray*)outlets {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(id outlet in outlets){
            if(![outlet isKindOfClass:[NSTextField class]])
                [outlet setMaxValue:_maxBrightness];
            
            [outlet setIntegerValue:_currentBrightness];
        }
    });
}

- (void)setContrast:(NSInteger)contrast {
    if(contrast > self.maxContrast)
        contrast = self.maxContrast;

    [controls changeDisplay:self.screenNumber control:CONTRAST withValue: contrast];
    self.currentContrast = contrast;

    NSLog(@"Screen: %@ - %ud Contrast changed to %ld", _model, self.screenNumber, (long)self.currentContrast);
}

- (void)setContrastWithPercentage:(NSInteger)percentage byOutlet:(NSView*)outlet {
    [self setContrast:(self.maxContrast * ((double)(CLAMP(percentage,0,100))/100)) byOutlet:outlet];
}

- (void)setContrast:(NSInteger)contrast byOutlet:(NSView*)outlet {
    if(contrast == self.currentContrast)
        return;
    else
        [self setContrast:contrast];

    NSMutableArray* dirtyOutlets = [_contrastOutlets mutableCopy];
    if(outlet)
        [dirtyOutlets removeObject:outlet];

    [self updateContrastOutlets:dirtyOutlets];
}

- (void)updateContrastOutlets:(NSArray*)outlets {
    dispatch_async(dispatch_get_main_queue(), ^{
        for(id outlet in outlets){
            if(![outlet isKindOfClass:[NSTextField class]])
                [outlet setMaxValue:_maxContrast];
            
            [outlet setIntegerValue:_currentContrast];
        }
    });
}

- (void)setAutoAttribute:(NSString*)attribute {
    self.currentAutoAttribute = attribute;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSLog(@"setAutoAttribute: %@ ", self.currentAutoAttribute);
    [defaults setObject:self.currentAutoAttribute forKey:[NSString stringWithFormat: @"autoAttribute_%@", self.model]];
    
}


@end
