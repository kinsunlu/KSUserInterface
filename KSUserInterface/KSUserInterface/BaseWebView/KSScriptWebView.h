//
//  KSScriptWebView.h
//  KSUserInterface
//
//  Created by Kinsun on 2021/1/15.
//  Copyright © 2021 Kinsun. All rights reserved.
//

#import "KSBaseWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSWebViewScriptHandler : NSObject

@property (nonatomic, weak, readonly) id target;
@property (readonly) SEL action;

- (instancetype)initWithTarget:(id)target action:(SEL)action;

@end

@interface KSScriptWebView : KSBaseWebView

@property (nonatomic, copy, readonly) NSDictionary <NSString *, KSWebViewScriptHandler *> *scriptHandlers;

- (instancetype)initWithScriptHandlers:(NSDictionary <NSString *, KSWebViewScriptHandler *> *)scriptHandlers;

@end

NS_ASSUME_NONNULL_END
