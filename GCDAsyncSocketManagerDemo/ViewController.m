//
//  ViewController.m
//  GCDAsyncSocketManagerDemo
//
//  Created by 宫城 on 16/6/23.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocketCommunicationManager.h"
#import "GACConnectConfig.h"

#define kDefaultChannel @"dkf"

@interface ViewController ()

@property (nonatomic, strong) GACConnectConfig *connectConfig;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 1. 使用默认的连接环境
    [[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithToken:@"f14c4e6f6c89335ca5909031d1a6efa9" channel:kDefaultChannel];
    
    // 2.自定义配置连接环境
    [[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithConfig:self.connectConfig];
}

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getConversationsList:(id)sender {
    // your request params
    NSDictionary *requestBody = @{};
    [[GCDAsyncSocketCommunicationManager sharedInstance] socketWriteDataWithRequestType:GACRequestType_GetConversationsList requestBody:requestBody completion:^(NSError * _Nullable error, id  _Nullable data) {
        // do something
        if (error) {
            
        } else {
            
        }
    }];
}

@end
