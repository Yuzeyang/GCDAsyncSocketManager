
//
//  FIMCommunicationManager.m
//  FlashIMiOSDemo
//
//  Created by Broccoli on 16/4/11.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCDAsyncSocketCommunicationManager.h"
#import "GCDAsyncSocket.h"
#import "GCKeyChainManager.h"
#import "GCDAsyncSocketManager.h"
#import "GACSocketModel.h"
#import <UIKit/UIKit.h>
#import "AFNetworkReachabilityManager.h"
#import "GACErrorManager.h"

/**
 *  默认通信协议版本号
 */
static NSUInteger PROTOCOL_VERSION = 7;

@interface GCDAsyncSocketCommunicationManager () <GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSString *socketAuthAppraisalChannel;  // socket验证通道，支持多通道
@property (nonatomic, strong) NSMutableDictionary *requestsMap;
@property (nonatomic, strong) GCDAsyncSocketManager *socketManager;
@property (nonatomic, assign) NSTimeInterval interval;  //服务器与本地时间的差值
@property (nonatomic, strong, nonnull) GACConnectConfig *connectConfig;

@end

@implementation GCDAsyncSocketCommunicationManager

@dynamic connectStatus;

#pragma mark - init

+ (GCDAsyncSocketCommunicationManager *)sharedInstance {
    static GCDAsyncSocketCommunicationManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }

    self.socketManager = [GCDAsyncSocketManager sharedInstance];
    self.requestsMap = [NSMutableDictionary dictionary];
    [self startMonitoringNetwork];
    return self;
}

#pragma mark - socket actions

- (void)createSocketWithConfig:(nonnull GACConnectConfig *)config {
    if (!config.token.length || !config.channels.length || !config.host.length) {
        return;
    }
    
    self.connectConfig = config;
    self.socketAuthAppraisalChannel = config.channels;
    [GCKeyChainManager sharedInstance].token = config.token;
    [self.socketManager changeHost:config.host port:config.port];
    PROTOCOL_VERSION = config.socketVersion;
    
    [self.socketManager connectSocketWithDelegate:self];
}

- (void)createSocketWithToken:(nonnull NSString *)token channel:(nonnull NSString *)channel {
    if (!token || !channel) {
        return;
    }

    self.socketAuthAppraisalChannel = channel;
    [GCKeyChainManager sharedInstance].token = token;
    [self.socketManager changeHost:@"online socket address" port:7070];

    [self.socketManager connectSocketWithDelegate:self];
}

- (void)disconnectSocket {
    [self.socketManager disconnectSocket];
}

