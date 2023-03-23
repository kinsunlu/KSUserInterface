//
//  KSURLRequest.h
//  KSFoundation
//
//  Created by Kinsun on 2020/6/4.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSURLRequestMethod) {
    KSURLRequestMethodUnknown   = 0,
    KSURLRequestMethodGET       = 1,
    KSURLRequestMethodPOST      = 2,
    KSURLRequestMethodDELETE    = 3,
    KSURLRequestMethodPUT       = 4
} NS_SWIFT_NAME(KSURLRequest.Method);

typedef NS_ENUM(NSInteger, KSURLRequestContentType) {
    KSURLRequestContentTypeJSON             = 0, /// Content-Type =  application/json;
    KSURLRequestContentTypeFormUrlencoded   = 1, /// Content-Type = application/x-www-form-urlencoded
    KSURLRequestContentTypeTextPlain        = 2 /// Content-Type = text/plain
} NS_SWIFT_NAME(KSURLRequest.ContentType);

NS_ASSUME_NONNULL_BEGIN

@interface KSURLRequest : NSMutableURLRequest

@property (nonatomic, assign, readonly) KSURLRequestMethod method;
@property (nonatomic, assign, readonly) KSURLRequestContentType contentType;
@property (nonatomic, strong, readonly, nullable) NSDictionary <NSString *, id> *params;
@property (nonatomic, strong, readonly, nullable) NSDictionary <NSString *, id> *query;

/// 填充HTTPBody的请求
/// @param URL 要请求的URL
/// @param method 请求方式
/// @param contentType HTTPBody的编码方式
/// @param query 在URL后拼接的参数
/// @param body HTTPBody数据
- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method contentType:(KSURLRequestContentType)contentType query:(NSDictionary <NSString *, id> *_Nullable)query body:(NSData *_Nullable)body;

/// 创建一个请求
/// @param URL 要请求的URL
/// @param method 请求方式
/// @param contentType params的编码方式
/// @param query 在URL后拼接的参数
/// @param params HTTPBody参数
/// 当contentType=KSURLRequestContentTypeTextPlain时请将文本以key=content value=文本内容的形式传入params
- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method contentType:(KSURLRequestContentType)contentType query:(NSDictionary <NSString *, id> *_Nullable)query params:(NSDictionary <NSString *, id> *_Nullable)params;

@end

@interface KSURLRequest (Convenient)

/// 便捷构造器，使用POST方式创建一个HTTPBody为json的请求。
/// contentType = KSURLRequestContentTypeJSON
/// @param URL 要请求的URL
/// @param jsonData json二进制数据包
- (instancetype)initWithURL:(NSURL *)URL jsonData:(NSData *)jsonData;

/// 便捷构造器，创建一个HTTP请求，如果请求方式为GET/DELETE，params将会转化为query拼接在URL后面，反之会放进HTTPBody中
/// @param URL 要请求的URL
/// @param method 请求方式
/// @param contentType params的编码方式
/// @param params query或HTTPBody参数
- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method contentType:(KSURLRequestContentType)contentType params:(NSDictionary <NSString *, id> *_Nullable)params;

/// 便捷构造器，创建一个HTTP请求，如果请求方式为GET/DELETE，params将会转化为query拼接在URL后面，反之会放进HTTPBody中。
/// contentType = KSURLRequestContentTypeJSON
/// @param URL 要请求的URL
/// @param method 请求方式
/// @param params query或HTTPBody参数
- (instancetype)initWithURL:(NSURL *)URL method:(KSURLRequestMethod)method params:(NSDictionary <NSString *, id> *_Nullable)params;

@end

NS_ASSUME_NONNULL_END
