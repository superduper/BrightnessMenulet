/*
 *  ddc.c
 *  ddc
 *
 *  Created by Jonathan Taylor on 07/10/2009.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

#include <assert.h>
#include <stdio.h>
#include "ddc.h"

/*
 IOFramebufferPortFromCGDisplayID based on: https://github.com/kfix/ddcctl/commit/0d66010890f99aa0972bb1478b41dda6329f52b4
 
 Iterate IOreg's device tree to find the IOFramebuffer mach service port that corresponds to a given CGDisplayID
 replaces CGDisplayIOServicePort: https://developer.apple.com/library/mac/documentation/GraphicsImaging/Reference/Quartz_Services_Ref/index.html#//apple_ref/c/func/CGDisplayIOServicePort
 based on: https://github.com/glfw/glfw/pull/192/files
 */
#include <IOKit/graphics/IOGraphicsLib.h>
static io_service_t IOFramebufferPortFromCGDisplayID(CGDirectDisplayID displayID)
{
    io_iterator_t iter;
    io_service_t serv, servicePort = 0;
    
    kern_return_t err = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(IOFRAMEBUFFER_CONFORMSTO), &iter);
    
    if (err != KERN_SUCCESS)
        return 0;
    
    // now recurse the IOReg tree
    while ((serv = IOIteratorNext(iter)) != MACH_PORT_NULL)
    {
        CFDictionaryRef info;
        io_name_t	name;
        CFIndex vendorID, productID, serialNumber = 0;
        CFNumberRef vendorIDRef, productIDRef, serialNumberRef;
#ifdef DEBUG
        CFStringRef location = CFSTR("");
        CFStringRef serial = CFSTR("");
#endif
        Boolean success = 0;
        
        // get metadata from IOreg node
        IORegistryEntryGetName(serv, name);
        info = IODisplayCreateInfoDictionary(serv, kIODisplayOnlyPreferredName);
        
#ifdef DEBUG
        /* When assigning a display ID, Quartz considers the following parameters:Vendor, Model, Serial Number and Position in the I/O Kit registry */
        // http://opensource.apple.com//source/IOGraphics/IOGraphics-179.2/IOGraphicsFamily/IOKit/graphics/IOGraphicsTypes.h
        CFStringRef locationRef = CFDictionaryGetValue(info, CFSTR(kIODisplayLocationKey));
        if (locationRef) location = CFStringCreateCopy(NULL, locationRef);
        CFStringRef serialRef = CFDictionaryGetValue(info, CFSTR(kDisplaySerialString));
        if (serialRef) serial = CFStringCreateCopy(NULL, serialRef);
#endif
        if (CFDictionaryGetValueIfPresent(info, CFSTR(kDisplayVendorID), (const void**)&vendorIDRef))
        success = CFNumberGetValue(vendorIDRef, kCFNumberCFIndexType, &vendorID);
        
        if (CFDictionaryGetValueIfPresent(info, CFSTR(kDisplayProductID), (const void**)&productIDRef))
        success &= CFNumberGetValue(productIDRef, kCFNumberCFIndexType, &productID);
        
        IOItemCount busCount;
        IOFBGetI2CInterfaceCount(serv, &busCount);
        
        if (!success || busCount < 1) {
            // this does not seem to be a DDC-enabled display, skip it
            CFRelease(info);
            continue;
        } else {
            // MacBook built-in screens have IOFBI2CInterfaceIDs=(0) but do not respond to DDC comms
            // they also do not have a BusType: IOFBI2CInterfaceInfo = ({"IOI2CBusType"=1 .. })
            // if (framebuffer.hasDDCConnect(0)) // https://developer.apple.com/reference/kernel/ioframebuffer/1813510-hasddcconnect?language=objc
            // kDisplayBundleKey
            // kAppleDisplayTypeKey -- if this is an Apple display, can use IODisplay func to change brightness: http://stackoverflow.com/a/32691700/3878712
        }
        
        if (CFDictionaryGetValueIfPresent(info, CFSTR(kDisplaySerialNumber), (const void**)&serialNumberRef))
        CFNumberGetValue(serialNumberRef, kCFNumberCFIndexType, &serialNumber);
        
        // compare IOreg's metadata to CGDisplay's metadata to infer if the IOReg's I2C monitor is the display for the given NSScreen.displayID
        if (CGDisplayVendorNumber(displayID) != vendorID  ||
            CGDisplayModelNumber(displayID)  != productID ||
            CGDisplaySerialNumber(displayID) != serialNumber) // SN is zero in lots of cases, so duplicate-monitors can confuse us :-/
        {
            CFRelease(info);
            continue;
        }
#ifdef DEBUG
        // considering this IOFramebuffer as the match for the CGDisplay, dump out its information
        printf("\nFramebuffer: %s\n", name);
        printf("%s\n", CFStringGetCStringPtr(location, kCFStringEncodingUTF8));
        printf("VN:%ld PN:%ld SN:%ld", vendorID, productID, serialNumber);
        printf(" UN:%d", CGDisplayUnitNumber(displayID));
        printf(" IN:%d", iter);
        printf(" Serial:%s\n\n", CFStringGetCStringPtr(serial, kCFStringEncodingUTF8));
#endif
        servicePort = serv;
        CFRelease(info);
        break;
    }
    
    IOObjectRelease(iter);
    return servicePort;
}

