//
//  SipParser.m
//  regular_expressions_c_to_objc
//
//  Created by Scott Haines on 8/4/11.
//  Copyright 2011 Convo Communications. All rights reserved.
//

#import "SipParser.h"
#import "RegexKitLite.h"

@implementation SipParser
@synthesize sip_packet, packet_header;
@synthesize s_packet_direction, s_packet_timestamp, s_packet_date, s_header, s_body;
@synthesize s_caller_ipaddress, s_caller_port, s_callee_ipaddress, s_callee_port;

-(void) parseSipMessage:(NSString *) message
{
    NSString *packet_header_regexp = @"^(U|T) ([0-9/]*[0-9]) ([0-9:]*)+(.[0-9]*) ([0-9.]*)+(:)+([0-9]*) (->) ([0-9.]*)(:)([0-9]*) "; //1: 28 'U 2011/08/02 15:40:37.643055
    //NSUInteger line = 0UL;
    NSArray *matches;
    
    // clean packet
    sip_packet = [self clean_packet:message];
    
    //NSLog(@"search body: %@", sip_packet);
    
    // grab full packet header
    matches = [sip_packet componentsMatchedByRegex:packet_header_regexp];
    for(NSString *match in matches)
    {
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        //packet_header = match;
        [self parsePacketHeader:match];
        sip_packet = [sip_packet substringFromIndex:[match length]];
    }
    //NSLog(@"SIP PACKET: %@",sip_packet);
    
    NSString *search = @"....";
    
    NSMutableString *m_sip_packet = [NSMutableString stringWithString:sip_packet];
    
    NSRange substr = [m_sip_packet rangeOfString:search];
    
    while (substr.location != NSNotFound)
    {
        //NSLog(@"match at: %@",NSStringFromRange(substr)); // {390, 4}
        //NSLog(@"packet length: %lu",[sip_packet length]); // 395
        // break header, body
        s_header = [sip_packet substringToIndex:substr.location];
        s_body = [sip_packet substringFromIndex:(substr.location + substr.length)];
        [m_sip_packet replaceCharactersInRange:substr withString:@""];
        substr = [m_sip_packet rangeOfString:search];
    }
    
    //NSLog(@"SIP Packet: %@", m_sip_packet);
    //NSLog(@"SIP HEADER: %@\n\n\n", s_header);
    
    [self parseSipHeader:s_header];
    
    //NSLog(@"SIP BODY: %@", s_body);
    [self parseSipBody:s_body];
}

