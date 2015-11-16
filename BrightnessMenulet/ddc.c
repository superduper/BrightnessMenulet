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

IOI2CConnectRef display_connection(CGDirectDisplayID display_id) {
    kern_return_t kr;
    io_service_t framebuffer, interface;
    IOOptionBits bus;
    IOItemCount busCount;

    //printf("Querying for displayid: %d\n", display_id);
    framebuffer = CGDisplayIOServicePort(display_id); // fixme! - CGDisplayIOServicePort deprecated

    // BUG: should pass nil if path cannot be found. or delay thread till path is established in IOReg
    io_string_t path;
    kr = IORegistryEntryGetPath(framebuffer, kIOServicePlane, path);
    assert(KERN_SUCCESS == kr);

    kr = IOFBGetI2CInterfaceCount( framebuffer, &busCount );
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

        return connect;
    }

    return nil;
}

int ddc_write(CGDirectDisplayID display_id, struct DDCWriteCommand* p_write) {
    UInt8 data[128];
    IOI2CRequest request;
    kern_return_t kr;
    
    IOI2CConnectRef connect = display_connection(display_id);
    
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

	int successful_reads = 0;
	
	for (int i=0; i<60; i++) {
		bzero( &request, sizeof(request));
		
		request.commFlags           = 0;
		request.sendAddress         = 0x6E;
		request.sendTransactionType = kIOI2CDDCciReplyTransactionType;
		request.sendBuffer          = (vm_address_t) &data[0];
		request.sendBytes           = 5;
		
		data[0] = 0x51;
		data[1] = 0x82;
		data[2] = 0x01; // We want to read this time
		data[3] = (*p_read).control_id;
		
		data[4] = 0x6E ^ data[0] ^ data[1] ^ data[2] ^ data[3];
		
		request.replyAddress            = 0x6f;
		request.replyTransactionType    = kIOI2CDDCciReplyTransactionType;
        
		request.replyBuffer             = (vm_address_t) &reply_data[0] ;
		request.replyBytes              = sizeof(reply_data);
		//request.minReplyDelay = 50 * 10000;   // causes Kernal panic
		
		int calculated_checksum;
        
		bzero( &reply_data[0], request.replyBytes);
		
        kr = IOI2CSendRequest( connect, kNilOptions, &request );
		calculated_checksum = 0x6f ^ 0x51 ^ reply_data[1] ^ reply_data[2] ^ reply_data[3] ^ reply_data[4]^ reply_data[5]^ reply_data[6]^ reply_data[7]^ reply_data[8]^ reply_data[9];
		
		if ((reply_data[10] == calculated_checksum) && reply_data[4] == data[3] ) {
			successful_reads++;
			if (successful_reads > 1)
				break;
			
		}
		//fprintf(stderr, "READ ERROR\n");
		
	}
	
	IOI2CInterfaceClose(connect, kNilOptions);
	
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

