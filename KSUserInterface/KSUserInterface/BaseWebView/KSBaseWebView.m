//
//  KSBaseWebView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSBaseWebView.h"
#import "UIColor+Hex.h"

static NSString * const k_EstimatedProgress = @"estimatedProgress";
static NSString * const k_WebViewTitle      = @"title";
static NSString * const k_GetVideoTag       = @"document.getElementsByTagName('video')";

static NSString * const k_BlankPage         = @"about:blank";
static NSString * const k_questionMark      = @"?";
static NSString * const k_andMark           = @"&";

@interface KSBaseWebView ()

@property (nonatomic, class, readonly) NSArray <WKUserScript *> *_initUserScripts;

@end

@implementation KSBaseWebView {
    __weak UIImageView *_screenshotView;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    WKUserContentController *userContentController = configuration.userContentController;
    for (WKUserScript *script in self.class._initUserScripts) {
        [userContentController addUserScript:script];
    }

    if (self = [super initWithFrame:frame configuration:configuration]) {
        UIScrollView *scrollView = self.scrollView;
        scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        scrollView.contentInset = UIEdgeInsetsZero;
        scrollView.alwaysBounceHorizontal = NO;
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }

        Class class = NSClassFromString(@"WKContentView");
        for (UIView *view in scrollView.subviews) {
            if ([view isKindOfClass:class]) {
                _webContentView = view;
            }
        }

        CALayer *progressLayer = CALayer.layer;
        progressLayer.backgroundColor = UIColor.ks_lightMain.CGColor;
        [self.layer addSublayer:progressLayer];
        _progressLayer = progressLayer;

        NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
        [self addObserver:self forKeyPath:k_EstimatedProgress options:options context:NULL];
        [self addObserver:self forKeyPath:k_WebViewTitle options:options context:NULL];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    WKPreferences *preferences = WKPreferences.alloc.init;
    preferences.javaScriptEnabled = YES; //允许与js进行交互

    WKWebViewConfiguration *configuration = WKWebViewConfiguration.alloc.init;
    configuration.allowsInlineMediaPlayback = NO;
    configuration.preferences = preferences;
    return [self initWithFrame:frame configuration:configuration];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _progressLayer.frame = (CGRect){CGPointZero, _progressLayer.bounds.size.width, 4.0};
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == self) {
        if (keyPath == k_EstimatedProgress) {
            NSString *url = self.URL.absoluteString;
            if (![url isEqualToString:k_BlankPage]) {
                double estimatedProgress = self.estimatedProgress;
                CGRect frame = _progressLayer.frame;
                frame.size.width = self.frame.size.width*estimatedProgress;
                __weak typeof(self) weakSelf = self;
                __weak typeof(_progressLayer) weakView = _progressLayer;
                [UIView animateWithDuration:0.2f animations:^{
                    weakView.frame = frame;
                } completion:^(BOOL finished) {
                    if (estimatedProgress >= 1.f) {
                        [weakSelf resetProgressLayer];
                    } else {
                        weakView.hidden = NO;
                    }
                }];
            }
        } else if (_webViewTitleChangedCallback && keyPath == k_WebViewTitle) {
            _webViewTitleChangedCallback(self.title);
        }
    }
}

- (void)resetProgressLayer {
    _progressLayer.hidden = YES;
    CGRect frame = _progressLayer.frame;
    frame.size.width = 0.0;
    _progressLayer.frame = frame;
}

- (WKNavigation *)loadRequest:(NSMutableURLRequest *)request {
    NSDictionary <NSString *, NSString *> *HTTPHeaders = _HTTPHeaders;
    if (HTTPHeaders != nil) {
        NSArray <NSString*>*allKeys = HTTPHeaders.allKeys;
        for (NSString *key in allKeys) {
            NSString *value = [HTTPHeaders objectForKey:key];
            if (value != nil)
                [request addValue:value forHTTPHeaderField:key];
        }
    }
    return [super loadRequest:request];
}

- (void)loadWebViewWithURL:(NSString *)url params:(NSDictionary<NSString *, id> *)params {
    if (url != nil && url.length != 0) {
        if (params != nil) {
            NSMutableString *urlString = [NSMutableString stringWithString:url];
            NSString *bridge = k_questionMark;
            if ([urlString rangeOfString:bridge].location != NSNotFound) {
                bridge = k_andMark;
            }
            NSMutableString *paramsStr = [NSMutableString stringWithString:bridge];
            NSArray <NSString *> *allKeys = params.allKeys;
            for (NSInteger i = 0; i < allKeys.count; i++) {
                NSString *key = [allKeys objectAtIndex:i];
                NSString *value = [[params objectForKey:key] description];
                [paramsStr appendFormat:@"%@=%@", key, value];
                if (i != allKeys.count-1) {
                    [paramsStr appendString:k_andMark];
                }
            }
            [urlString appendString:paramsStr];
            url = urlString;
        }
        NSURL *k_url = [NSURL URLWithString:url];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:k_url];
        [self loadRequest:request];
    }
}

