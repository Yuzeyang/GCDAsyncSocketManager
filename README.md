# GCDAsyncSocketManager

## Introduction
GCDAsyncSocketManager provides qiuick-to-use GCDAsyncSocket to build socket,it contains connect,disconnect,reconnect,beat,general request<br>
GCDAsyncSocketManager提供快速使用GCDAsyncSocket来搭建socket，它包含了建连、断开、重连、心跳、通用请求<br>

## members

[Zeeyang](https://github.com/Yuzeyang)、[broccolii](https://github.com/broccolii)

## How to use
socket connect:

you can connect when app enter forground or ViewController view will appear

```objective-c
[[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithToken:@"your token" channel:@"your communication channel"];
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

