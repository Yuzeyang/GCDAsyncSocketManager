//
//  GACErrorManager.m
//  GCDAsyncSocketManagerDemo
//
//  Created by Broccoli on 16/6/23.
//  Copyright © 2016年 宫城. All rights reserved.
//

#import "GACErrorManager.h"

@implementation GACErrorManager

+ (NSError *)errorWithErrorCode:(NSInteger)errorCode {
    NSString *errorMessage;
    
    switch (errorCode) {
        case 1:
            errorMessage = GAC_REQUEST_ERROR;
            errorCode = 1001;
            break;
        case 2:
            errorMessage = GAC_REQUEST_PARAM_ERROR;
            errorCode = 1002;
            break;
        case 3:
            errorMessage = GAC_REQUEST_TIMEOUT;
            errorCode = 1003;
            break;
        case 4:
            errorMessage = GAC_SERVER_MAINTENANCE_UPDATES;
            errorCode = 1004;
            break;
        case 1005:
            errorMessage = GAC_AUTHAPPRAISAL_FAILED;
            break;
        case 2001:
            errorMessage = GAC_NETWORK_DISCONNECTED;
            break;
        case 2002:
            errorMessage = GAC_LOCAL_REQUEST_TIMEOUT;
            break;
        case 2004:
            errorMessage = GAC_JSON_PARSE_ERROR;
            break;
        case 2003:
            errorMessage = GAC_LOCAL_PARAM_ERROR;
            break;
        default:
            break;
    }
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:errorCode
                           userInfo:@{ NSLocalizedDescriptionKey: errorMessage }];
}

@end