-(NSString *) clean_packet:(NSString *) packet
{
    NSString *leading_whitespace_regexp = @"^(\\s*)";
    NSString *leading_hash_regexp = @"^\\W";
    
    /*
     Clean up stray Hashes and \n in packet
    */
    NSString *stray_hashes_newline_regexp = @"^(#*)\\n";
    //NSString *closing_hash_regexp = @"\\W$";
    //NSString *trailing_whitespace_regexp = @"\\s*$";
    
    NSUInteger line = 0UL;
    NSArray *matches;
    
    // kill opening hashes and newline
    matches = [packet componentsMatchedByRegex:stray_hashes_newline_regexp];
    for(NSString *match in matches)
    {
        NSLog(@"Search for Hashes followed by newline: %lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        packet = [packet substringFromIndex:[match length]];
    }
    
    // kill opening hash symbol
    matches = [packet componentsMatchedByRegex:leading_hash_regexp];
    for(NSString *match in matches)
    {
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        packet = [packet substringFromIndex:[match length]];
    }
    
    // kill closing hash symbol
    /*matches = [packet componentsMatchedByRegex:closing_hash_regexp];
     for(NSString *match in matches)
     {
     NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
     packet = [packet substringFromIndex:[match length]];
     }
     */
    
    // Strip Whitespace (leading)
    matches = [packet componentsMatchedByRegex:leading_whitespace_regexp];
    for(NSString *match in matches)
    {
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        packet = [packet substringFromIndex:[match length]];
    }
    return packet;
}

-(void) parsePacketHeader:(NSString *) p_header
{
    packet_header = p_header;
    
    NSLog(@"====================================\n");
    NSLog(@"PACKET HEADER");
    
    NSString *direction_regexp = @"^(U|T)";
    NSString *date_regexp = @"([0-9]*)(/)([0-9]*)(/)([0-9]*)";
    NSString *time_regexp = @"([0-9]*)(:)([0-9]*)(:)([0-9]*)(.)([0-9]*)";
    NSString *ip_port_regexp = @"([0-9.]*)+(:)+([0-9]*)"; // 127.0.0.1:44999
    
    //NSUInteger line = 0UL;
    
    // try to strip out the U | T
    NSArray *matches = [packet_header componentsMatchedByRegex:direction_regexp];
    for(NSString *match in matches)
    {
        /*
         Need to update method, direction is from (ip) -> to (ip)
        */
        
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        if([match isEqualToString:@"U"] == YES)
        {
            s_packet_direction = @"outbound";
            NSLog(@"Packet Direction: %@",s_packet_direction);
        }
        else if([match isEqualToString:@"T"] == YES)
        {
            s_packet_direction = @"inbound";
            NSLog(@"Packet Direction: %@",s_packet_direction);
        }
        packet_header = [packet_header substringFromIndex:[match length]];
        [packet_header stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        //NSLog(@"m_sip_packet: %@", packet_header);
    }
    
    // Strip out Date
    matches = [packet_header componentsMatchedByRegex:date_regexp];
    for(NSString *match in matches)
    {
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        if([match length] >= 1)
        {
            s_packet_date = match;
            NSLog(@"Date: %@",s_packet_date);
        }
        packet_header = [packet_header substringFromIndex:[match length]+1];
        //NSLog(@"m_sip_packet: %@", packet_header);
    }
    
    // Strip out Timestamp and Milliseconds
    matches = [packet_header componentsMatchedByRegex:time_regexp];
    for(NSString *match in matches)
    {
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        s_packet_timestamp = match;
        NSLog(@"TimeStamp: %@",s_packet_timestamp);
        packet_header = [packet_header substringFromIndex:[match length]+1];
        //NSLog(@"m_sip_packet: %@", packet_header);
    }
    
    // Grab IP Address and Ports (caller, callee)
    matches = [packet_header componentsMatchedByRegex:ip_port_regexp];
    
    for(NSString *match in matches)
    {
        //NSLog(@"%lu: %lu '%@'",(u_long)++line, (u_long)[match length], match);
        // have ipaddress and port, split string on ':'
        if([s_packet_direction isEqualToString:@"outbound"]==YES)
        {
            if([s_caller_ipaddress length] < 1)
            {
                s_caller_ipaddress = match;
                NSLog(@"caller ipaddress: %@",s_caller_ipaddress);
            }
            else
            {
                s_callee_ipaddress = match;
                NSLog(@"callee ipaddress: %@",s_callee_ipaddress);
            }
        }
        else if([s_packet_direction isEqualToString:@"inbound"]==YES)
        {
            if([s_callee_ipaddress length] < 1)
            {
                s_callee_ipaddress = match;
                NSLog(@"callee ipaddress: %@",s_callee_ipaddress);
            }
            else
            {
                s_caller_ipaddress = match;
                NSLog(@"caller ipaddress: %@",s_caller_ipaddress);
            }
        }
    }
    NSLog(@"===================================\r\n\r\n");
}

-(void) parseSipHeader:(NSString *) header
{
    NSMutableArray *l_sip_header = [[NSMutableArray alloc] init];
    NSMutableString *c_header = [NSMutableString stringWithString:header];
    
    NSString *boundry = @"..";
    NSRange substr = [c_header rangeOfString:boundry];
    
    while (substr.location != NSNotFound)
    {
        /*
         s_header = [sip_packet substringToIndex:substr.location];
         s_body = [sip_packet substringFromIndex:(substr.location + substr.length)];
         [m_sip_packet replaceCharactersInRange:substr withString:@""];
         substr = [m_sip_packet rangeOfString:search];
         */
        [l_sip_header addObject:[c_header substringToIndex:substr.location]];
        //NSLog(@"%@",NSStringFromRange(substr));
        [c_header replaceCharactersInRange:NSMakeRange(0, (substr.location + substr.length)) withString:@""];
        substr = [c_header rangeOfString:boundry];
    }
    
    NSLog(@"SIP HEADER");
    NSLog(@"%@",l_sip_header);
    /*for(NSString *chunk in l_sip_header)
     {
     NSLog(@"%@",chunk);
     }*/
}

-(void) parseSipBody:(NSString *) body
{
    NSMutableArray *l_sip_body = [[NSMutableArray alloc] init];
    NSMutableString *c_body = [NSMutableString stringWithString:body];
    
    NSString *boundry = @"..";
    
    if([body length] > 10)
    {
        NSRange substr = [c_body rangeOfString:boundry];
    
        while (substr.location != NSNotFound)
        {
            
            [l_sip_body addObject:[c_body substringToIndex:substr.location]];
            //NSLog(@"%@",NSStringFromRange(substr));
            [c_body replaceCharactersInRange:NSMakeRange(0, (substr.location + substr.length)) withString:@""];
            substr = [c_body rangeOfString:boundry];
        }
    
        NSLog(@"SIP BODY");
        NSLog(@"%@",l_sip_body);
        /*for(NSString *chunk in l_sip_header)
         {
         NSLog(@"%@",chunk);
         }
        */
    }
    
}

@end
