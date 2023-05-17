//
//  KSImagePickerViewerView.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/4.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerViewerView.h"
#import "KSImagePickerToolBar.h"
#import "UIColor+Hex.h"

@implementation KSImagePickerViewerView {
    __weak UIView *_toolBarSafeAreaView;
    __weak KSImagePickerToolBar *_bottomBar;
}
@dynamic navigationView;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame navigationView:KSImagePickerViewerNavigationView.alloc.init]) {
        UIView *toolBarSafeAreaView = UIView.alloc.init;
        toolBarSafeAreaView.backgroundColor = UIColor.ks_lightBlack;
        [self addSubview:toolBarSafeAreaView];
        _toolBarSafeAreaView = toolBarSafeAreaView;
        
        KSImagePickerToolBar *bottomBar = [[KSImagePickerToolBar alloc] initWithStyle:KSImagePickerToolBarStylePageNumber];
        [toolBarSafeAreaView addSubview:bottomBar];
        _bottomBar = bottomBar;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    UIEdgeInsets safeArea = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeArea = self.safeAreaInsets;
    }
    
    CGFloat viewW = windowWidth;
    CGFloat viewH = 48.0+safeArea.bottom;
    CGFloat viewY = windowHeight-viewH;
    _toolBarSafeAreaView.frame = (CGRect){0.0, viewY, viewW, viewH};
    
    viewY = 0.0;
    viewH = 48.0;
    _bottomBar.frame = (CGRect){0.0, viewY, viewW, viewH};
}

- (void)setFullScreen:(BOOL)fullScreen {
    if (_fullScreen != fullScreen) {
        _fullScreen = fullScreen;
        
        KSImagePickerViewerNavigationView *navigationView = self.navigationView;
        navigationView.hidden = fullScreen;
        CATransition *trans = [CATransition animation];
        trans.duration = 0.3f;
        trans.type = kCATransitionPush;
        trans.subtype = fullScreen ? kCATransitionFromTop : kCATransitionFromBottom;
        [navigationView.layer addAnimation:trans forKey:nil];
        
        trans.subtype = fullScreen ? kCATransitionFromBottom : kCATransitionFromTop;
        _toolBarSafeAreaView.hidden = fullScreen;
        [_toolBarSafeAreaView.layer addAnimation:trans forKey:nil];
    }
}

- (void)setPageString:(NSString *)pageString {
    _bottomBar.pageNumberLabel.text = pageString;
    [self setNeedsLayout];
}

- (NSString *)pageString {
    return _bottomBar.pageNumberLabel.text;
}

- (KSGradientButton *)doneButton {
    return _bottomBar.doneButton;
}

@end