- (void)socketWriteDataWithRequestType:(GACRequestType)type
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nullable SocketDidReadBlock)callback {
    if (self.socketManager.connectStatus == -1) {
        NSLog(@"socket 未连通");
        if (callback) {
            callback([GACErrorManager errorWithErrorCode:2003],
                     nil);
        }
        return;
    }
    
    NSString *blockRequestID = [self createRequestID];
    if (callback) {
        [self.requestsMap setObject:callback forKey:blockRequestID];
    }
    
    GACSocketModel *socketModel = [[GACSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = type;
    socketModel.reqId = blockRequestID;
    socketModel.requestChannel = self.currentCommunicationChannel;
    socketModel.body = body;
    
    NSString *requestBody = [socketModel socketModelToJSONString];
    [self.socketManager socketWriteData:requestBody];
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    GACSocketModel *socketModel = [[GACSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = GACRequestType_ConnectionAuthAppraisal;
    socketModel.reqId = [self createRequestID];
    socketModel.requestChannel = self.socketAuthAppraisalChannel;
    
    socketModel.body =
    @{ @"token": [GCKeyChainManager sharedInstance].token ?: @"",
       @"endpoint": @"ios" };
    
    [self.socketManager socketWriteData:[socketModel socketModelToJSONString]];
    
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", socket, host, port);
    NSLog(@"Cool, I'm connected! That was easy.");
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)err {
    GACSocketModel *socketModel = [[GACSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = GACRequestType_ConnectionAuthAppraisal;
    socketModel.reqId = [self createRequestID];
    socketModel.requestChannel = self.socketAuthAppraisalChannel;
    socketModel.body = @{
                         @"token":
                             [GCKeyChainManager sharedInstance].token == nil ? @"" : [GCKeyChainManager sharedInstance].token,
                         @"endpoint": @"ios"
                         };
    
    NSString *requestBody = [socketModel socketModelToJSONString];
    
    [self.socketManager socketDidDisconectBeginSendReconnect:requestBody];
    NSLog(@"socketDidDisconnect:%p withError: %@", socket, err);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonString = [jsonString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *jsonError;
    NSDictionary *json =
    [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&jsonError];
    NSLog(@"socket - receive data %@", json);
    
    if (jsonError) {
        [self.socketManager socketBeginReadData];
        NSLog(@"json 解析错误: --- error %@", jsonError);
        return;
    }
    
    NSInteger requestType = [json[@"reqType"] integerValue];
    NSInteger errorCode = [json[@"status"] integerValue];
    NSDictionary *body = @{};
    NSString *requestID = json[@"reqId"];
    NSString *requestChannel = nil;
    if ([[json allKeys] containsObject:@"requestChannel"]) {
        requestChannel = json[@"requestChannel"];
    }
    
    SocketDidReadBlock didReadBlock = self.requestsMap[requestID];
    
    if (errorCode != 0) {
        NSError *error = [GACErrorManager errorWithErrorCode:errorCode];
        if (requestType == GACRequestType_ConnectionAuthAppraisal &&
            [self.socketDelegate respondsToSelector:@selector(connectionAuthAppraisalFailedWithErorr:)]) {
            [self.socketDelegate connectionAuthAppraisalFailedWithErorr:[GACErrorManager errorWithErrorCode:1005]];
        }
        if (didReadBlock) {
            didReadBlock(error, body);
        }
        return;
    }
    
    switch (requestType) {
        case GACRequestType_ConnectionAuthAppraisal: {
            [self didConnectionAuthAppraisal];
            
            NSDictionary *systemTimeDic = [body mutableCopy];
            [self differenceOfLocalTimeAndServerTime:[systemTimeDic[@"system_time"] longLongValue]];
        } break;
        case GACRequestType_Beat: {
            [self.socketManager resetBeatCount];
        } break;
        case GACRequestType_GetConversationsList: {
            if (didReadBlock) {
                didReadBlock(nil, body);
            }
        } break;
        default: {
            if ([self.socketDelegate respondsToSelector:@selector(socketReadedData:forType:)]) {
                [self.socketDelegate socketReadedData:body forType:requestType];
            }
        } break;
    }

    [self.socketManager socketBeginReadData];
}

#pragma mark-- private method
- (NSString *)createRequestID {
    NSInteger timeInterval = [NSDate date].timeIntervalSince1970 * 1000000;
    NSString *randomRequestID = [NSString stringWithFormat:@"%ld%d", timeInterval, arc4random() % 100000];
    return randomRequestID;
}

- (void)differenceOfLocalTimeAndServerTime:(long long)serverTime {
    if (serverTime == 0) {
        self.interval = 0;
        return;
    }
    
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    self.interval = serverTime - localTimeInterval;
}

- (long long)simulateServerCreateTime {
    NSTimeInterval localTimeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    localTimeInterval += 3600 * 8;
    localTimeInterval += self.interval;
    return localTimeInterval;
}

- (void)didConnectionAuthAppraisal {
    if ([self.socketDelegate respondsToSelector:@selector(socketDidConnect)]) {
        [self.socketDelegate socketDidConnect];
    }
    
    GACSocketModel *socketModel = [[GACSocketModel alloc] init];
    socketModel.version = PROTOCOL_VERSION;
    socketModel.reqType = GACRequestType_Beat;
    socketModel.user_mid = 0;
    
    NSString *beatBody = [NSString stringWithFormat:@"%@\r\n", [socketModel toJSONString]];
    [self.socketManager socketDidConnectBeginSendBeat:beatBody];
}

- (void)startMonitoringNetwork {
    AFNetworkReachabilityManager *networkManager = [AFNetworkReachabilityManager sharedManager];
    [networkManager startMonitoring];
    __weak __typeof(&*self) weakSelf = self;
    [networkManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                if (weakSelf.socketManager.connectStatus != -1) {
                    [self disconnectSocket];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (weakSelf.socketManager.connectStatus == -1) {
                    [self createSocketWithToken:[GCKeyChainManager sharedInstance].token
                                        channel:self.socketAuthAppraisalChannel];
                }
                break;
            default:
                break;
        }
    }];
}

#pragma mark - getter
- (GACSocketConnectStatus)connectStatus {
    return self.socketManager.connectStatus;
}

@end