IOI2CConnectRef display_connection(CGDirectDisplayID display_id) {
    kern_return_t kr;
    io_service_t framebuffer, interface;
    IOOptionBits bus;
    IOItemCount busCount;
    
    //printf("Querying for displayid: %d\n", display_id);
    //framebuffer = CGDisplayIOServicePort(display_id))) // Deprecated since OSX 10.9
    framebuffer = IOFramebufferPortFromCGDisplayID(display_id);
    
    io_string_t path;
    kr = IORegistryEntryGetPath(framebuffer, kIOServicePlane, path);
    if(KERN_SUCCESS != kr) // display path find failed
        return nil;
    
    kr = IOFBGetI2CInterfaceCount(framebuffer, &busCount );
    assert(kIOReturnSuccess == kr);
    
    for(bus = 0; bus < busCount; bus++){
        IOI2CConnectRef connect;
        
        kr = IOFBCopyI2CInterfaceForBus(framebuffer, bus, &interface);
        if(kIOReturnSuccess != kr)
            continue;
        
        kr = IOI2CInterfaceOpen(interface, kNilOptions, &connect);
        
        IOObjectRelease(interface);
        assert(kIOReturnSuccess == kr);
        if(kIOReturnSuccess != kr)
            continue;
        
        IOObjectRelease(framebuffer);
        return connect;
    }
    
    IOObjectRelease(framebuffer);
    return nil;
}

int ddc_write(CGDirectDisplayID display_id, struct DDCWriteCommand* p_write) {
    UInt8 data[128];
    IOI2CRequest request;
    kern_return_t kr;
    
    IOI2CConnectRef connect = display_connection(display_id);
    if(!connect)
        return 0;
    
    bzero(&request, sizeof(request));
    
    request.commFlags           = 0;
    request.sendAddress         = 0x6e;
    request.sendTransactionType = kIOI2CSimpleTransactionType;
	request.sendBuffer          = (vm_address_t) &data[0];
	request.sendBytes           = 7;
    
    data[0] = 0x51;
    data[1] = 0x84;
    data[2] = 0x03;
    data[3] = (*p_write).control_id;
    data[4] = 0x1;
    data[5] = (*p_write).new_value;
    data[6] = 0x6E ^ data[0] ^ data[1] ^ data[2] ^ data[3] ^ data[4] ^ data[5];
    
    request.replyTransactionType    = kIOI2CNoTransactionType;
	request.replyBytes              = 0;
    
	kr = IOI2CSendRequest(connect, kNilOptions, &request);
	IOI2CInterfaceClose(connect, kNilOptions);

	assert(kIOReturnSuccess == kr);
	if(kIOReturnSuccess != request.result)
        return 0;
    
    return 1;
}

