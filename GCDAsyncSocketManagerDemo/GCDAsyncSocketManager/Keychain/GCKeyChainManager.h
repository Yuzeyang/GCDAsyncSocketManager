//
//  GCKeyChainManager.h
//  GCDAsyncSocketManagerDemo
//
//  Created by 宫城 on 16/6/23.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCKeyChainManager : NSObject

@property (nonatomic, strong) NSString *token;

+ (GCKeyChainManager *)sharedInstance;

@end
