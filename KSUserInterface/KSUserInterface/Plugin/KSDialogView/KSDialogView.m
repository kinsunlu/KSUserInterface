//
//  KSDialogView.m
//  KSUserInterface
//
//  Created by Kinsun on 2021/2/17.
//  Copyright © 2021年 Kinsun. All rights reserved.
//

#import "KSDialogView.h"
#import "UIColor+Hex.h"

@implementation KSDialogView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame direction:KSDialogViewIndicatorDirectionTop];
}

- (instancetype)initWithDirection:(KSDialogViewIndicatorDirection)direction {
    return [self initWithFrame:CGRectZero direction:direction];
}

- (instancetype)initWithFrame:(CGRect)frame direction:(KSDialogViewIndicatorDirection)direction {
    if (self = [super initWithFrame:frame]) {
        _direction = direction;
        self.layer.mask = CAShapeLayer.layer;
        _indicatorSize = (CGSize){14.0, 7.0};
        _indicatorFocalPoint = 16.0;
        _cornerRadius = 8.0;
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat indicatorHeight = _indicatorSize.height;
    CGFloat viewX, viewW, viewY, viewH;
    switch (_direction) {
        case KSDialogViewIndicatorDirectionTop:
            viewX = _contentInset.left;
            viewW = windowWidth-_contentInset.right-viewX;
            viewY = _contentInset.top+indicatorHeight;
            viewH = windowHeight-_contentInset.bottom-viewY;
            break;
        case KSDialogViewIndicatorDirectionBottom:
            viewX = _contentInset.left;
            viewW = windowWidth-_contentInset.right-viewX;
            viewY = _contentInset.top;
            viewH = windowHeight-_contentInset.bottom-viewY-indicatorHeight;
            break;
        case KSDialogViewIndicatorDirectionLeft:
            viewY = _contentInset.top;
            viewH = windowHeight-_contentInset.bottom-viewY;
            viewX = indicatorHeight+_contentInset.left;
            viewW = windowWidth-_contentInset.right-viewX;
            break;
        case KSDialogViewIndicatorDirectionRight:
            viewY = _contentInset.top;
            viewH = windowHeight-_contentInset.bottom-viewY;
            viewX = _contentInset.left;
            viewW = windowWidth-_contentInset.right-viewX-indicatorHeight;
            break;
    }
    _contentView.frame = (CGRect){viewX, viewY, viewW, viewH};
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    layer.mask.frame = layer.bounds;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGFloat indicatorWidth = _indicatorSize.width;
    CGFloat indicatorHeight = _indicatorSize.height;
    CGSize windowSize = rect.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat pi = M_PI;
    
    UIBezierPath *path = UIBezierPath.bezierPath;
    path.lineJoinStyle = kCGLineJoinRound;
    switch (_direction) {
        case KSDialogViewIndicatorDirectionTop:
            [path moveToPoint:(CGPoint){_indicatorFocalPoint, 0.0}];
            [path addLineToPoint:(CGPoint){_indicatorFocalPoint+indicatorWidth*0.5, indicatorHeight}];
            [path addArcWithCenter:(CGPoint){windowWidth-_cornerRadius, indicatorHeight+_cornerRadius} radius:_cornerRadius startAngle:-(pi*0.5) endAngle:0.0 clockwise:YES];
            [path addArcWithCenter:(CGPoint){windowWidth-_cornerRadius, windowHeight-_cornerRadius} radius:_cornerRadius startAngle:0.0 endAngle:pi*0.5 clockwise:YES];
            [path addArcWithCenter:(CGPoint){_cornerRadius, windowHeight-_cornerRadius} radius:_cornerRadius startAngle:pi*0.5 endAngle:pi clockwise:YES];
            [path addArcWithCenter:(CGPoint){_cornerRadius, indicatorHeight+_cornerRadius} radius:_cornerRadius startAngle:pi endAngle:-(pi*0.5) clockwise:YES];
            [path addLineToPoint:(CGPoint){_indicatorFocalPoint-indicatorWidth*0.5, indicatorHeight}];
            break;
        case KSDialogViewIndicatorDirectionBottom:
            [path moveToPoint:(CGPoint){_indicatorFocalPoint, windowHeight}];
            [path addLineToPoint:(CGPoint){_indicatorFocalPoint+indicatorWidth*0.5, windowHeight-indicatorHeight}];
            [path addArcWithCenter:(CGPoint){windowWidth-_cornerRadius, windowHeight-indicatorHeight-_cornerRadius} radius:_cornerRadius startAngle:pi*0.5 endAngle:0.0 clockwise:NO];
            [path addArcWithCenter:(CGPoint){windowWidth-_cornerRadius, _cornerRadius} radius:_cornerRadius startAngle:0.0 endAngle:-(pi*0.5) clockwise:NO];
            [path addArcWithCenter:(CGPoint){_cornerRadius, _cornerRadius} radius:_cornerRadius startAngle:-(pi*0.5) endAngle:pi clockwise:NO];
            [path addArcWithCenter:(CGPoint){_cornerRadius, windowHeight-indicatorHeight-_cornerRadius} radius:_cornerRadius startAngle:pi endAngle:pi*0.5 clockwise:NO];
            [path addLineToPoint:(CGPoint){_indicatorFocalPoint-indicatorWidth*0.5, windowHeight-indicatorHeight}];
            break;
        case KSDialogViewIndicatorDirectionLeft:
            [path moveToPoint:(CGPoint){0.0, _indicatorFocalPoint}];
            [path addLineToPoint:(CGPoint){indicatorHeight, _indicatorFocalPoint+indicatorWidth*0.5}];
            [path addArcWithCenter:(CGPoint){indicatorHeight+_cornerRadius, windowHeight-_cornerRadius} radius:_cornerRadius startAngle:pi endAngle:pi*0.5 clockwise:NO];
            [path addArcWithCenter:(CGPoint){windowWidth-_cornerRadius, windowHeight-_cornerRadius} radius:_cornerRadius startAngle:pi*0.5 endAngle:0.0 clockwise:NO];
            [path addArcWithCenter:(CGPoint){windowWidth-_cornerRadius, _cornerRadius} radius:_cornerRadius startAngle:0.0 endAngle:-(pi*0.5) clockwise:NO];
            [path addArcWithCenter:(CGPoint){indicatorHeight+_cornerRadius, _cornerRadius} radius:_cornerRadius startAngle:-(pi*0.5) endAngle:pi clockwise:NO];
            [path addLineToPoint:(CGPoint){indicatorHeight, _indicatorFocalPoint-indicatorWidth*0.5}];
            break;
        case KSDialogViewIndicatorDirectionRight:
            [path moveToPoint:(CGPoint){windowWidth, _indicatorFocalPoint}];
            [path addLineToPoint:(CGPoint){windowWidth-indicatorHeight, _indicatorFocalPoint+indicatorWidth*0.5}];
            [path addArcWithCenter:(CGPoint){windowWidth-indicatorHeight-_cornerRadius, windowHeight-_cornerRadius} radius:_cornerRadius startAngle:0.0 endAngle:pi*0.5 clockwise:YES];
            [path addArcWithCenter:(CGPoint){_cornerRadius, windowHeight-_cornerRadius} radius:_cornerRadius startAngle:pi*0.5 endAngle:pi clockwise:YES];
            [path addArcWithCenter:(CGPoint){_cornerRadius, _cornerRadius} radius:_cornerRadius startAngle:pi endAngle:-(pi*0.5) clockwise:YES];
            [path addArcWithCenter:(CGPoint){windowWidth-indicatorHeight-_cornerRadius, _cornerRadius} radius:_cornerRadius startAngle:-(pi*0.5) endAngle:0.0 clockwise:YES];
            [path addLineToPoint:(CGPoint){windowWidth-indicatorHeight, _indicatorFocalPoint-indicatorWidth*0.5}];
            break;
    }
    [path closePath];
    ((CAShapeLayer *)self.layer.mask).path = path.CGPath;
}

- (void)setIndicatorSize:(CGSize)indicatorSize {
    _indicatorSize = indicatorSize;
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setIndicatorFocalPoint:(CGFloat)indicatorFocalPoint {
    _indicatorFocalPoint = indicatorFocalPoint;
    [self setNeedsDisplay];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self setNeedsDisplay];
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)setContentView:(__kindof UIView *)contentView {
    if (_contentView != nil) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    if (contentView != nil) {
        [self addSubview:contentView];
    }
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat defw = _contentInset.right+_contentInset.left;
    CGFloat defh = _contentInset.top+_contentInset.bottom;
    switch (_direction) {
        case KSDialogViewIndicatorDirectionTop:
        case KSDialogViewIndicatorDirectionBottom:
            defh += _indicatorSize.height;
            break;
        case KSDialogViewIndicatorDirectionLeft:
        case KSDialogViewIndicatorDirectionRight:
            defw += _indicatorSize.height;
            break;
    }
    CGSize r = [_contentView sizeThatFits:(CGSize){size.width-defw, size.height-defh}];
    r.width += defw;
    r.height += defh;
    return r;
}

@end
