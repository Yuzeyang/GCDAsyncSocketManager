//
//  GCDAsyncSocketManager.m
//  GCDAsyncSocketManager
//
//  Created by 宫城 on 16/1/17.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GCDAsyncSocketManager.h"
#import "GCDAsyncSocketConfig.h"
#import "GCDAsyncSocket.h"

#define kMaxReconnection_time 6    //最大重连次数

@interface GCDAsyncSocketManager ()

@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, assign) int reconnection_time;
@property (nonatomic, assign) int beat_time;    //Used for reconnection
@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSTimer *beatTimer;

@end

@implementation GCDAsyncSocketManager

+ (GCDAsyncSocketManager *)sharedInstance {
    static GCDAsyncSocketManager *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.status = -1;
        self.queue = [[NSOperationQueue alloc] init];
        [self.queue setMaxConcurrentOperationCount:1];
        [self.timer invalidate];
        self.timer = nil;
        [self.beatTimer invalidate];
        self.beatTimer = nil;
    }
    
    return self;
}

#pragma mark - socket actions
- (void)initSocket {
#ifdef DEBUG
    NSLog(@"reconnection_time %d",_reconnection_time);
#endif
    
    if (_status != -1) {
        NSLog(@"Socket Connect: YES");
        return;
    }
    
    _status = 0;
    
    self.socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    NSError *err;
    if (![self.socket connectToHost:HOST onPort:PORT withTimeout:TIMEOUT error:&err]) {
        self.status = -1;
        
        NSLog(@"%@",err);
    } else {
        NSString *requestStr = [NSString stringWithFormat:@"{\"version\":%d,\"reqType\":%d,\"body\":\"{}\"}\r\n",PROTOCOL_VERSION,REQTYPE_CONNECTION_AUTH_APPRAISAL];
        [self socketRequest:requestStr];
    }
}

- (void)disconnectSocket {
    _reconnection_time = -1;
    [_socket disconnect];
    
    [_beatTimer invalidate];
    _beatTimer = nil;
}

- (void)reconnection {
    [self initSocket];
}

- (void)sendBeat {
    if (_beat_time >= beatLimit) {
        [_beatTimer invalidate];
        _beatTimer = nil;
        [self reconnection];
    }else {
        _beat_time++;
    }
    
    NSString *BeatStr = [NSString stringWithFormat:@"{\"version\":%d,\"reqType\":%d}\r\n",PROTOCOL_VERSION,REQTYPE_BEAT];
    [self socketRequest:BeatStr];
}

- (void)socketRequest:(NSString *)requestStr {
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket writeData:requestData withTimeout:-1 tag:0];
    [self readData];
}

- (void)readData {
    [self.socket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:50000 tag:0];
}

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port {
    _status = 1;
    _reconnection_time = 0;
    [_timer invalidate];
    _timer = nil;
    
    if (!_beatTimer) {
        _beatTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendBeat) userInfo:nil repeats:YES];
        //        NSLog(@"start");
    }
    
    NSLog(@"Cool, I'm connected! That was easy.");
    NSLog(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    _status = -1;
    
    if (_reconnection_time >= 0 && _reconnection_time <= kMaxReconnection_time) {
        [_timer invalidate];
        _timer = nil;
        
        int time = pow(2, _reconnection_time);
        _timer = [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(reconnection) userInfo:nil repeats:NO];
        
        _reconnection_time++;
        NSLog(@"socket did reconnection,after %ds try again",time);
    }else{
        _reconnection_time = 0;
        NSLog(@"socketDidDisconnect:%p withError: %@", sock, err);
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    //    NSLog(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    //    NSLog(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    NSString *jsonStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    jsonStr = [jsonStr stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
    NSString *part = jsonStr;
    NSData *newData = [part dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:newData options:kNilOptions error:&error];
    
    if (!error) {
        int reqType = [json[@"reqType"] intValue];
        
        switch (reqType) {
            case REQTYPE_CONNECTION_AUTH_APPRAISAL:
            {
                // do something
            }
                break;
            case REQTYPE_BEAT:
            {
                // do something
            }
                break;
                
            default:
                break;
        }
    }
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:10 maxLength:50000 tag:0];
}

@end
