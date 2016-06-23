//
//  GACSocketModel.h
//  GCDAsyncSocketManagerDemo
//
//  Created by 宫城 on 16/6/23.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface GACSocketModel : JSONModel

/**
 *  socket协议版本号
 */
@property (nonatomic, assign) NSInteger version;

/**
 *  socket请求类型
 */
@property (nonatomic, assign) NSInteger reqType;

/**
 *  根据时间戳生成的socket唯一请求ID
 */
@property (nonatomic, strong) NSString<Optional> *reqId;

/**
 *  socket通道，支持单通道，多通道
 */
@property (nonatomic, strong) NSString<Optional> *requestChannel;

/**
 *  socket请求体
 */
@property (nonatomic, strong) NSDictionary<Optional> *body;

/**
 *  发送心跳时携带的接收到最新消息的ID
 */
@property (nonatomic, assign) NSInteger user_mid;

/**
 *  使用该方法对body对象进行两次转JSONString处理，如无body，请使用toJSONString方法直接转JSONString
 */
- (NSString *)socketModelToJSONString;

@end
