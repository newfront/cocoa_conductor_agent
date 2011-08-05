//
//  ThreadController.m
//  spawn_task
//
//  Created by Scott Haines on 8/1/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import "ThreadController.h"
#import "spawn_taskAppDelegate.h"

#define NGREP_PATH @"/usr/local/bin/ngrep" 
#define NGREP_FILTER @"SIP/2.0"

#define IMPORTANT_PACKET_SIZE (NSUInteger) 200

@implementation ThreadController
@synthesize threads;
@synthesize pipeTask;
@synthesize callingClass;
@synthesize isRunning;
@synthesize readHandle, writeHandle;

-(id) initWithObject:(spawn_taskAppDelegate *) klass
{
    self = [super init];
    if(self)
    {
        callingClass = klass;
    }
    return self;
    
}

-(void) ngrepRunner:(id) param;
{
    NSLog(@"ngrep process instantiated by %@",param);
    if(isRunning == NO)
    {
        isRunning = YES;
        
        /*
         Start ngrep cycle
        */
        pipeTask = [[NSTask alloc] init];
        NSMutableArray *args = [NSMutableArray array];
        NSPipe *rPipe = [NSPipe pipe];
        NSPipe *wPipe = [NSPipe pipe];
        readHandle = [rPipe fileHandleForReading];
        writeHandle = [wPipe fileHandleForWriting];
        NSData *inData = nil;
        //[[[newPipe standardInput] fileHandleForWriting] writeData:inData];
        
        
        
        /* set nGrep args */
        
        [args addObject:@"-d"];
        [args addObject:@"en0"];
        [args addObject:@"-W"];
        [args addObject:@"single"];
        [args addObject:@"-pt"];
        
        /* SET BELOW good for testing http content */
        
        /*
         [args addObject:@"port"];
         [args addObject:@"80"];
        */
        
        /*
         ngrep -d en0 -qt -W single SIP/2.0
         */
        
        [args addObject:NGREP_FILTER];
        
        NSUInteger arrayCount = [args count];
        NSLog(@"array size: %g",arrayCount);
        
        [pipeTask setArguments:args];
        [args release];
        
        // write handle is closed to this process
        
        NSLog(@"%@",[pipeTask currentDirectoryPath]);
        
        /*
         NSPipe (attach to NSTask to receive STDIN, STDOUT)
         */
        [pipeTask setStandardOutput:rPipe];
        [pipeTask setStandardInput:wPipe];
        
        [pipeTask setCurrentDirectoryPath:@"/usr/local/bin/"];
        
        //NSLog(@"currentDirectoryPath: %@",[pipeTask currentDirectoryPath]);
        
        // must update /dev/bpf0 to be accesible from basic user
        // sudo chmod 775 /dev/bpf0 (ethernet)
        // sudo chmod 775 /dev/bpf1 (wifi)
        
        [pipeTask setLaunchPath:NGREP_PATH];
        //NSLog(@"launchPath: %@",[pipeTask launchPath]);
        
        [pipeTask launch];
        
        //NSLog(@"%@",[pipeTask currentDirectoryPath]);
        
        NSAutoreleasePool *pool = [NSAutoreleasePool new];
        while ((inData = [readHandle availableData]) && [inData length] && [self isRunning] == YES)
        {
            [self processData:inData];
        }
        
        // after we escape from the while loop
        // clean up memory
        
        @try {
            [pool drain];
        }
        @catch (NSException *exception) {
            NSLog(@"Error draining autorelease pool:\n%@\n%@", [exception name],[exception reason]);
        }
        @finally {
            NSLog(@"made it past pool drain issue.... maybe try again?");
        }
        
        NSLog(@"out of while loop....");
        
        [pipeTask terminate];
        
        /* end ngrep cycle */
        //sleep(3);
        
        NSLog(@"pool is what? %@",[pool class]);
        
        /*if([pool respondsToSelector:@selector(drain:)])
        {
            [pool drain];
             NSLog(@"drained....");
        }
        else
        {
            NSLog(@"pool can't be drained...");
        }
        */
        [readHandle release];
        [writeHandle release];
        [rPipe release];
        [wPipe release];
        [pipeTask release];
        isRunning = NO;
    }
    else
    {
        NSLog(@"Task is already running....");
        // kill task with writePipe command
    }
}

-(void) processData:(NSData *) data
{
    NSLog(@"\n\n\n\ncalled processData\n\n\n\n\n");
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    //NSString *other = [[NSString stringWithUTF8String:[data bytes]] autorelease];
    
    // if data packet is larger than 200 bytes
    if([data length] > IMPORTANT_PACKET_SIZE)
    {
        NSLog(@"data: %lu", [data length]);
        
        // clean up string
        // parse ip address
        // parse timestamp
        
        // FORMAT: U 2011/08/02 16:07:28.649933 192.168.1.156:45496 -> 85.17.186.7:5060
        // U (local)
        // T (remote)
        // Timestamp: Y/M/D H::M::S.milliseconds
        // IPv4(IPv6) split on -> IPv4(IPv6)
        // remove after parse
        // trim start and end of packet
        // break on CRLG \r\n
        // \r\n\r\n = end of header, start of body
        
        // [self parse:dataString] return NSMutableDictionary
        // keys: direction (to,from), timestamp, local_ip_address, remote_ip_address, header, body, type
        
        [callingClass task_responded:dataString];
    }
    
    // clean up memory
    [dataString release];
}

-(void) killTask
{
    if(isRunning == YES)
    {
        NSLog(@"terminating NGREP");
        isRunning = NO;
    }
}


/*- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
*/

- (void)dealloc
{
    [super dealloc];
}

@end
