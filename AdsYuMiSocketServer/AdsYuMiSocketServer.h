//
//  AdsYuMiSocketServer.h
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/26.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AdsYuMiSocketServer : NSObject

//链接到服务器
- (BOOL)connectToIP:(NSString *)IP port:(int)port;

//同步发送和接收数据
- (NSString *)sendAndRecv:(NSString *)msg;

//同步发送二进制数据和接收
-(NSString *)sendAndRecvData:(NSData *)msg;

//异步发送和接收数据
- (NSString *)asynSendAndRecv:(NSString *)msg;

//断开链接
- (void)disconnection;

@end
