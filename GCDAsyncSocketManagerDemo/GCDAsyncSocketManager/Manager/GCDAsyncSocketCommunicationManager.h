//
//  FIMCommunicationManager.h
//  FlashIMiOSDemo
//
//  Created by Broccoli on 16/4/11.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GACConnectConfig.h"

/**
 *  业务类型
 */
typedef NS_ENUM(NSInteger, GACRequestType) {
    GACRequestType_Beat = 1,                       //心跳
    GACRequestType_GetConversationsList,           //获取会话列表
    GACRequestType_ConnectionAuthAppraisal = 7,        //连接鉴权
};

/**
 *  socket 连接状态
 */
typedef NS_ENUM(NSInteger, GACSocketConnectStatus) {
    GACSocketConnectStatusDisconnected = -1,  // 未连接
    GACSocketConnectStatusConnecting = 0,     // 连接中
    GACSocketConnectStatusConnected = 1       // 已连接
};

typedef void (^SocketDidReadBlock)(NSError *__nullable error, id __nullable data);

@protocol GACSocketDelegate <NSObject>

@optional
/**
 *  监听到服务器发送过来的消息
 *
 *  @param data 数据
 *  @param type 类型 目前就三种情况（receive messge / kick out / default / ConnectionAuthAppraisal）
 */
- (void)socketReadedData:(nullable id)data forType:(NSInteger)type;

/**
 *  连上时
 */
- (void)socketDidConnect;

/**
 *  建连时检测到token失效
 */
- (void)connectionAuthAppraisalFailedWithErorr:(nonnull NSError *)error;

@end

@interface GCDAsyncSocketCommunicationManager : NSObject

// 连接状态
@property (nonatomic, assign, readonly) GACSocketConnectStatus connectStatus;

// 当前请求通道
@property (nonatomic, strong, nonnull) NSString *currentCommunicationChannel;

// socket 回调
@property (nonatomic, weak, nullable) id<GACSocketDelegate> socketDelegate;

/**
 *  获取单例
 *
 *  @return 单例对象
 */
+ (nullable GCDAsyncSocketCommunicationManager *)sharedInstance;

/**
 初始化 socket
 
 @param token         token
 @param channel       建连时通道
 @param host          主机地址
 @param port          端口号
 @param socketVersion socket通信协议版本号
 */
- (void)createSocketWithConfig:(nonnull GACConnectConfig *)config;

/**
 *  初始化 socket
 *
 *  @param token          token
 *  @param requestChannel 请求参数
 */
- (void)createSocketWithToken:(nonnull NSString *)token channel:(nonnull NSString *)channel;

/**
 *  socket断开连接
 */
- (void)disconnectSocket;

/**
 *  向服务器发送数据
 *
 *  @param type    请求类型
 *  @param body    请求体
 */
- (void)socketWriteDataWithRequestType:(GACRequestType)type
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nullable SocketDidReadBlock)callback;

@end
