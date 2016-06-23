//
//  ViewController.m
//  GCDAsyncSocketManagerDemo
//
//  Created by 宫城 on 16/6/23.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "ViewController.h"
#import "GCDAsyncSocketCommunicationManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[GCDAsyncSocketCommunicationManager sharedInstance] createSocketWithToken:@"your token" channel:@"your communication channel"];
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
