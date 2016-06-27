//
//  AdsYuMiSocketServer.m
//  AdsYUMISample
//
//  Created by 甲丁乙_ on 16/1/26.
//  Copyright © 2016年 AdsYuMI. All rights reserved.
//

#import "AdsYuMiSocketServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>


@interface AdsYuMiSocketServer()
// 全局的socket
@property (nonatomic, assign) int clientSocket;

// 接收返回数据
@property (nonatomic, copy) NSString *recvStr;

//block 回调
@property (nonatomic, copy) void (^finishedBlock)(NSString *str);

@end

@implementation AdsYuMiSocketServer

-(BOOL)connectToIP:(NSString *)IP port:(int)port{

  //socket，如果 > 0 就表示成功
  self.clientSocket = socket(AF_INET, SOCK_STREAM, 0);
  if (self.clientSocket < 0) {
    NSLog(@"socket创建失败,%d",self.clientSocket);
    return NO;
  }
  
  //0 成功/其他 错误代号，非0即真
  struct sockaddr_in serverAddress;
  serverAddress.sin_family = AF_INET;
  serverAddress.sin_addr.s_addr = inet_addr(IP.UTF8String);
  serverAddress.sin_port = htons(port);
  
  int connection = connect(self.clientSocket, (const struct sockaddr *)&serverAddress, sizeof(serverAddress));
  if (connection == 0) {
    NSLog(@"建立连接,%d",connection);
    return YES;
  }
    NSLog(@"连接失败,%d",connection);
  return NO;
}

-(NSString *)sendAndRecv:(NSString *)msg {
  
  //如果成功，则返回发送的字节数，失败则返回SOCKET_ERROR
  ssize_t sendLen = send(self.clientSocket, msg.UTF8String, strlen(msg.UTF8String), 0);
  NSLog(@"发送了 %ld 字节", sendLen);
  
  uint8_t buffer[1024];
  NSMutableData *dataM = [NSMutableData data];
  ssize_t recvLen = -1;
  
  while (recvLen != 0) {
    // 循环接收数据
    recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
    NSLog(@"接收 %ld 字节", recvLen);
    
    // 将数据拼接到 dataM 中
    if (recvLen > 0) {
      [dataM appendBytes:buffer length:recvLen];
    }
  }
  
  // 转换成字符串
  NSString *str = [[NSString alloc] initWithData:dataM encoding:NSUTF8StringEncoding];
  NSLog(@"%@", str);

  return str;
}

-(NSString *)sendAndRecvData:(NSData *)msg{
    
    //如果成功，则返回发送的字节数，失败则返回SOCKET_ERROR
    
    ssize_t sendLen = send(self.clientSocket,(__bridge const void *)(msg),[msg length], 0);
    NSLog(@"发送了 %ld 字节", sendLen);
    
    uint8_t buffer[1024];
    NSMutableData *dataM = [NSMutableData data];
    ssize_t recvLen = -1;
    
    while (recvLen != 0) {
        // 循环接收数据
        recvLen = recv(self.clientSocket, buffer, sizeof(buffer), 0);
        NSLog(@"接收 %ld 字节", recvLen);
        
        // 将数据拼接到 dataM 中
        if (recvLen > 0) {
            [dataM appendBytes:buffer length:recvLen];
        }
    }
    
    // 转换成字符串
    NSString *str = [[NSString alloc] initWithData:dataM encoding:NSUTF8StringEncoding];
    NSLog(@"%@", str);
    
    return str;
}

- (NSString *)asynSendAndRecv:(NSString *)msg {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        self.recvStr = [self sendAndRecv:msg];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%@",self.recvStr);
        });
    });
    
   
    
  
  
  if (self.recvStr != nil) {
    return self.recvStr;
  }

  return nil;
}

// 断开连接
- (void)disconnection {

  close(self.clientSocket);
  
}

@end
