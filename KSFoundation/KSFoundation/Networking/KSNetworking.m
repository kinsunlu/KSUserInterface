//
//  KSNetworking.m
//  KSFoundation
//
//  Created by Kinsun on 2020/4/27.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSNetworking.h"

typedef void(^_KSNetworkingCallbackBlock)(id, NSError *);

@interface _KSNetworkingModel <__covariant DataType> : NSObject

@property (nonatomic, assign, getter=isStream) BOOL stream;
@property (nonatomic, copy, readonly) _KSNetworkingCallbackBlock callback;
@property (nonatomic, strong) DataType data;

@end

@implementation _KSNetworkingModel

- (instancetype)initWithCallback:(_KSNetworkingCallbackBlock)callback {
    if (self = [super init]) {
        _callback = [callback copy];
    }
    return self;
}

@end

#import <pthread/pthread.h>

@implementation KSCertificate

- (instancetype)initWithData:(NSData *)data type:(KSCertificateType)type password:(NSString *)password {
    if (self = [super init]) {
        NSAssert(type == KSCertificateTypeCer || (type == KSCertificateTypeP12 && password != nil), @"P12 类型证书必须设置密码");
        _data = data;
        _type = type;
        _password = password.copy;
    }
    return self;
}

- (NSURLCredential *)trustWithSpace:(NSURLProtectionSpace *)space {
    switch (_type) {
        case KSCertificateTypeP12:
            return [self _p12TrustWithSpace:space];
        case KSCertificateTypeCer:
            return [self _cerTrustWithSpace:space];
        default:
            break;
    }
}

- (NSURLCredential *)_p12TrustWithSpace:(NSURLProtectionSpace *)space {
    //client certificate password
    NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:_password forKey:(__bridge id)kSecImportExportPassphrase];
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)_data, (__bridge CFDictionaryRef)optionsDictionary, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        SecIdentityRef identity = (SecIdentityRef)tempIdentity;
        
        SecCertificateRef certificate = NULL;
        SecIdentityCopyCertificate(identity, &certificate);
        const void *certs[] = {certificate};
        CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
        
        return [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray *)certArray persistence:NSURLCredentialPersistencePermanent];
    } else {
        NSLog(@"Failedwith error code %d", (int)securityError);
        return nil;
    }
}

- (NSURLCredential *)_cerTrustWithSpace:(NSURLProtectionSpace *)space {
    SecCertificateRef certificate = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)_data);
    if (certificate != NULL) {
        SecTrustRef serverTrust = space.serverTrust;
        const void *certs[] = {certificate};
        CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
        //将读取的证书设置为服务端帧数的根证书
        OSStatus status = SecTrustSetAnchorCertificates(serverTrust, certArray);
        if (status == errSecSuccess) {
            SecTrustResultType result = -1;
            //验证服务器的证书是否可信(有可能通过联网验证证书颁发机构)
            status = SecTrustEvaluate(serverTrust, &result);
            if (status == errSecSuccess && (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed)) {
                return [NSURLCredential credentialForTrust:serverTrust];
            }
        }
        NSLog(@"Failedwith error code %d", (int)status);
    }
    return nil;
}

@end

@interface KSNetworking () <NSURLSessionDataDelegate, NSURLSessionDownloadDelegate>

@end

@implementation KSNetworking {
    NSLock *_taskPoolLock;
    
    NSURLSession *_session;
    NSMapTable <NSURLSessionTask *, _KSNetworkingModel *> *_taskPool;
}

- (instancetype)initWithConfiguration:(NSURLSessionConfiguration *)configuration queue:(NSOperationQueue *)queue {
    if (self = [super init]) {
        if (configuration == nil) {
            configuration = NSURLSessionConfiguration.defaultSessionConfiguration;
        }
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:queue];
        _taskPool = [NSMapTable strongToStrongObjectsMapTable];
        _taskPoolLock = NSLock.alloc.init;
    }
    return self;
}

- (NSURLSessionConfiguration *)configuration {
    return _session.configuration;
}

