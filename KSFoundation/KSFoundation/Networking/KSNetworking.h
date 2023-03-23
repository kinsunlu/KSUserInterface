//
//  KSNetworking.h
//  KSFoundation
//
//  Created by Kinsun on 2020/4/27.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSURLRequest.h"

typedef NS_ENUM(NSInteger, KSCertificateType) {
    KSCertificateTypeP12    = 0, /// p12格式证书，需要密码
    KSCertificateTypeCer    = 1 /// cer格式证书不需要密码
} NS_SWIFT_NAME(KSCertificate.Type);

NS_ASSUME_NONNULL_BEGIN

@interface KSCertificate : NSObject

@property (nonatomic, assign, readonly) KSCertificateType type;
@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, copy, nullable, readonly) NSString *password;

- (instancetype)initWithData:(NSData *)data type:(KSCertificateType)type password:(NSString * _Nullable)password;

- (NSURLCredential *_Nullable)trustWithSpace:(NSURLProtectionSpace *_Nonnull)space;

@end

typedef void(^KSNetworkingDownloadCallback)(NSURL *_Nullable, NSError *_Nullable) NS_SWIFT_NAME(KSNetworking.DownloadCallback);

@interface KSNetworking <__covariant DataType> : NSObject

typedef void(^KSNetworkingCallback)(DataType _Nullable, NSError *_Nullable) NS_SWIFT_NAME(KSNetworking.Callback);

@property (nonatomic, readonly) NSURLSessionConfiguration *configuration;
@property (nonatomic, readonly) NSOperationQueue *queue;

@property (nonatomic, strong, nullable) NSDictionary <NSString *, id> *publicRequestHeaders;

@property (nonatomic, strong, nullable) KSCertificate *clientCertificate;
@property (nonatomic, assign, getter=isNeedServerTrust) BOOL needServerTrust;
@property (nonatomic, strong, nullable) KSCertificate *serverTrustCertificate;

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration queue:(NSOperationQueue *_Nullable)queue;

- (NSURLSessionDataTask *)requestWithRequest:(KSURLRequest *)request callback:(KSNetworkingCallback _Nullable)callback;

- (NSURLSessionDataTask *)requestDataWithRequest:(KSURLRequest *)request callback:(KSNetworkingCallback _Nullable)callback;

- (NSURLSessionDataTask *)requestDataWithRequest:(KSURLRequest *)request onMainThreadCallback:(KSNetworkingCallback _Nullable)callback;

- (NSURLSessionDownloadTask *)downloadWithURL:(NSURL *)url callback:(KSNetworkingDownloadCallback _Nullable)callback;

@end

@interface KSNetworking <__covariant DataType> (Convenient)

@property (nonatomic, readonly, class) KSNetworking *dataNetworking;
@property (nonatomic, readonly, class) KSNetworking *downloadNetworking;

- (NSURLSessionDataTask *)requestWithURL:(NSURL *)url method:(KSURLRequestMethod)method params:(NSDictionary <NSString *, id> * _Nullable)params callback:(KSNetworkingCallback _Nullable)callback;

- (NSURLSessionDataTask *)requestWithURLString:(NSString *)urlString method:(KSURLRequestMethod)method params:(NSDictionary <NSString *, id> *_Nullable)params callback:(KSNetworkingCallback _Nullable)callback;

- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString callback:(KSNetworkingDownloadCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