- (void)loadWebViewWithFilePath:(NSString *)filePath {
    if (filePath != nil && filePath.length > 0) {
        NSString *questionMark = k_questionMark;
        NSArray <NSString*>*stringArray = [filePath componentsSeparatedByString:questionMark];
        NSURL *fileURL = nil;
        if (stringArray.count > 1) {
            fileURL = [NSURL fileURLWithPath:stringArray.firstObject];
        } else {
            fileURL = [NSURL fileURLWithPath:filePath];
        }
        NSURL *baseURL = fileURL;
        if (stringArray.count > 1) {
            NSString *fileURLString = [NSString stringWithFormat:@"%@%@%@",fileURL.absoluteString,questionMark,stringArray.lastObject];
            baseURL = [NSURL URLWithString:fileURLString];
        }
        [self loadFileURL:baseURL allowingReadAccessToURL:baseURL];
    }
}

- (void)webViewBeginScreenshot {
    CALayer *layer = self.layer;
    UIGraphicsBeginImageContextWithOptions(layer.bounds.size, layer.opaque, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    UIImageView *screenshotView = _screenshotView;
    if (screenshotView == nil) {
        screenshotView = [[UIImageView alloc]init];
        screenshotView.backgroundColor = [UIColor whiteColor];
        [self addSubview:screenshotView];
        _screenshotView = screenshotView;
    }
    screenshotView.image = img;
    screenshotView.frame = self.bounds;
    screenshotView.hidden = NO;
}

- (void)webViewEndScreenshot {
    UIImageView *screenshotView = _screenshotView;
    if (screenshotView) screenshotView.hidden = YES;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) self.scrollView.delegate = nil;
    [super willMoveToSuperview:newSuperview];
}

+ (NSArray<WKUserScript *> *)_initUserScripts {
    static NSArray<WKUserScript *> *k_initUserScripts = nil;
    if (k_initUserScripts == nil) {
        NSString *noSelectCss = @"var style = document.createElement('style');style.type = 'text/css';var cssContent = document.createTextNode('body{-webkit-touch-callout:none;}');style.appendChild(cssContent);document.body.appendChild(style);";
        WKUserScript *noneSelectScript = [[WKUserScript alloc] initWithSource:noSelectCss injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        NSString *injectionJSString = @"var script = document.createElement('meta');"
            "script.name = 'viewport';"
            "script.content=\"width=device-width, user-scalable=no\";"
            "document.getElementsByTagName('head')[0].appendChild(script);";
        WKUserScript *noneZoom = [[WKUserScript alloc] initWithSource:injectionJSString injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        k_initUserScripts = @[noneSelectScript, noneZoom];
    }
    return k_initUserScripts;
}

- (void)dealloc {
    self.navigationDelegate = nil;
    [self removeObserver:self forKeyPath:k_EstimatedProgress];
    [self removeObserver:self forKeyPath:k_WebViewTitle];
}

- (void)videoPlayerCount:(void (^)(NSInteger))callback {
    if (callback != nil) {
        NSString * hasVideoTestString = [NSString stringWithFormat:@"%@.length",k_GetVideoTag];
        [self evaluateJavaScript:hasVideoTestString completionHandler:^(NSNumber *result, NSError *error) {
            if (callback != nil) callback(result.unsignedIntegerValue);
        }];
    }
}

- (void)videoDurationWithIndex:(NSInteger)index callback:(void(^)(double))callback {
    if (callback != nil) {
        __weak typeof(self) weakSelf = self;
        [self videoPlayerCount:^(NSInteger count) {
            if (index < count) {
                NSString * durationString = [NSString stringWithFormat:@"%@[%td].duration.toFixed(1)", k_GetVideoTag, index];
                [weakSelf evaluateJavaScript:durationString completionHandler:^(NSNumber *result, NSError *error) {
                    if (callback != nil) callback(result.doubleValue);
                }];
            }
        }];
    }
}

- (void)videoCurrentTimeWithIndex:(NSInteger)index callback:(void(^)(double))callback {
    if (callback != nil) {
        __weak typeof(self) weakSelf = self;
        [self videoPlayerCount:^(NSInteger count) {
            if (index < count) {
                NSString * durationString = [NSString stringWithFormat:@"%@[%td].currentTime.toFixed(1)", k_GetVideoTag, index];
                [weakSelf evaluateJavaScript:durationString completionHandler:^(NSNumber *result, NSError *error) {
                    if (callback != nil) callback(result.doubleValue);
                }];
            }
        }];
    }
}

- (void)playVideoWithIndex:(NSInteger)index {
    __weak typeof(self) weakSelf = self;
    [self videoPlayerCount:^(NSInteger count) {
        if (index < count) {
            NSString *playString = [NSString stringWithFormat:@"%@[%td].play()", k_GetVideoTag, index];
            [weakSelf evaluateJavaScript:playString completionHandler:nil];
        }
    }];
}

- (void)pausePlayingVideo {
    __weak typeof(self) weakSelf = self;
    [self videoPlayerCount:^(NSInteger count) {
        if (count > 0) {
            NSString *pauseString = [NSString stringWithFormat:@"var dom = %@;for(var i = 0; i < dom.length; i++){dom[i].pause();}", k_GetVideoTag];
            [weakSelf evaluateJavaScript:pauseString completionHandler:nil];
        }
    }];
}

@end
