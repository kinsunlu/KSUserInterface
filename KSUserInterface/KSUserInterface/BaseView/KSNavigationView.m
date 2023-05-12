//
//  KSNavigationView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSNavigationView.h"
#import "UIColor+Hex.h"
#import "KSUITools.h"

@interface _KSNavigationTitleLabel : UILabel <KSNavigationCenterViewProtocol>

@end

@implementation _KSNavigationTitleLabel
@synthesize style = _style;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.font = [UIFont boldSystemFontOfSize:18.0];
        self.textAlignment = NSTextAlignmentCenter;
//        self.lineBreakMode = NSLineBreakByTruncatingMiddle;
        self.adjustsFontSizeToFitWidth = YES;
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.text = title;
}

- (NSString *)title {
    return self.text;
}

- (void)setTitleColor:(UIColor *)titleColor {
    self.textColor = titleColor;
}

- (UIColor *)titleColor {
    return self.textColor;
}

@end

@implementation KSNavigationView {
    NSMutableDictionary <NSNumber*, UIColor*> *_backgroundColors;
    NSMutableDictionary <NSNumber*, UIColor*> *_lineColors;
    NSMutableDictionary <NSNumber*, UIColor*> *_titleColors;
    NSMutableArray <UIView *> *_leftViews;
    NSMutableArray <UIView *> *_rightViews;
    __weak CALayer *_lineLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _backgroundColors = [NSMutableDictionary dictionaryWithObjectsAndKeys:UIColor.ks_white, @(KSNavigationViewStyleLight), [UIColor colorWithHex:0x000000 alpha:0.8], @(KSNavigationViewStyleDark), UIColor.clearColor, @(KSNavigationViewStyleClear), nil];
        _lineColors = [NSMutableDictionary dictionaryWithObjectsAndKeys:UIColor.ks_lightGray, @(KSNavigationViewStyleLight), UIColor.ks_lightBlack, @(KSNavigationViewStyleDark), UIColor.clearColor, @(KSNavigationViewStyleClear), nil];
        _titleColors = [NSMutableDictionary dictionaryWithObjectsAndKeys:UIColor.ks_title, @(KSNavigationViewStyleLight), UIColor.ks_white, @(KSNavigationViewStyleDark), UIColor.ks_main, @(KSNavigationViewStyleClear), nil];
        _leftViews = NSMutableArray.array;
        _rightViews = NSMutableArray.array;
        _KSNavigationTitleLabel *titleLabel = _KSNavigationTitleLabel.alloc.init;
        [self addSubview:titleLabel];
        _centerView = titleLabel;
        
        CALayer *lineLayer = CALayer.layer;
        [self.layer addSublayer:lineLayer];
        _lineLayer = lineLayer;
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf setStyle:weakSelf.style];
        });
    }
    return self;
}

