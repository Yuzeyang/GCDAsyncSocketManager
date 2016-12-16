# GCDAsyncSocketManager

## Introduction
GCDAsyncSocketManager provides qiuick-to-use GCDAsyncSocket to build socket,it contains connect,disconnect,reconnect,beat,general request<br>
GCDAsyncSocketManager提供快速使用GCDAsyncSocket来搭建socket，它包含了建连、断开、重连、心跳、通用请求<br>

## members

[Zeeyang](https://github.com/Yuzeyang)、[broccolii](https://github.com/broccolii)

## How to use
socket connect:

1. you can connect to the default environment when app enter forground or ViewController view will appear 

```objective-c
[[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithToken:@"your token" channel:@"your communication channel"];
```
2. you can connect to the custom environment

```objective-c
- (GACConnectConfig *)connectConfig {
    if (!_connectConfig) {
        _connectConfig = [[GACConnectConfig alloc] init];
        _connectConfig.channels = kDefaultChannel;
        _connectConfig.currentChannel = kDefaultChannel;
        _connectConfig.host = @"online socket address";
        _connectConfig.port = 7070;
        _connectConfig.socketVersion = 5;
    }
    _connectConfig.token = @"f14c4e6f6c89335ca5909031d1a6efa9";
    
    return _connectConfig;
}

 [[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
```

socket disconnect:

you can disconnect when app enter background

```objective-c
[[GCDAsyncSocketCommunicationManager sharedInstance] disconnectSocket];
```
we provide a general interface to send request

`type` is the request type 

`body` is the request body

`callback` is the request handle complete callback to app

```objective-c
- (void)socketWriteDataWithRequestType:(GACRequestType)type
                           requestBody:(nonnull NSDictionary *)body
                            completion:(nullable SocketDidReadBlock)callback;
```

for example:

```objective-c
[[GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:GACRequestType_GetConversationsList requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data) {
        // do something
        if (error) {
            
        } else {
            
        }
    }];
```

## Related articles

[iOS 基于GCDAsyncSocket快速开发Socket通信](http://zeeyang.com/2016/01/17/GCDAsyncSocket-socket/)

[iOS Socket重构设计](http://zeeyang.com/2016/06/22/GCDAsyncSocket-socket-optimize/)