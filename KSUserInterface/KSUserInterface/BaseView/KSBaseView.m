//
//  KSBaseView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSBaseView.h"
#import "UIColor+Hex.h"
#import "KSBaseViewController.h"

@implementation KSBaseView {
    __weak KSToastContentView *_toastContentView;
}
@synthesize loadingView = _loadingView;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = UIColor.ks_background;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.bounds;
    _backgroundView.frame = bounds;
    _loadingView.frame = bounds;
    _toastContentView.frame = bounds;
}

- (void)setBackgroundView:(UIView *)backgroundView {
    if (_backgroundView != nil) {
        [_backgroundView removeFromSuperview];
    }
    _backgroundView = backgroundView.mutableCopy;
    if (_backgroundView != nil) {
        [self insertSubview:_backgroundView atIndex:0];
        [self setNeedsLayout];
    }
}

- (void)_didClickLoadingView:(KSLoadingView *)loadingView {
    if (_didClickLoadingViewCallback != nil) {
        _didClickLoadingViewCallback(self, loadingView);
    }
}

- (KSLoadingView *)loadingView {
    if (_loadingView == nil) {
        KSLoadingView *loadingView = KSLoadingView.alloc.init;
        [loadingView addTarget:self action:@selector(_didClickLoadingView:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:loadingView];
        _loadingView = loadingView;
    }
    return _loadingView;
}

- (KSToast *)toast {
    return _toastContentView.toast;
}

- (void)showToastWithStyle:(KSToastStyle)style {
    if (style == KSToastStyleMessage) return;
    if (_toastContentView != nil) {
        [_toastContentView removeFromSuperview];
    }
    KSToastContentView *toast = [KSToastContentView.alloc initWithFrame:self.bounds style:style];
    [self addSubview:toast];
    _toastContentView = toast;
    [toast.toast showToast];
}

- (void)dismissToast {
    if (_toastContentView != nil) {
        [_toastContentView.toast dismissToastWithCompletion:^(KSToast *k_toast) {
            [k_toast.superview removeFromSuperview];
        }];
    }
}

@end

#import "KSUITools.h"

@implementation KSSystemStyleView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame navigationView:KSNavigationView.alloc.init];
}

- (instancetype)initWithFrame:(CGRect)frame navigationView:(KSNavigationView *)navigationView {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:navigationView];
        _navigationView = navigationView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat statusBarHeight = CGRectGetMaxY([KSUITools statusBarFrameFromView:self]);
    _navigationView.statusBarHeight = statusBarHeight;
    _navigationView.frame = (CGRect){CGPointZero, self.bounds.size.width, statusBarHeight+44.0};
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
    [self bringSubviewToFront:_navigationView];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [super insertSubview:view atIndex:index];
    [self bringSubviewToFront:_navigationView];
}

- (void)addSubviewToTheTop:(UIView *)view {
    [super insertSubview:view atIndex:self.subviews.count];
}

@end

@implementation KSSecondaryView
@dynamic navigationView;

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame navigationView:KSSecondaryNavigationView.alloc.init];
}

- (instancetype)initWithFrame:(CGRect)frame navigationView:(KSSecondaryNavigationView *)navigationView {
    return [super initWithFrame:frame navigationView:navigationView];
}

@end
