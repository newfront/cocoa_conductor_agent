//
//  spawn_taskAppDelegate.h
//  spawn_task
//
//  Created by Scott Haines on 7/27/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ThreadController.h"

@interface spawn_taskAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    NSButton *task_button;
    NSTextField *task_response;
    ThreadController *t_controller;
    
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSButton *task_button;
@property (assign) IBOutlet NSTextField *task_response;
@property (assign) ThreadController *t_controller;

-(IBAction) spawn_task:(id) sender;
-(void) task_responded:(NSString *) message;
-(void) checkATaskStatus:(NSNotification *) notification;
//-(id) init;

@end
