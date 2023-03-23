//
//  KSScriptWebView.m
//  KSUserInterface
//
//  Created by Kinsun on 2021/1/15.
//  Copyright © 2021 Kinsun. All rights reserved.
//

#import "KSScriptWebView.h"

@implementation KSWebViewScriptHandler

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    if (self = [super init]) {
        _target = target;
        _action = action;
    }
    return self;
}

@end

NSString * const k_ks_WebViewBridgeIndexKey = @"__ks_web_bridge_";

@interface KSScriptWebView () <WKUIDelegate>

@end

@implementation KSScriptWebView {
    __weak id<WKUIDelegate> _UIDelegate;
}

- (instancetype)initWithScriptHandlers:(NSDictionary<NSString *,KSWebViewScriptHandler *> *)scriptHandlers {
    if (self = [super init]) {
        _scriptHandlers = scriptHandlers.copy;
        NSMutableString *scriptString = NSMutableString.string;
        for (NSString *funcName in scriptHandlers.allKeys) {
            [scriptString appendFormat:@"android['%@']=function(){var array=[].slice.call(arguments);var returnString=prompt('__ks_web_bridge_%@',JSON.stringify(array));if(returnString==null){return null}return JSON.parse(returnString)};", funcName, funcName];
        }
        NSString *s = [NSString stringWithFormat:@"window.android=function(){var android={};%@return android}();", scriptString];
        WKUserContentController *userContentController = self.configuration.userContentController;
        WKUserScript *script = [WKUserScript.alloc initWithSource:s injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
        [userContentController addUserScript:script];
        
        super.UIDelegate = self;
    }
    return self;
}

- (void)setUIDelegate:(id<WKUIDelegate>)UIDelegate {
    _UIDelegate = UIDelegate;
}

- (id<WKUIDelegate>)UIDelegate {
    return _UIDelegate;
}

- (void)webView:(KSScriptWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)body initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * result))completionHandler {
    NSString *prefix = k_ks_WebViewBridgeIndexKey;
    if ([prompt hasPrefix:prefix]) {
        NSString *name = [prompt substringFromIndex:prefix.length];
        KSWebViewScriptHandler *handler = [_scriptHandlers objectForKey:name];
        if (handler == nil) {
            completionHandler([KSScriptWebView _errorJsonWithCode:-999 msg:@"客户端没有找到该方法"]);
            return;
        }
        id target = handler.target;
        SEL action = handler.action;
        NSMethodSignature *signature = [target methodSignatureForSelector:action];
        const char *returnType = signature.methodReturnType;
        BOOL notHasReturnValue = !strcmp(returnType, @encode(void));
        if (notHasReturnValue) {
            completionHandler(nil);
        }
        if ([target respondsToSelector:action]) {
            NSUInteger numberOfArguments = signature.numberOfArguments;
            if (numberOfArguments > 2) {
                NSArray <id> *arguments = nil;
                if (body != nil && body.length > 0) {
                    NSError *error = nil;
                    arguments = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
                    if (error != nil) {
                        completionHandler([KSScriptWebView _errorJsonWithError:error]);
                        return;
                    }
                    if (arguments.count != numberOfArguments-2) {
                        completionHandler([KSScriptWebView _errorJsonWithCode:-998 msg:@"客户端的参数个数与JS不匹配"]);
                        return;
                    }
                }
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
                invocation.selector = action;
                for (NSInteger i = 0; i < arguments.count; i++) {
                    const char *argType = [signature getArgumentTypeAtIndex:i+2];
                    id arg = [arguments objectAtIndex:i];
                    if (arg == NSNull.null) {// 空
                        void *location = NULL;
                        [invocation setArgument:location atIndex:i+2];
                    } else if (strcmp(argType, @encode(id)) != 0) { // 基本数据类型
                        NSNumber *number = arg;
                        size_t length = __ks_lengthFromType(number.objCType);
                        void *location = (void *)malloc(length);
                        if (@available(iOS 11.0, *)) {
                            [number getValue:location size:length];
                        } else {
                            [number getValue:location];
                        }
                        [invocation setArgument:location atIndex:i+2];
                    } else { // 对象
                        [invocation setArgument:&arg atIndex:i+2];
                    }
                }
                [invocation invokeWithTarget:target];
                if (!notHasReturnValue) {
                    if (strcmp(returnType, @encode(id))) {
                        void *buffer = (void *)malloc(signature.methodReturnLength);
                        [invocation getReturnValue:buffer];
                        NSValue *number = [NSNumber value:buffer withObjCType:returnType];
                        completionHandler([KSScriptWebView _jsonWithObject:number]);
                    } else {
                        void *temp;
                        [invocation getReturnValue:&temp];
                        completionHandler([KSScriptWebView _jsonWithObject:(__bridge id)temp]);
                    }
                }
            } else {
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                if (notHasReturnValue) {
                    [target performSelector:action];
                } else {
                    id returnValue = [target performSelector:action];
                    completionHandler([KSScriptWebView _jsonWithObject:returnValue]);
                }
            }
        }
    } else if (_UIDelegate != nil && [_UIDelegate respondsToSelector:_cmd]) {
        [_UIDelegate webView:webView runJavaScriptTextInputPanelWithPrompt:prompt defaultText:body initiatedByFrame:frame completionHandler:completionHandler];
    }
}

+ (NSString *)_errorJsonWithError:(NSError *)error {
    return [self _errorJsonWithCode:error.code msg:error.localizedDescription];
}

+ (NSString *)_errorJsonWithCode:(NSInteger)code msg:(NSString *)msg {
    return [self _jsonWithObject:@{@"code": @(code), @"msg": msg ?: @""}];
}

+ (NSString *)_jsonWithObject:(id)object {
    NSJSONWritingOptions options = 0;
    if (@available(iOS 11.0, *)) options = NSJSONWritingSortedKeys;
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:options error:nil];
    if (data == nil) return nil;
    return [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
}

size_t __ks_lengthFromType(const char *type) {
    if (strcmp(type, @encode(int)) == 0) {
        return sizeof(int);
    } else if (strcmp(type, @encode(unsigned int)) == 0) {
        return sizeof(unsigned int);
    } else if (strcmp(type, @encode(long)) == 0) {
        return sizeof(long);
    } else if (strcmp(type, @encode(unsigned long)) == 0) {
        return sizeof(unsigned long);
    } else if (strcmp(type, @encode(long long)) == 0) {
        return sizeof(long long);
    } else if (strcmp(type, @encode(unsigned long long)) == 0) {
        return sizeof(unsigned long long);
    } else if (strcmp(type, @encode(float)) == 0) {
        return sizeof(float);
    } else if (strcmp(type, @encode(double)) == 0) {
        return sizeof(double);
    } else if (strcmp(type, @encode(BOOL)) == 0) {
        return sizeof(BOOL);
    } else if (strcmp(type, @encode(NSInteger)) == 0) {
        return sizeof(NSInteger);
    } else if (strcmp(type, @encode(NSUInteger)) == 0) {
        return sizeof(NSUInteger);
    } else if (strcmp(type, @encode(char)) == 0) {
        return sizeof(char);
    } else if (strcmp(type, @encode(unsigned char)) == 0) {
        return sizeof(unsigned char);
    } else if (strcmp(type, @encode(short)) == 0) {
        return sizeof(short);
    } else if (strcmp(type, @encode(unsigned short)) == 0) {
        return sizeof(unsigned short);
    } else return 16;
}

@end
