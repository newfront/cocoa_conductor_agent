//
//  spawn_taskAppDelegate.m
//  spawn_task
//
//  Created by Scott Haines on 7/27/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import "spawn_taskAppDelegate.h"
#import "SipParser.h"
#import "RegexKitLite.h"

@implementation spawn_taskAppDelegate

@synthesize window;
@synthesize task_button;
@synthesize task_response;
@synthesize t_controller;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    t_controller = [[ThreadController alloc] initWithObject:self];
    
    
    /*
     SHOW THAT SIP PARSER IS WORKING
    */
    NSString *sip_message = @"#    U 2011/08/04 16:48:32.010346 192.168.1.156:42114 -> 81.23.228.129:5060 ACK sip:6178512065@sip2sip.info SIP/2.0..Via: SIP/2.0/UDP 192.168.1.156:42114;branch=z9hG4bK-d8754z-36d7274218f4774c-1---d8754z-;rport..Max-Forwards: 70..To: \"6178512065\"<sip:6178512065@sip2sip.info>;tag=e7d4d6b46afb9bf88242924a8d869ebf.4b01..From: \"Scott Haines\"<sip:newfront@sip2sip.info>;tag=46c67063..Call-ID: OTk4OTc1MDdiN2E3NmUyZThkYjBlOTllMjI4N2ViZGU...CSeq: 2 ACK..Content-Length: 0....#";
    
    NSString *message = @"U 2011/08/04 16:48:31.631821 192.168.1.156:42114 -> 81.23.228.129:5060 INVITE sip:6178512065@sip2sip.info SIP/2.0..Via: SIP/2.0/UDP 192.168.1.156:42114;branch=z9hG4bK-d8754z-9325ee5b48c85235-1---d8754z-;rport..Max-Forwards: 70..Contact: <sip:newfront@192.168.1.156:42114>..To: \"6178512065\"<sip:6178512065@sip2sip.info>..From: \"Scott Haines\"<sip:newfront@sip2sip.info>;tag=46c67063..Call-ID: OTk4OTc1MDdiN2E3NmUyZThkYjBlOTllMjI4N2ViZGU...CSeq: 1 INVITE..Allow: INVITE, ACK, CANCEL, OPTIONS, BYE, REFER, NOTIFY, MESSAGE, SUBSCRIBE, INFO..Content-Type: application/sdp..Supported: replaces..User-Agent: X-Lite 4 release 4.0 stamp 58833..Content-Length: 558....v=0..o=- 1312501711449269 1 IN IP4 192.168.1.156..s=CounterPath X-Lite 4.0..c=IN IP4 66.202.154.30..t=0 0..a=ice-ufrag:c604d2..a=ice-pwd:4f02bb33dd12385fcbd004809d27116a..m=audio 53550 RTP/AVP 0 101..a=rtpmap:101 telephone-event/8000..a=fmtp:101 0-15..a=sendrecv..a=candidate:1 1 UDP 659136 192.168.1.156 53550 typ host..a=candidate:2 1 UDP 659084 66.202.154.30 53550 typ srflx raddr 192.168.1.156 rport 53550..a=candidate:1 2 UDP 659134 192.168.1.156 53551 typ host..a=candidate:2 2 UDP 659082 66.202.154.30 53551 typ srflx raddr 192.168.1.156 rport 53551..##";
    
    SipParser *parser = [[SipParser alloc] init];
    [parser parseSipMessage:message];
    
    SipParser *no_body_parser = [[SipParser alloc] init];
    [no_body_parser parseSipMessage:sip_message];
    
    [parser release];
    [no_body_parser release];
    [sip_message release];
    [message release];
}

-(IBAction) spawn_task:(id)sender
{
    NSLog(@"%@",[task_button stringValue]);
    if([task_button.title isEqualToString:@"Launch NGREP"])
    {
    NSLog(@"Spawn new task...ngrep");
    [NSThread detachNewThreadSelector:@selector(ngrepRunner:) toTarget:t_controller withObject:nil];
        task_button.title = @"Stop NGREP";
    }
    else
    {
        if([t_controller isRunning] == YES)
        {
            NSLog(@"time to stop task");
            [t_controller killTask];
            task_button.title = @"Launch NGREP";
        }
        else
        {
            NSLog(@"no reason to stop task. it is stopped");
            task_button.title = @"Launch NGREP";
        }
    }
}

-(void) task_responded:(NSString *)message
{
    NSLog(@"Task responded with %@", message);
    [task_response setStringValue:message];
}

-(void) checkATaskStatus:(NSNotification *) notification
{
    int status = [[notification object] terminationStatus];
    if(status == 0)
        NSLog(@"Task Succeeded");
    else
        NSLog(@"Task failed");
}

-(id) init
{
    self = [super init];
    return self;
}

-(void) dealloc
{
    [super dealloc];
}


@end
