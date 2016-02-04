//
//  LMUController.m
//  BrightnessMenulet
//
//  Created by Kalvin Loc on 1/29/16.
//
//

#import "LMUController.h"

@interface LMUController ()

@property CFRunLoopTimerRef updateTimer;
@property io_connect_t lmuDataPort;

@property (weak) NSTimer* callbackTimer;

@property (strong) NSMutableArray* percentHistory;

@end

@implementation LMUController

- (instancetype)init {
    if((self = [super init])){
        _lmuDataPort = 0;

        [self getLMUDataPort];
    }

    return self;
}

- (void)dealloc {
    [self closeLMUPort];
}

- (io_connect_t)getLMUDataPort {
    kern_return_t kr;
    io_service_t serviceObject;

    if(_lmuDataPort) return _lmuDataPort;

    serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleLMUController"));

    if(!serviceObject){
        NSLog(@"LMUController: Failed to find LMU\n");
        return 0;
    }

    // Create a connection to the IOService object
    kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &_lmuDataPort);
    IOObjectRelease(serviceObject);

    if(kr != KERN_SUCCESS){
        NSLog(@"LMUController: Failed to open LMU IOService object");
        return 0;
    }

    return _lmuDataPort;
}

- (void)closeLMUPort {
    IOServiceClose(_lmuDataPort);
    _lmuDataPort = 0;
}

- (void)startMonitoring {
    double updateInterval = 2.0;

    // Check if timer already exists of if any screens exist
    if(_callbackTimer && ([controls.screens count] == 0)) return;

    // NSTimer objects cannot be reused after invalidation
    _callbackTimer = [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                                      target:self
                                                    selector:@selector(updateTimerCallBack)
                                                    userInfo:nil
                                                     repeats:YES];
    NSLog(@"LMUController: Started Monitoring");
}

- (void)stopMonitoring {
    [_callbackTimer invalidate];
    _callbackTimer = nil;

    NSLog(@"LMUController: Stopped Monitoring");
}

// MODIFY caluclated percent here
- (NSInteger)percentForSensorValue:(double)sensorVal {
    // log10(x+1) scale (Weber-Fechner Law)
    NSInteger percent = log10(sensorVal + 1) * 10;
    // lower percentage with p = 100 - x
    percent -= (100 - percent);
    if(percent < 0)
        percent = 0;

    return percent;
}

- (void)updateTimerCallBack {
    uint64_t inputValues[0], outputValues[2];
    uint32_t inputCount = 0, outputCount = 2;
    kern_return_t kr;

    // 0 = Sensor Reading
    kr = IOConnectCallScalarMethod(_lmuDataPort, 0, inputValues, inputCount, outputValues, &outputCount);
    
    if(kr != KERN_SUCCESS){
        //printf("error getting light sensor values\n");
        return;
    }

    double max = 67092480.0;
    double avgSensorValue = ((double)(outputValues[0] + outputValues[1]))/2;

    // Check if fetched sensor value is over max. If so, lid must be closed
    if(avgSensorValue > max){
        NSLog(@"LMUController: No sensor found or Lid closed");
        [self stopMonitoring];
        return;
    }

    double percent = [self percentForSensorValue:avgSensorValue];

    // Add percent to history queue
    if(_percentHistory.count == 4)
        [_percentHistory removeObjectAtIndex:0];
    [_percentHistory addObject:[NSNumber numberWithInteger:percent]];

    BOOL needsUpdate = NO;
    if(_percentHistory.count == 4){
        if([_percentHistory[2] integerValue] == percent){
            needsUpdate = YES;
        }
    }else
        needsUpdate = YES;

    if(needsUpdate)
        for(Screen* screen in controls.screens)
            [screen setBrightness:percent byOutlet:nil];
}

@end