- (NSOperationQueue *)queue {
    return _session.delegateQueue;
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    [_taskPoolLock lock];
    _KSNetworkingModel<NSMutableData *> *model = [_taskPool objectForKey:dataTask];
    [_taskPoolLock unlock];
    if (model != nil && model.callback != nil) {
        if (!model.isStream) {
            model.data = NSMutableData.data;
        }
        completionHandler(NSURLSessionResponseAllow);
    } else {
        completionHandler(NSURLSessionResponseCancel);
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [_taskPoolLock lock];
    _KSNetworkingModel<NSMutableData *> *model = [_taskPool objectForKey:dataTask];
    [_taskPoolLock unlock];
    if (model != nil) {
        if (model.isStream) {
            model.callback(data, nil);
        } else if (model.data != nil) {
            [model.data appendData:data];
        }
    }
}

#pragma mark - NSURLSessionDownloadDelegate
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    [_taskPoolLock lock];
    _KSNetworkingModel *model = [_taskPool objectForKey:downloadTask];
    [_taskPoolLock unlock];
    if (model != nil && model.callback != nil) {
        if (pthread_main_np() != 0) {
            model.callback(location, nil);
        } else dispatch_async(dispatch_get_main_queue(), ^{
            model.callback(location, nil);
        });
    }
}

#pragma mark - NSURLSessionTaskDelegate
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    [_taskPoolLock lock];
    _KSNetworkingModel<NSMutableData *> *model = [_taskPool objectForKey:task];
    [_taskPoolLock unlock];
    if (model != nil && model.callback != nil) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
        if ([response isKindOfClass:NSHTTPURLResponse.class]) {
            NSInteger statusCode = response.statusCode;
            if (statusCode != 200) {
                error = [NSError errorWithDomain:NSURLErrorDomain code:statusCode userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"服务器异常，请稍后重试。错误码 %zd", statusCode]}];
            }
        }
        if ([task isKindOfClass:NSURLSessionDataTask.class]) {
            model.callback(model.isStream ? [@"status: isEnd" dataUsingEncoding:NSUTF8StringEncoding] : model.data, error);
            [_taskPoolLock lock];
            [_taskPool removeObjectForKey:task];
            [_taskPoolLock unlock];
        } else if ([task isKindOfClass:NSURLSessionDownloadTask.class]) {
            if (error != nil) {
                if (pthread_main_np() != 0) {
                    model.callback(nil, error);
                } else dispatch_async(dispatch_get_main_queue(), ^{
                    model.callback(nil, error);
                });
            }
        }
    }
    [_taskPoolLock lock];
    [_taskPool removeObjectForKey:task];
    [_taskPoolLock unlock];
}

//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
//
//}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSURLProtectionSpace *protectionSpace = challenge.protectionSpace;
    NSString *authenticationMethod = protectionSpace.authenticationMethod;
    if (authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *newCredential = nil;
        if (_needServerTrust) {
            NSAssert(_serverTrustCertificate != nil, @"你选择了需要验证服务器needServerTrust = YES, 却没有设置serverTrustCertificate。");
            newCredential = [_serverTrustCertificate trustWithSpace:protectionSpace];
        } else {
            SecTrustRef trust = protectionSpace.serverTrust;
            SecTrustSetAnchorCertificates(trust, nil);
            newCredential = [NSURLCredential credentialForTrust:trust];
        }
        completionHandler(NSURLSessionAuthChallengeUseCredential, newCredential);
        return;
    } else if (authenticationMethod == NSURLAuthenticationMethodClientCertificate) {
        if (_clientCertificate != nil) {
            NSURLCredential *credential = [_clientCertificate trustWithSpace:protectionSpace];
            //关键回传NSURLCredential 证书凭证
            //NSURLCredential * getCredential = [NSURLCredential credentialWithIdentity:(SecIdentityRef)identity certificates:nil persistence:NSURLCredentialPersistenceForSession];
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
        }
    }
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark - public headers

