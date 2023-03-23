//
//  KSRequestModel.h
//  KSFoundation
//
//  Created by Kinsun on 2020/4/28.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSNetworking.h"

//formart is '(path)***(1 or 2)'. 1 = GET, 2 = POST, 3 = DELETE, 4 = PUT. 直接写Path为POST
typedef NSString * KSRequestModelKey NS_SWIFT_NAME(KSRequestModel.Key);

NS_ASSUME_NONNULL_BEGIN

@interface KSRequestModel : NSObject

@property (nonatomic, assign, readonly) KSURLRequestMethod method;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSURL *toURL;
@property (nonatomic, weak) NSURLSessionTask *task;

@property (nonatomic, strong, readonly) NSString *host;
@property (nonatomic, copy, readonly) KSRequestModelKey key;

- (instancetype)initWithKey:(KSRequestModelKey)key host:(NSString *)host;
- (instancetype)initWithURL:(NSString *)url method:(KSURLRequestMethod)method;

/// 在子类重写来替换生成请求中的contentType，默认=KSURLRequestContentTypeJSON
@property (nonatomic, class, readonly) KSURLRequestContentType contentType;

@end

@interface KSNetworking <__covariant DataType> (KSRequestModel)

- (NSURLSessionDataTask *)requestWithModel:(KSRequestModel *)model callback:(KSNetworkingCallback _Nullable)callback;

- (NSURLSessionDataTask *)requestWithModel:(KSRequestModel *)model params:(NSDictionary <NSString *, id> *_Nullable)params callback:(KSNetworkingCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
