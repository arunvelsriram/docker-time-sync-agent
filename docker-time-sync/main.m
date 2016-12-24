//
//  main.m
//  docker-time-sync
//
//  Created by ArunvelSriram on 25/12/16.
//  Copyright © 2016 ArunvelSriram. All rights reserved.
//

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>

#include <mach/mach_port.h>
#include <mach/mach_interface.h>
#include <mach/mach_init.h>

#include <IOKit/pwr_mgt/IOPMLib.h>
#include <IOKit/IOMessage.h>

#include <Foundation/NSTask.h>
#include <Foundation/NSString.h>
#include <Foundation/NSArray.h>

io_connect_t  root_port; // a reference to the Root Power Domain IOService

void
MySleepCallBack( void * refCon, io_service_t service, natural_t messageType, void * messageArgument )
{
    printf( "messageType %08lx, arg %08lx\n",
           (long unsigned int)messageType,
           (long unsigned int)messageArgument );
    
    NSTask *task = [[NSTask alloc] init];
    NSArray *arguments = [NSArray arrayWithObjects:@"run", @"--rm", @"-it", @"--privileged", @"--pid=host", @"walkerlee/nsenter", [NSString stringWithFormat: @"%@ %@",@"-t",@"1"], @"-m", @"-u", @"-i", @"-n", @"ntpd", @"-d", @"-q", @"-n", @"-p", @"pool.ntp.org", nil];
    [task setLaunchPath: @"/usr/local/bin/docker"];
    [task setArguments: arguments];
    
    switch ( messageType )
    {
            
        case kIOMessageCanSystemSleep:
            /* Idle sleep is about to kick in. This message will not be sent for forced sleep.
             Applications have a chance to prevent sleep by calling IOCancelPowerChange.
             Most applications should not prevent idle sleep.
             
             Power Management waits up to 30 seconds for you to either allow or deny idle
             sleep. If you don't acknowledge this power change by calling either
             IOAllowPowerChange or IOCancelPowerChange, the system will wait 30
             seconds then go to sleep.
             */
            
            //Uncomment to cancel idle sleep
            //IOCancelPowerChange( root_port, (long)messageArgument );
            // we will allow idle sleep
            IOAllowPowerChange( root_port, (long)messageArgument );
            NSLog(@"hello 1");
            break;
            
        case kIOMessageSystemWillSleep:
            /* The system WILL go to sleep. If you do not call IOAllowPowerChange or
             IOCancelPowerChange to acknowledge this message, sleep will be
             delayed by 30 seconds.
             
             NOTE: If you call IOCancelPowerChange to deny sleep it returns
             kIOReturnSuccess, however the system WILL still go to sleep.
             */
            
            IOAllowPowerChange( root_port, (long)messageArgument );
            NSLog(@"hello2");
            break;
            
        case kIOMessageSystemWillPowerOn:
            //System has started the wake up process...
            NSLog(@"hello3");
            break;
            
        case kIOMessageSystemHasPoweredOn:
            //System has finished waking up...
            NSLog(@"hello4");
            [task launch];
            break;
            
        default:
            break;
    }
}


int main( int argc, char **argv )
{
    // notification port allocated by IORegisterForSystemPower
    IONotificationPortRef  notifyPortRef;
    
    // notifier object, used to deregister later
    io_object_t            notifierObject;
    // this parameter is passed to the callback
    void*                  refCon;
    
    // register to receive system sleep notifications
    
    root_port = IORegisterForSystemPower( refCon, &notifyPortRef, MySleepCallBack, &notifierObject );
    if ( root_port == 0 )
    {
        printf("IORegisterForSystemPower failed\n");
        return 1;
    }
    
    // add the notification port to the application runloop
    CFRunLoopAddSource( CFRunLoopGetCurrent(),
                       IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopCommonModes );
    
    /* Start the run loop to receive sleep notifications. Don't call CFRunLoopRun if this code
     is running on the main thread of a Cocoa or Carbon application. Cocoa and Carbon
     manage the main thread's run loop for you as part of their event handling
     mechanisms.
     */
    CFRunLoopRun();
    
    // Not reached, CFRunLoopRun doesn't return in this case.
    // return (0);
}