- (void)setStyle:(KSNavigationViewStyle)style {
    _style = style;
    self.backgroundColor = [self backgroundColorForStyle:style];
    _lineLayer.backgroundColor = [self lineColorForStyle:style].CGColor;
    if (_centerView == nil) return;
    if ([_centerView respondsToSelector:@selector(setTitle:)]) {
        _centerView.titleColor = [self titleColorForStyle:style];
    }
    if ([_centerView respondsToSelector:@selector(setStyle:)]) {
        _centerView.style = style;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forStyle:(KSNavigationViewStyle)style {
    if (backgroundColor == nil) {
        [_backgroundColors removeObjectForKey:@(style)];
    } else {
        [_backgroundColors setObject:backgroundColor forKey:@(style)];
    }
    if (_style == style) {
        self.backgroundColor = backgroundColor;
    }
}

- (UIColor *)backgroundColorForStyle:(KSNavigationViewStyle)style {
    return [_backgroundColors objectForKey:@(style)];
}

- (void)setLineColor:(UIColor *)lineColor forStyle:(KSNavigationViewStyle)style {
    if (lineColor == nil) {
        [_lineColors removeObjectForKey:@(style)];
    } else {
        [_lineColors setObject:lineColor forKey:@(style)];
    }
    if (_style == style) {
        _lineLayer.backgroundColor = lineColor.CGColor;
    }
}

- (UIColor *)lineColorForStyle:(KSNavigationViewStyle)style {
    return [_lineColors objectForKey:@(style)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat minY = _statusBarHeight;
    CGFloat maxH = windowHeight-minY;
    
    CGFloat viewY = minY;
    CGFloat viewH = maxH;
    CGFloat viewX = 0.0;
    CGFloat viewW = 0.0;
    CGFloat lastX = 15.0;
    for (UIView *view in _leftViews) {
        if (view.isHidden || view.alpha <= 0.0) continue;
        CGSize size = [view sizeThatFits:windowSize];
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = view.bounds.size;
        }
        view.frame = (CGRect){viewX, (maxH-size.height)*0.5+minY, size};
        viewX = CGRectGetMaxX(view.frame);
        lastX = viewX;
    }
    viewX = windowWidth;
    CGFloat lastMaxX = windowWidth-15.0;
    for (UIView *view in _rightViews) {
        if (view.isHidden || view.alpha <= 0.0) continue;
        CGSize size = [view sizeThatFits:windowSize];
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size = view.bounds.size;
        }
        viewX = viewX-size.width;
        view.frame = (CGRect){viewX, (maxH-size.height)*0.5+minY, size};
        lastMaxX = viewX;
    }
    
    if (_centerView != nil) {
        CGFloat isInCenterX = MAX(lastX, windowWidth-lastMaxX);
        CGFloat maxW = lastMaxX-lastX;
        CGSize centerViewSize = [_centerView sizeThatFits:(CGSize){maxW, maxH}];
        CGFloat centerViewW = MIN(maxW, ceil(centerViewSize.width));
        CGFloat centerViewH = MIN(maxH, ceil(centerViewSize.height));
        viewX = (windowWidth-centerViewW)*0.5;
        if (viewX < isInCenterX) {
            viewX = (maxW-centerViewW)*0.5+lastX;
        }
        _centerView.frame = (CGRect){viewX, (maxH-centerViewH)*0.5+minY, centerViewW, centerViewH};
    }
    
    viewX = 0.0;
    viewH = 0.5;
    viewW = windowWidth;
    viewY = windowHeight-viewH;
    _lineLayer.frame = (CGRect){viewX, viewY, viewW, viewH};
}

- (void)setTitle:(NSString *)title {
    if (_centerView != nil && [_centerView respondsToSelector:@selector(setTitle:)]) {
        _centerView.title = title;
        [self setNeedsLayout];
    }
}

- (NSString *)title {
    if (_centerView != nil && [_centerView respondsToSelector:@selector(title)]) {
        return _centerView.title;
    }
    return nil;
}

- (void)setTitleColor:(UIColor *)titleColor forStyle:(KSNavigationViewStyle)style {
    if (titleColor == nil) {
        [_titleColors removeObjectForKey:@(style)];
    } else {
        [_titleColors setObject:titleColor forKey:@(style)];
    }
    if (_style == style && _centerView != nil && [_centerView respondsToSelector:@selector(setTitle:)]) {
        _centerView.titleColor = titleColor;
    }
}

- (UIColor *)titleColorForStyle:(KSNavigationViewStyle)style {
    return [_titleColors objectForKey:@(style)];
}

- (void)setCenterView:(UIView<KSNavigationCenterViewProtocol> *)centerView {
    if (_centerView != nil)
        [_centerView removeFromSuperview];
    if (centerView != nil) {
        [self addSubview:centerView];
        _centerView = centerView;
    }
}

- (NSArray<UIView *> *)leftViews {
    return _leftViews.copy;
}

- (NSArray<UIView *> *)rightViews {
    return _rightViews.copy;
}

- (void)addLeftView:(UIView *)leftView {
    [_leftViews addObject:leftView];
    [self addSubview:leftView];
}

- (void)removeLeftView:(UIView *)leftView {
    [_leftViews removeObject:leftView];
    [leftView removeFromSuperview];
    [self setNeedsLayout];
}

- (void)addRightView:(UIView *)rightView {
    [_rightViews addObject:rightView];
    [self addSubview:rightView];
}

- (void)removeRightView:(UIView *)rightView {
    [_rightViews removeObject:rightView];
    [rightView removeFromSuperview];
    [self setNeedsLayout];
}

- (void)setHiddenLine:(BOOL)hiddenLine {
    _lineLayer.hidden = hiddenLine;
}

- (BOOL)isHiddenLine {
    return _lineLayer.isHidden;
}

@end

#import "KSBoxLayoutButton.h"

@implementation KSSecondaryNavigationView {
    NSMutableDictionary <NSNumber*, UIColor*> *_backButtonColors;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _backButtonColors = [NSMutableDictionary dictionaryWithObjectsAndKeys:UIColor.ks_title, @(KSNavigationViewStyleLight), UIColor.ks_white, @(KSNavigationViewStyleDark), UIColor.ks_main, @(KSNavigationViewStyleClear), nil];
        KSImageButton *leftBtn = KSImageButton.alloc.init;
        leftBtn.contentInset = (UIEdgeInsets){12.0, 15.0, 12.0, 15.0};
        UIImage *image = [UIImage imageNamed:@"KSUserInterface.bundle/icon_navigation_back"];
        leftBtn.normalImage = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [self addLeftView:leftBtn];
        _backButton = leftBtn;
    }
    return self;
}

- (void)setStyle:(KSNavigationViewStyle)style {
    [super setStyle:style];
    KSImageButton *backButton = (KSImageButton *)_backButton;
    if ([backButton isKindOfClass:KSImageButton.class]) {
        backButton.contentView.tintColor = [self backButtonColorForStyle:style];
    }
}

- (void)setBackButtonColor:(UIColor *)backButtonColor forStyle:(KSNavigationViewStyle)style {
    if (backButtonColor == nil) {
        [_backButtonColors removeObjectForKey:@(style)];
    } else {
        [_backButtonColors setObject:backButtonColor forKey:@(style)];
    }
    KSImageButton *backButton = (KSImageButton *)_backButton;
    if (self.style == style && [backButton isKindOfClass:KSImageButton.class]) {
        backButton.contentView.tintColor = backButtonColor;
    }
}

- (UIColor *)backButtonColorForStyle:(KSNavigationViewStyle)style {
    return [_backButtonColors objectForKey:@(style)];
}

@end
