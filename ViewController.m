//
//  ViewController.m
//  socketDemo
//
//  Created by 甲丁乙_ on 16/1/27.
//  Copyright © 2016年 wzy. All rights reserved.
//

#import "ViewController.h"
#import "AdsYuMiSocketServer.h"
#import <CommonCrypto/CommonDigest.h>
#import "AdsYuMiNSData+CRC32.h"
#import "HexStringFromString.h"
#import "HexStringToData.h"

@interface ViewController ()
@property (nonatomic,copy) NSData *jsonData;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
      /**
       *  socket 测试
       */
      AdsYuMiSocketServer *SocketServer = [[AdsYuMiSocketServer alloc]init];
      if (![SocketServer connectToIP:@"182.92.84.81" port:8888]) {
        NSLog(@"error");
        return;
      }
    
      NSLog(@"OK");
    
    NSString *params = @"uuid=&cornID=06600cfc941f4b419eccd199a4cc5465&versionID=&channelID=&deviceType=1&os=ios&MAC=A4:5E:60:D6:34:A9&deviceKey=F49A8A97-385F-4220-A215-2DBD579354BE&netType=WIFI&deviceNo=iphone 4S&language=en-US&longitude=&latitude=&adType=2&supportSDK=ChanceAd&planTime=1453880672074.324219&wifiList=&stationInfo=&optimization=0&action=request click&result=1&interfaceType=API&PLMN=&sdkver=104&rid=494dd2cba9d4515ea9dc066608d37d06&pid=42e92090d890b2fc29a9646d8c436200";
    //添加 sigkey
    NSString *str = [NSString stringWithFormat:@"jDVbiQGUGr5tShbL22%@",params];
    NSString *sign = [self adViewMd5:str];
    
    //body
    NSDictionary *dic = [self getDictionary];
    [dic setValue:sign forKey:@"sign"];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *body = [NSString stringWithFormat:@"%@",jsonString];
    //将 body 转为16进制
    NSString *body16 = [HexStringFromString hexStringFromString:body];


    //body 的长度,转为16进制
    NSUInteger len = body.length;
    NSString *length = [NSString stringWithFormat:@"%010lx",(unsigned long)len];
    
    //body 的 CRC32,转为16进制
    NSData* Data = [body dataUsingEncoding:NSUTF8StringEncoding];
    int32_t CRC32 = [Data AdsYuMiCRC32];
    NSString *crc32 = [[NSString alloc]initWithFormat:@"%x",CRC32];
    
    //最终的请求
    
    NSString *request = [NSString stringWithFormat:@"f8e7c3a500010100000000%@%@%@",length,body16,crc32];
    
    NSMutableData *data16 = [HexStringToData HexStringToData:request];
    
//    //转为二进制数据
//    NSData *data =[request dataUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"%@", data);
//    NSString *str333 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];

    
    // 向服务器发送请求数据
//    NSString *result = [SocketServer asynSendAndRecv:request];
    //发送二进制数据
    NSString *result = [SocketServer sendAndRecvData:data16];
    if (result != nil) {
        NSLog(@"result=%@", result);
      }
      

}
- (NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    
//    LEDEBUG(@"hexdata: %@", hexData);
    return hexData;
}
//参数字典
-(NSDictionary *)getDictionary{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:@"" forKey:@"uuid"];
    [dic setObject:@"06600cfc941f4b419eccd199a4cc5465" forKey:@"cornID"];
    [dic setObject:@"" forKey:@"versionID"];
    [dic setObject:@"" forKey:@"channelID"];
    [dic setObject:@"1" forKey:@"deviceType"];
    [dic setObject:@"ios" forKey:@"os"];
    [dic setObject:@"A4:5E:60:D6:34:A9" forKey:@"MAC"];
    [dic setObject:@"F49A8A97-385F-4220-A215-2DBD579354BE" forKey:@"deviceKey"];
    [dic setObject:@"WIFI" forKey:@"netType"];
    [dic setObject:@"iphone 4S" forKey:@"deviceNo"];
    [dic setObject:@"en-US" forKey:@"language"];
    [dic setObject:@"" forKey:@"longitude"];
    [dic setObject:@"" forKey:@"latitude"];
    [dic setObject:@"2" forKey:@"adType"];
    [dic setObject:@"ChanceAd" forKey:@"supportSDK"];
    [dic setObject:@"1453880672074.324219" forKey:@"planTime"];
    [dic setObject:@"" forKey:@"wifiList"];
    [dic setObject:@"" forKey:@"stationInfo"];
    [dic setObject:@"0" forKey:@"optimization"];
    [dic setObject:@"request click" forKey:@"action"];
    [dic setObject:@"1" forKey:@"result"];
    [dic setObject:@"API" forKey:@"interfaceType"];
    [dic setObject:@"" forKey:@"PLMN"];
    [dic setObject:@"104" forKey:@"sdkver"];
    [dic setObject:@"494dd2cba9d4515ea9dc066608d37d06" forKey:@"rid"];
    [dic setObject:@"42e92090d890b2fc29a9646d8c436200" forKey:@"pid"];
    return dic;
}
//md5
- (NSString*)adViewMd5:(NSString*) str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), result );
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

//将普通字符串转为16进制
+ (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
