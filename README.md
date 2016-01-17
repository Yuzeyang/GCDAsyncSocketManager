# GCDAsyncSocketManager

## Introduction
GCDAsyncSocketManager provides qiuick-to-use GCDAsyncSocket to build socket,it contains connect,disconnect,reconnect,beat,custom request
GCDAsyncSocketManager提供快速使用GCDAsyncSocket来搭建socket，它包含了建连、断开、重连、心跳、自定义请求

## How to use
connect

```object-c
[[GCDAsyncSocketManager sharedInstance] initSocket];
```
disconnect
```object-c
[[GCDAsyncSocketManager sharedInstance] disconnectSocket];
```