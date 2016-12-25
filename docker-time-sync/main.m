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

void SleepCallBack( void * refCon, io_service_t service, natural_t messageType, void * messageArgument )
{
    NSLog( @"messageType %08lx, arg %08lx\n",
           (long unsigned int)messageType,
           (long unsigned int)messageArgument );
    
    if (messageType == kIOMessageSystemHasPoweredOn) {
        NSLog(@"Started to sync time...");
        // docker run --rm -it --privileged --pid=host walkerlee/nsenter -t 1 -m -u -i -n ntpd -d -q -n -p pool.ntp.org
        NSTask *task = [[NSTask alloc] init];
        NSArray *arguments = [NSArray arrayWithObjects:@"run", @"--rm", @"-it", @"--privileged", @"--pid=host", @"walkerlee/nsenter", [NSString stringWithFormat: @"%@ %@",@"-t",@"1"], @"-m", @"-u", @"-i", @"-n", @"ntpd", @"-d", @"-q", @"-n", @"-p", @"pool.ntp.org", nil];
        [task setLaunchPath: @"/usr/local/bin/docker"];
        [task setArguments: arguments];
        task.terminationHandler = ^(NSTask *aTask){
            NSLog(@"\nDone!\n");
        };
        [task launch];
    }
}


int main( int argc, char **argv )
{
    io_connect_t  root_port;
    IONotificationPortRef notifyPortRef;
    io_object_t notifierObject;
    void* refCon;
    
    root_port = IORegisterForSystemPower(refCon, &notifyPortRef, SleepCallBack, &notifierObject);
    if (root_port == 0)
    {
        printf("IORegisterForSystemPower failed\n");
        return 1;
    }
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(),
                       IONotificationPortGetRunLoopSource(notifyPortRef), kCFRunLoopCommonModes);
    CFRunLoopRun();
}
