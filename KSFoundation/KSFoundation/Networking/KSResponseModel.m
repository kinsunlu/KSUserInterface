//
//  KSResponseModel.m
//  KSFoundation
//
//  Created by Kinsun on 2020/4/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSResponseModel.h"

@implementation KSResponseModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _message = [dictionary objectForKey:@"message"];
        if (_message == nil) {
            _message = [dictionary objectForKey:@"msg"];
        }
        NSNumber *codeObj = [dictionary objectForKey:@"code"];
        if (codeObj == nil) {
            codeObj = [dictionary objectForKey:@"result"];
        }
        _code = codeObj != nil ? codeObj.integerValue : -1;
        _data = [dictionary objectForKey:@"data"];
    }
    return self;
}

@end

@implementation KSNetworking (KSResponseModel)

- (NSURLSessionDataTask *)requestForResponseModelWithRequest:(KSURLRequest *)request callback:(KSNetworkingModelCallback)callback {
    return [self requestWithRequest:request callback:^(NSDictionary *data, NSError *error) {
        if (callback != nil) {
            KSResponseModel *response = nil;
            if (data != nil) {
                response = [KSResponseModel.alloc initWithDictionary:data];
            }
            callback(response, error);
        }
    }];
}

- (NSURLSessionDataTask *)requestForResponseModelWithModel:(KSRequestModel *)model params:(NSDictionary <NSString *, id> *)params callback:(KSNetworkingModelCallback)callback {
    KSURLRequest *request = [KSURLRequest.alloc initWithURL:model.toURL method:model.method contentType:[[model class] contentType] params:params];
    return [self requestForResponseModelWithRequest:request callback:callback];
}

- (NSURLSessionDataTask *)requestForResponseModelWithModel:(KSRequestModel *)model callback:(KSNetworkingModelCallback)callback {
    return [self requestForResponseModelWithModel:model params:nil callback:callback];
}

@end
