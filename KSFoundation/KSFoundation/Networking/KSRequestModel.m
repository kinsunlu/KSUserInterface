//
//  KSRequestModel.m
//  KSFoundation
//
//  Created by Kinsun on 2020/4/28.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSRequestModel.h"

static NSString * const k_JOINT_STRING = @"***";

@implementation KSRequestModel

- (instancetype)initWithKey:(KSRequestModelKey)key host:(NSString *)host {
    if (self = [super init]) {
        _host = host;
        _key = key;
        if (key != nil && key.length > 0) {
            if ([key containsString:k_JOINT_STRING]) {
                NSArray <NSString *> *jointArray = [key componentsSeparatedByString:k_JOINT_STRING];
                NSString *jointURL = jointArray.firstObject;
                NSString *method = jointArray.lastObject;
                BOOL canContinue = jointURL != nil && method != nil && jointURL != method && jointURL.length > 0 && method.length > 0 ;
                if (canContinue) {
                    _method = method.integerValue;
                    _url = [_host stringByAppendingString:jointURL];
                }
            } else {
                _method = KSURLRequestMethodPOST;
                _url = [_host stringByAppendingString:key];
            }
            _toURL = [NSURL URLWithString:_url];
        }
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url method:(KSURLRequestMethod)method {
    if (self = [super init]) {
        _url = url;
        _toURL = [NSURL URLWithString:_url];
        _method = method;
        NSURL *k_url = [NSURL URLWithString:url];
        _host = [NSString stringWithFormat:@"%@://%@/", k_url.scheme, k_url.host];
        _key = [url substringFromIndex:_host.length];
    }
    return self;
}

- (void)setTask:(NSURLSessionTask *)task {
    if (_task != nil) [_task cancel];
    _task = task;
}

- (void)dealloc {
    if (_task != nil) [_task cancel];
//    NSLog(@"---------- Request:%@ dealloc", self);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@, URL=%@>", super.description, _url];
}

+ (KSURLRequestContentType)contentType {
    return KSURLRequestContentTypeJSON;
}

@end

@implementation KSNetworking (KSRequestModel)

- (NSURLSessionDataTask *)requestWithModel:(KSRequestModel *)model callback:(KSNetworkingCallback)callback {
    return [self requestWithURLString:model.url method:model.method params:nil callback:callback];
}

- (NSURLSessionDataTask *)requestWithModel:(KSRequestModel *)model params:(NSDictionary <NSString *, id> *)params callback:(KSNetworkingCallback)callback {
    return [self requestWithRequest:[KSURLRequest.alloc initWithURL:model.toURL method:model.method contentType:[[model class] contentType] params:params] callback:callback];
}

@end
