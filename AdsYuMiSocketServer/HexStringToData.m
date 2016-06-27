//
//  HexStringToData.m
//  socketDemo
//
//  Created by 甲丁乙_ on 16/2/19.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import "HexStringToData.h"

@implementation HexStringToData


//编写一个NSData类型数据
+ (NSMutableData *)HexStringToData:(NSString *)str{
    
    NSString *command = str;
    command = [command stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSMutableData *commandToSend= [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [command length]/2; i++) {
        byte_chars[0] = [command characterAtIndex:i*2];
        byte_chars[1] = [command characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [commandToSend appendBytes:&whole_byte length:1];
    }
    return commandToSend;
}


@end
