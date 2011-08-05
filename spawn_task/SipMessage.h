//
//  SipMessage.h
//  spawn_task
//
//  Created by Scott Haines on 8/5/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SipMessage : NSObject {
    NSMutableDictionary *sip_header;
    NSMutableDictionary *sip_body;
    NSArray *a_sip_header;
    NSArray *a_sip_body;
}

/*
 need to return type,to,from,contact
*/

-(id) initWithHeader:(NSString *) header andSipBody:(NSString *) body;
-(void) parseHeader:(NSArray *) a_header;
-(void) parseBody:(NSArray *) a_body;
-(NSString *) print;

@end
