//
//  SipMessage.m
//  spawn_task
//
//  Created by Scott Haines on 8/5/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import "SipMessage.h"
#import "RegexKitLite.h"

/*
 SipMessage creates a key:value dictionary for
  - SipHeader
  - SipBody
*/

@implementation SipMessage


-(id) initWithHeader:(NSArray *) header andSipBody:(NSArray *) body
{
    self = [super init];
    if(self)
    {
        a_sip_header = header;
        a_sip_body = body;
        [self parseHeader:a_sip_header];
        [self parseBody:a_sip_body];
    }
    return self;
}

-(void) parseHeader:(NSArray *) a_header
{
    /*
     Cycle through Header NSArray
     Line by Line parse into NSMutableDictionary
    */
}

-(void) parseBody:(NSArray *) a_body
{
    /*
     If Body count > 0, continue
     Cycle through Body NSArray
     Line by Line parse into NSMutableDictionary
     */
}

-(NSString *) print
{
    return @"todo";
}

- (id)init
{
    return [self initWithHeader:NULL andSipBody:NULL];
}

- (void)dealloc
{
    [super dealloc];
}

@end
