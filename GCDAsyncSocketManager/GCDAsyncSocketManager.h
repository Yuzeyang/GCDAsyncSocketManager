//
//  GCDAsyncSocketManager.h
//  GCDAsyncSocketManager
//
//  Created by 宫城 on 16/1/17.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol GCDAsyncSocketManagerDelegate <NSObject>

// set your request delegate here

@end

@interface GCDAsyncSocketManager : NSObject

@property (nonatomic, weak) id<GCDAsyncSocketManagerDelegate> delegate;

@property (nonatomic, assign) int status;   //connect status：1 connect，-1 not connect，0 connecting

/**
 *  sharedInstance
 */
+ (GCDAsyncSocketManager *)sharedInstance;

/**
 *  init socket
 */
- (void)initSocket;

/**
 *  disconnect socket
 */
- (void)disconnectSocket;

@end
