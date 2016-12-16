//
//  FIMSocketManager.h
//  FIMMobSDK
//
//  Created by 宫城 on 15/9/11.
//  Copyright (c) 2015年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCDAsyncSocketManager : NSObject

/**
 *  连接状态：1已连接，-1未连接，0连接中
 */
@property (nonatomic, assign) NSInteger connectStatus;
@property (nonatomic, assign) NSInteger reconnectionCount;  // 建连失败重连次数

/**
 *  获取单例
 *
 *  @return 单例对象
 */
+ (nullable GCDAsyncSocketManager *)sharedInstance;

/**
 *  连接 socket
 *
 *  @param requestString 请求数据
 *  @param delegate      delegate
 */
- (void)connectSocketWithDelegate:(nonnull id)delegate;

/**
 *  socket 连接成功后发送心跳的操作
 */
- (void)socketDidConnectBeginSendBeat:(nonnull NSString *)beatBody;

/**
 *  socket 连接失败后重接的操作
 */
- (void)socketDidDisconectBeginSendReconnect:(nonnull NSString *)reconnectBody;

/**
 *  向服务器发送数据
 *
 *  @param body 数据
 */
- (void)socketWriteData:(nonnull NSString *)data;

/**
 *  socket 读取数据
 */
- (void)socketBeginReadData;

/**
 *  socket 主动断开连接
 */
- (void)disconnectSocket;

/**
 *  重设心跳次数
 */
- (void)resetBeatCount;

/**
 *  设置连接的host和port
 */
- (void)changeHost:(nullable NSString *)host port:(NSInteger)port;

@end
