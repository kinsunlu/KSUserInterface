//
//  KSBaseWebViewController.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSBaseWebViewController.h"
#import "KSBaseView.h"

@implementation KSBaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"...";
}

- (void)loadView {
    [super loadView];
    KSBaseWebView *webView = self.loadWebView;
    __weak typeof(self) weakSelf = self;
    [webView setWebViewTitleChangedCallback:^(NSString *title) {
        weakSelf.title = title;
    }];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    _webView = webView;
}

- (KSBaseWebView *)loadWebView {
    return KSBaseWebView.alloc.init;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    KSSystemStyleView *view = self.view;
    CGSize windowSize = view.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat viewX = 0.0;
    CGFloat viewY = CGRectGetMaxY(view.navigationView.frame);
    CGFloat viewW = windowWidth;
    CGFloat viewH = windowHeight-viewY;
    _webView.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    UIScrollView *scrollView = _webView.scrollView;
    UIEdgeInsets safearea = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safearea = view.safeAreaInsets;
    }
    UIEdgeInsets inset = (UIEdgeInsets){0.0, 0.0, safearea.bottom, 0.0};
    scrollView.contentInset = inset;
    scrollView.scrollIndicatorInsets = inset;
}

- (void)startWebViewRequest {
    if (_url != nil && _url.length != 0) {
        [_webView loadWebViewWithURL:_url params:_params];
    } else if (_filePath != nil && _filePath.length != 0) {
        [_webView loadWebViewWithFilePath:_filePath];
    }
}

- (void)webView:(KSBaseWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [_webView resetProgressLayer];
}

- (void)webView:(KSBaseWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [_webView resetProgressLayer];
}

@end

#import "KSBoxLayoutButton.h"
#import <KSUserInterface/UIColor+Hex.h>

@implementation KSBrowserViewController {
    __weak KSImageButton *_closeButton;
}

NSString * const _k_CanGoBack = @"canGoBack";

- (void)loadView {
    [super loadView];
    KSImageButton *closeButton = KSImageButton.alloc.init;
    closeButton.contentInset = (UIEdgeInsets){13.0, 11.0, 13.0, 11.0};
    closeButton.contentView.tintColor = UIColor.ks_title;
    closeButton.normalImage = [[UIImage imageNamed:@"KSUserInterface.bundle/icon_navigation_close"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [closeButton addTarget:self action:@selector(_didClickCloseButton:) forControlEvents:UIControlEventTouchUpInside];
    closeButton.hidden = YES;
    [self.view.navigationView addLeftView:closeButton];
    _closeButton = closeButton;
    
    NSKeyValueObservingOptions options = NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld;
    [self.webView addObserver:self forKeyPath:_k_CanGoBack options:options context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    WKWebView *view = self.webView;
    if (object == view) {
        if (keyPath == _k_CanGoBack) {
            _closeButton.hidden = !view.canGoBack;
            [self.view.navigationView setNeedsLayout];
        }
    }
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:_k_CanGoBack];
}

- (void)_didClickCloseButton:(KSImageButton *)closeButton {
    [super didClickNavigationBackButton:closeButton];
}

- (void)didClickNavigationBackButton:(UIControl *)backButton {
    if (_closeButton.isHidden) {
        [super didClickNavigationBackButton:backButton];
    } else {
        [self.webView goBack];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startWebViewRequest];
}

@end