- (NSURLSessionDataTask *)requestDataWithRequest:(KSURLRequest *)request callback:(KSNetworkingCallback)callback {
    if (_publicRequestHeaders != nil) {
        [_publicRequestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    _KSNetworkingModel<NSMutableData *> *model = [_KSNetworkingModel.alloc initWithCallback:callback];
    model.stream = request.contentType == KSURLRequestContentTypeEventStream;
    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request];
    [_taskPoolLock lock];
    [_taskPool setObject:model forKey:task];
    [_taskPoolLock unlock];
    [task resume];
    return task;
}

- (NSURLSessionDataTask *)requestDataWithRequest:(KSURLRequest *)request onMainThreadCallback:(KSNetworkingCallback)callback {
    KSNetworkingCallback k_callback = nil;
    if (callback != nil) {
        k_callback = ^(NSData *data, NSError *error){
            if (pthread_main_np() != 0) {
                callback(data, error);
            } else dispatch_async(dispatch_get_main_queue(), ^{
                callback(data, error);
            });
        };
    }
    return [self requestDataWithRequest:request callback:k_callback];
}

- (NSURLSessionDataTask *)requestWithRequest:(KSURLRequest *)request callback:(KSNetworkingCallback)callback {
    KSNetworkingCallback k_callback = nil;
    if (callback != nil) {
        k_callback = ^(NSData *data, NSError *error){
            if (error == nil) {
                id k_data = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                if (error == nil) {
                    [KSNetworking _filterNullForJsonObject:k_data];
                }
                callback(k_data, error);
                return;
            }
            callback(nil, error);
        };
    }
    return [self requestDataWithRequest:request onMainThreadCallback:k_callback];
}

- (NSURLSessionDownloadTask *)downloadWithURL:(NSURL *)url callback:(KSNetworkingDownloadCallback)callback {
    _KSNetworkingModel *model = [_KSNetworkingModel.alloc initWithCallback:callback];
    KSURLRequest *request = [KSURLRequest.alloc initWithURL:url method:KSURLRequestMethodGET params:nil];
    if (_publicRequestHeaders != nil) {
        [_publicRequestHeaders enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
    NSURLSessionDownloadTask *task = [_session downloadTaskWithRequest:request];
    [_taskPoolLock lock];
    [_taskPool setObject:model forKey:task];
    [_taskPoolLock unlock];
    [task resume];
    return task;
}

+ (void)_filterNullForJsonObject:(id)jsonObject {
    if ([jsonObject isKindOfClass:NSDictionary.class]) {
        NSNull *null = NSNull.null;
        NSArray *allKeys = [jsonObject allKeys];
        for (id key in allKeys) {
            id obj = [jsonObject objectForKey:key];
            if (obj == null) {
                [jsonObject removeObjectForKey:key];
            } else {
                [self _filterNullForJsonObject:obj];
            }
        }
    } else if ([jsonObject isKindOfClass:NSArray.class]) {
        NSNull *null = NSNull.null;
        for (NSInteger i = [jsonObject count]-1; i >= 0; i --) {
            id obj = [jsonObject objectAtIndex:i];
            if (obj == null) {
                [jsonObject removeObjectAtIndex:i];
            } else {
                [self _filterNullForJsonObject:obj];
            }
        }
    }
}

@end

@implementation KSNetworking (Convenient)

+ (instancetype)dataNetworking {
    static KSNetworking *k_dataNetworking = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = NSURLSessionConfiguration.defaultSessionConfiguration.mutableCopy;
        configuration.timeoutIntervalForRequest = 3.0;
        NSOperationQueue *queue = NSOperationQueue.alloc.init;
        queue.name = @"com.kinsun.networking.queue";
        queue.maxConcurrentOperationCount = 5;
        k_dataNetworking = [[self alloc] initWithConfiguration:configuration queue:queue];
    });
    return k_dataNetworking;
}

+ (instancetype)downloadNetworking {
    static KSNetworking *k_downloadNetworking = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 30.0;
        configuration.networkServiceType = NSURLNetworkServiceTypeBackground;
        k_downloadNetworking = [[self alloc] initWithConfiguration:configuration queue:nil];
    });
    return k_downloadNetworking;
}

- (NSURLSessionDataTask *)requestWithURL:(NSURL *)url method:(KSURLRequestMethod)method params:(NSDictionary <NSString *, id> *)params callback:(KSNetworkingCallback)callback {
    return [self requestWithRequest:[KSURLRequest.alloc initWithURL:url method:method contentType:KSURLRequestContentTypeJSON params:params] callback:callback];
}

- (NSURLSessionDataTask *)requestWithURLString:(NSString *)urlString method:(KSURLRequestMethod)method params:(NSDictionary <NSString *, id> *)params callback:(KSNetworkingCallback)callback {
    return [self requestWithURL:[NSURL URLWithString:urlString] method:method params:params callback:callback];
}

- (NSURLSessionDownloadTask *)downloadWithURLString:(NSString *)urlString callback:(KSNetworkingDownloadCallback)callback {
    return [self downloadWithURL:[NSURL URLWithString:urlString] callback:callback];
}

@end
