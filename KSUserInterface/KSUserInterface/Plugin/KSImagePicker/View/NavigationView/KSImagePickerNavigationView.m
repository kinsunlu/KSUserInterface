//
//  KSImagePickerNavigationView.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerNavigationView.h"
#import "KSBoxLayoutButton.h"
#import "UIColor+Hex.h"

@interface _KSImagePickerNavigationTitleView : UIControl

@property (nonatomic) NSString *title;
@property (nonatomic, getter=isIndicatorUp) BOOL indicatorUp;

@end

@implementation _KSImagePickerNavigationTitleView {
    __weak UILabel *_label;
    __weak CALayer *_indicator;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = UILabel.alloc.init;
        label.font = [UIFont systemFontOfSize:18.0];
        label.textColor = UIColor.ks_black;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        _label = label;
        
        CALayer *indicator = CALayer.layer;
        indicator.backgroundColor = UIColor.ks_black.CGColor;
        indicator.mask = CAShapeLayer.layer;
        [self.layer addSublayer:indicator];
        _indicator = indicator;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    _label.frame = (CGRect){CGPointZero, windowSize.width-14.0, windowSize.height};
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    CGSize windowSize = layer.bounds.size;
    CGRect frame = (CGRect){windowSize.width-7.0, (windowSize.height-5.0)*0.5, 7.0, 5.0};
    _indicator.frame = frame;
    CGSize size = frame.size;
    CGFloat windowWidth = size.width;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointZero];
    [path addLineToPoint:(CGPoint){windowWidth, 0.0}];
    [path addLineToPoint:(CGPoint){windowWidth*0.5, size.height}];
    [path closePath];
    ((CAShapeLayer *)_indicator.mask).path = path.CGPath;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat defw = 14.0;
    CGSize r = [_label sizeThatFits:(CGSize){size.width-defw, size.height}];
    r.width += defw;
    return r;
}

- (void)setTitle:(NSString *)title {
    _label.text = title;
}

- (NSString *)title {
    return _label.text;
}

- (void)setIndicatorUp:(BOOL)indicatorUp {
    _indicator.affineTransform = CGAffineTransformMakeRotation(indicatorUp ? M_PI : 0.0);
}

- (BOOL)isIndicatorUp {
    return !CGAffineTransformEqualToTransform(_indicator.affineTransform, CGAffineTransformIdentity);
}

- (void)setTintColor:(UIColor *)tintColor {
    _label.textColor = tintColor;
    _indicator.backgroundColor = tintColor.CGColor;
}

- (UIColor *)tintColor {
    return _label.textColor;
}

@end

@interface _KSImagePickerNavigationCenterView : UIView <KSNavigationCenterViewProtocol>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, weak, readonly) _KSImagePickerNavigationTitleView *button;

@end

@implementation _KSImagePickerNavigationCenterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _KSImagePickerNavigationTitleView *button = _KSImagePickerNavigationTitleView.alloc.init;
        [self addSubview:button];
        _button = button;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGSize size = [_button sizeThatFits:windowSize];
    _button.frame = (CGRect){(windowSize.width-size.width)*0.5, (windowSize.height-size.height)*0.5, size};
}

- (void)setTitle:(NSString *)title {
    _button.title = title;
    [self setNeedsLayout];
}

- (NSString *)title {
    return _button.title;
}

@end

@implementation KSImagePickerNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.centerView = _KSImagePickerNavigationCenterView.alloc.init;
    }
    return self;
}

- (UIControl *)centerButton {
    return ((_KSImagePickerNavigationCenterView *)self.centerView).button;
}

- (void)setIndicatorUp:(BOOL)indicatorUp {
    ((_KSImagePickerNavigationCenterView *)self.centerView).button.indicatorUp = indicatorUp;
}

- (BOOL)isIndicatorUp {
    return ((_KSImagePickerNavigationCenterView *)self.centerView).button.isIndicatorUp;
}

@end
