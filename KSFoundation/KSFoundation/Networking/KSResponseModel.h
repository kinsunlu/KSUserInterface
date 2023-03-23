//
//  KSResponseModel.h
//  KSFoundation
//
//  Created by Kinsun on 2020/4/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSModelsProtocol.h"
#import "KSRequestModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSResponseModel <__covariant DataType> : NSObject <KSEnModelsProtocol>

/// 提示
@property (nonatomic, copy, readonly, nullable) NSString *message;
/// 响应结果的code码
@property (nonatomic, assign, readonly) NSInteger code;
/// 响应数据
@property (nonatomic, strong, readonly, nullable) DataType data;

@end

@interface KSNetworking <__covariant DataType> (KSResponseModel)

typedef void(^KSNetworkingModelCallback)(KSResponseModel<DataType> *_Nullable, NSError *_Nullable) NS_SWIFT_NAME(KSNetworking.ModelCallback);

- (NSURLSessionDataTask *)requestForResponseModelWithRequest:(KSURLRequest *)request callback:(KSNetworkingModelCallback _Nullable)callback;

- (NSURLSessionDataTask *)requestForResponseModelWithModel:(KSRequestModel *)model params:(NSDictionary <NSString *, id> *_Nullable)params callback:(KSNetworkingModelCallback _Nullable)callback;

- (NSURLSessionDataTask *)requestForResponseModelWithModel:(KSRequestModel *)model callback:(KSNetworkingModelCallback _Nullable)callback;

@end

NS_ASSUME_NONNULL_END
