//
//  SipParser.h
//  regular_expressions_c_to_objc
//
//  Created by Scott Haines on 8/4/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SipParser : NSObject {
    NSString *sip_packet; // original message
    
    //NSMutableDictionary *packet_header;
    NSMutableDictionary *sip_header;
    NSMutableDictionary *sip_body;
    
    /* Packet Header Parsed Values */
    NSString *packet_header;
    NSString *s_packet_direction; // U or T , U is from user, T is from 3rd party
    NSString *s_packet_timestamp; // Timestamp
    NSString *s_packet_date; // Date
    NSString *s_caller_ipaddress;
    NSString *s_caller_port;
    NSString *s_callee_ipaddress;
    NSString *s_callee_port;
    
    NSString *s_header;
    NSString *s_body;
}
/* 
 synthized variables
 */

@property (copy, nonatomic) NSString *sip_packet, *packet_header;
@property (assign) NSString *s_packet_direction, *s_packet_timestamp, *s_packet_date,*s_caller_ipaddress,*s_caller_port, *s_callee_ipaddress, *s_callee_port, *s_header, *s_body;

-(void) parseSipMessage:(NSString *) message;
-(NSString *) clean_packet:(NSString *) packet;
-(void) parsePacketHeader:(NSString *) p_header;
-(void) parseSipHeader:(NSString *) header;
-(void) parseSipBody:(NSString *) body;

@end
