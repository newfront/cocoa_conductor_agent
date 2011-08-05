//
//  ThreadController.h
//  spawn_task
//
//  Created by Scott Haines on 8/1/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

@class spawn_taskAppDelegate;

@interface ThreadController : NSObject {
    NSMutableArray *threads;
    spawn_taskAppDelegate *callingClass;
    NSTask *pipeTask;
    NSPipe *readPipe;
    NSPipe *writePipe;
    NSFileHandle *readHandle;
    NSFileHandle *writeHandle;
    BOOL isRunning;
}
@property (assign) NSMutableArray *threads;
@property (assign) NSTask *pipeTask;
@property (assign) spawn_taskAppDelegate *callingClass;
@property (assign, readwrite) BOOL isRunning;
@property (assign) NSFileHandle *readHandle,*writeHandle;

-(id) initWithObject:(id) klass;

-(void) ngrepRunner:(id) param;
-(void) killTask;
-(void) processData:(NSData *) data;

@end