int ddc_read(CGDirectDisplayID display_id, struct DDCReadCommand* p_read) {
    UInt8 data[128];
    IOI2CRequest request;
    kern_return_t kr;
    UInt8 reply_data[11];
    
    IOI2CConnectRef connect = display_connection(display_id);
    if(!connect)
        return 0;

	int successful_reads = 0;
	int max_reads = 10;
	
	for (int i=0; i<max_reads; i++) {
		bzero(&request, sizeof(request));
		
		request.commFlags           = 0;
		request.sendAddress         = 0x6E;
		request.sendTransactionType = kIOI2CSimpleTransactionType;
		request.sendBuffer          = (vm_address_t) &data[0];
		request.sendBytes           = 5;
		
		data[0] = 0x51;
		data[1] = 0x82;
		data[2] = 0x01; // We want to read this time
		data[3] = (*p_read).control_id;
		
		data[4] = 0x6E ^ data[0] ^ data[1] ^ data[2] ^ data[3];
		
		request.replyAddress            = 0x6f;
		request.replyTransactionType    = kIOI2CSimpleTransactionType;
        
		request.replyBuffer             = (vm_address_t) &reply_data[0] ;
		request.replyBytes              = sizeof(reply_data);
		request.minReplyDelay           = 10;
		
		int calculated_checksum;
        
		bzero(&reply_data[0], request.replyBytes);
		
		kr = IOI2CSendRequest(connect, kNilOptions, &request);
		calculated_checksum = 0x6f ^ 0x51 ^ reply_data[1] ^ reply_data[2] ^ reply_data[3] ^ reply_data[4]^ reply_data[5]^ reply_data[6]^ reply_data[7]^ reply_data[8]^ reply_data[9];
		
		if ((reply_data[10] == calculated_checksum) && reply_data[4] == data[3] ) {
			successful_reads++;
			break;
		}
		//fprintf(stderr, "READ ERROR\n");
	}
	
	IOI2CInterfaceClose(connect, kNilOptions);
    
	if (successful_reads == 0) {
		printf("Error getting result\n");
		return 0;
	}
	
	(*p_read).response.max_value = reply_data[7];
	(*p_read).response.current_value = reply_data[9];
	
	assert(kIOReturnSuccess == kr);
	if(kIOReturnSuccess != request.result) {
        printf("Error getting result\n");
        return 0;
    }
    
    return 1;
}

void EDIDRead(CGDirectDisplayID display_id, struct EDID* edid) {
    kern_return_t kr;
    IOI2CConnectRef connect;
    IOI2CRequest request;
    UInt8 data[128];
    
    if(!(connect = display_connection(display_id)))
       return;
    
    bzero( &request, sizeof(request) );
    
    request.commFlags	    	= 0;
    request.sendAddress			= 0xA0;
    request.sendTransactionType	= kIOI2CSimpleTransactionType;
    request.sendBuffer			= (vm_address_t)&data[0];
    request.sendBytes	    	= 0x01;
    data[0] 		    		= 0x00;
    
    request.replyAddress            = 0xA1;
    request.replyTransactionType	= kIOI2CSimpleTransactionType;
    request.replyBuffer	    		= (vm_address_t)&data[0];
    request.replyBytes	    		= sizeof(data);
    bzero( &data[0], request.replyBytes );
    
    kr = IOI2CSendRequest(connect, kNilOptions, &request);
    assert(kIOReturnSuccess == kr);
    if(kIOReturnSuccess != request.result)
        return;
    
    if(edid) memcpy(edid, &data, 128);
    
    UInt32 i = 0;
    UInt8 sum = 0;
    while(i < request.replyBytes) {
        if(i % 128 == 0) {
            if(sum)break;
            sum = 0;
        }
        sum += data[i++];
    }
    
    IOI2CInterfaceClose(connect, kNilOptions);
}

