//
//  GACConnectConfig.h
//  GCDAsyncSocketManagerDemo
//
//  Created by 宫城 on 2016/12/16.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GACConnectConfig : NSObject

/**
 *  socket配置
 */
@property (nonatomic, strong) NSString *token;
/**
 *  建连时的通道
 */
@property (nonatomic, strong) NSString *channels;
/**
 *  当前使用的通道
 */
@property (nonatomic, strong) NSString *currentChannel;
/**
 *  通信地址
 */
@property (nonatomic, strong) NSString *host;
/**
 *  通信端口号
 */
@property (nonatomic, assign) uint16_t port;
/**
 *  通信协议版本号
 */
@property (nonatomic, assign) NSInteger socketVersion;

@end
