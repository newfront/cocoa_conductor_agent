//
//  spawn_taskAppDelegate.m
//  spawn_task
//
//  Created by Scott Haines on 7/27/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import "spawn_taskAppDelegate.h"

@implementation spawn_taskAppDelegate

@synthesize window;
@synthesize task_button;
@synthesize task_response;
@synthesize t_controller;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    t_controller = [[ThreadController alloc] initWithObject:self];
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
