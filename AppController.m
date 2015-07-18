#import "ddc.h"
#import "AppController.h"
#include <IOKit/graphics/IOGraphicsLib.h>


@implementation AppController
const int kMaxDisplays = 16;
const CFStringRef kDisplayBrightness = CFSTR(kIODisplayBrightnessKey);
static double updateInterval = 5.0;
static io_connect_t dataPort = 0;
static double oldPercentValue = -1;

- (BOOL) isDarkMode {
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] persistentDomainForName:NSGlobalDomain];
    id style = [dict objectForKey:@"AppleInterfaceStyle"];
    return ( style && [style isKindOfClass:[NSString class]] && NSOrderedSame == [style caseInsensitiveCompare:@"dark"] );

}

- (void) setMenuIcon{
    
    //Used to detect where our files are
    NSBundle *bundle = [NSBundle mainBundle];
    
    NSString* iconImageName = @"icon";
    NSString* altIconImageName = @"icon-alt";
    
    if ([self isDarkMode]){
        iconImageName = @"icon-alt";
        altIconImageName = @"icon";
    }
    
    //Allocates and loads the images into the application which will be used for our NSStatusItem
    statusImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:iconImageName ofType:@"png"]];
    statusHighlightImage = [[NSImage alloc] initWithContentsOfFile:[bundle pathForResource:altIconImageName ofType:@"png"]];
    
    //Sets the images in our NSStatusItem
    [statusItem setImage:statusImage];
    [statusItem setAlternateImage:statusHighlightImage];
}

- (void) initLMUController{
    kern_return_t kr;
    io_service_t serviceObject;
    
    serviceObject = IOServiceGetMatchingService(kIOMasterPortDefault, IOServiceMatching("AppleLMUController"));
    if (!serviceObject) {
        fprintf(stderr, "failed to find ambient light sensors\n");
        exit(1);
    }
    
    kr = IOServiceOpen(serviceObject, mach_task_self(), 0, &dataPort);
    IOObjectRelease(serviceObject);
    if (kr != KERN_SUCCESS) {
        mach_error("IOServiceOpen:", kr);
        exit(kr);
    }
    
    setbuf(stdout, NULL);
    printf("%8ld %8ld", 0L, 0L);
    
    [NSTimer scheduledTimerWithTimeInterval:updateInterval
                                     target:self selector:@selector(updateTimerCallBack) userInfo:nil repeats:YES];
}

- (void) updateTimerCallBack {
    kern_return_t kr;
    uint32_t outputs = 2;
    uint64_t values[outputs];
    
    kr = IOConnectCallMethod(dataPort, 0, nil, 0, nil, 0, values, &outputs, nil, 0);
    if (kr == KERN_SUCCESS) {
            
        const double value = values[0]/1000000.0;
        int percent = 0;
        
        if (value > 10.0){
            percent = 99;
        }else if (value > 0.9){
            percent = 55;
        }else if (value > 0.09){
            percent = 33;
        }else if (value > 0.009){
            percent = 22;
        }else{
            percent = 1;
        }
        
        if (oldPercentValue != percent){
            oldPercentValue = percent;
            NSLog(@"original value>> %llu, value> %f , percent>> %d", values[0], value, percent);
            
            [mySlider setIntValue:percent];
            [self set_brightness:percent];
            
            return;
        }else{
            return;
        }
    }
    
    if (kr == kIOReturnBusy) {
        return;
    }
    
    mach_error("I/O Kit error:", kr);
    exit(kr);
}

- (void) awakeFromNib{
	
	//Create the NSStatusBar and set its length
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength] retain];
    
    [self setMenuIcon];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(setMenuIcon) name:@"AppleInterfaceThemeChangedNotification" object:nil];

	
	//Tells the NSStatusItem what menu to load
	[statusItem setMenu:statusMenu];
	//Sets the tooptip for our item
	[statusItem setToolTip:@"Brightness Menulet"];
    
	[mySlider setIntValue:[self get_brightness]];
	//Enables highlighting
	[statusItem setHighlightMode:YES];
	
	[mySlider becomeFirstResponder];
    [self initLMUController];
		
}


- (int) get_brightness {
	struct DDCReadCommand read_command;
	read_command.control_id = 0x10;
    
	ddc_read(0, &read_command);
	return ((int)read_command.response.current_value);
}

- (void) set_brightness:(int) new_brightness {
    //oldPercentValue = new_brightness;
    
	struct DDCWriteCommand write_command;
	write_command.control_id = 0x10;
	write_command.new_value = new_brightness;
	ddc_write(0, &write_command);
}

- (void) dealloc {
	//Releases the 2 images we loaded into memory
	[statusImage release];
	[statusHighlightImage release];
	[super dealloc];
}


-(IBAction)sliderUpdate:(id)sender{
	int value = [sender intValue];
    NSLog(@"Got brightness %d", value);
	[self set_brightness:value];

}

-(IBAction)exit:(id)sender{
	NSLog(@"goodvnye there!");
	exit(1);
}


@end