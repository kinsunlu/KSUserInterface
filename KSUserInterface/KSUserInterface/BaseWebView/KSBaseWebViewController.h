//
//  KSBaseWebViewController.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSBaseViewController.h"
#import "KSBaseWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSBaseWebViewController : KSSecondaryViewController <WKNavigationDelegate>

@property (nonatomic, weak, readonly) KSBaseWebView *webView;
@property (nonatomic, copy, nullable) NSString *filePath;
@property (nonatomic, copy, nullable) NSString *url;
@property (nonatomic, strong, nullable) NSDictionary <NSString *, id> *params;

/// 该方法不应该被调用，继承后重写webview子类
- (KSBaseWebView *)loadWebView;

/// 开始WebView请求，继承后手动调用
- (void)startWebViewRequest;

- (void)webView:(KSBaseWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;
- (void)webView:(KSBaseWebView *)webView didFinishNavigation:(WKNavigation *)navigation;

@end

/// 简易浏览器
@interface KSBrowserViewController : KSBaseWebViewController

@end

NS_ASSUME_NONNULL_END
