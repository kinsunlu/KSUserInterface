//
//  KSGradientButton.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/11/27.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSGradientButton.h"
#import "UIColor+Hex.h"

@implementation KSGradientButton {
    NSMutableDictionary <NSNumber *, NSArray <UIColor *> *> *_colors;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _colors = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   @[UIColor.ks_lightMain, UIColor.ks_main],
                   [NSNumber numberWithInteger:UIControlStateNormal],
                   @[[UIColor.ks_lightMain colorWithAlphaComponent:0.5], [UIColor.ks_main colorWithAlphaComponent:0.5]],
                   [NSNumber numberWithInteger:UIControlStateHighlighted],
                   @[UIColor.ks_lightGray6],
                   [NSNumber numberWithInteger:UIControlStateDisabled], nil];
        self.backgroundColor = UIColor.ks_lightGray6;
        self.titleLabel.font = [UIFont systemFontOfSize:16.0];
        [self setTitleColor:UIColor.ks_white forState:UIControlStateNormal];
        [self setTitleColor:UIColor.ks_lightGray2 forState:UIControlStateDisabled];
        
        CAGradientLayer *gradientLayer = CAGradientLayer.layer;
        [self.layer insertSublayer:gradientLayer atIndex:0];
        _gradientLayer = gradientLayer;
        
        [self bringSubviewToFront:self.imageView];
        
        self.enabled = YES;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    _gradientLayer.frame = layer.bounds;
    if (_roundedCorners) {
        layer.cornerRadius = layer.bounds.size.height*0.5;
    }
}

- (void)setRoundedCorners:(BOOL)roundedCorners {
    _roundedCorners = roundedCorners;
    self.layer.masksToBounds = roundedCorners;
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    NSArray <UIColor *> *colors = [self backgroundColorsForState:self.state] ?: [self backgroundColorsForState:UIControlStateNormal];
    [self _updateLayerColors:colors];
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    NSArray <UIColor *> *colors = [self backgroundColorsForState:self.state] ?: [self backgroundColorsForState:UIControlStateNormal];
    [self _updateLayerColors:colors];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    NSArray <UIColor *> *colors = [self backgroundColorsForState:self.state] ?: [self backgroundColorsForState:UIControlStateNormal];
    [self _updateLayerColors:colors];
}

- (void)setBackgroundColors:(NSArray<UIColor *> *)backgroundColors forState:(UIControlState)state {
    NSNumber *key = [NSNumber numberWithInteger:state];
    if (backgroundColors == nil || backgroundColors.count == 0) {
        [_colors removeObjectForKey:key];
    } else {
        [_colors setObject:backgroundColors forKey:key];
    }
    if (self.state == state) {
        [self _updateLayerColors:backgroundColors];
    }
}

- (NSArray<UIColor *> *)backgroundColorsForState:(UIControlState)state {
    return [_colors objectForKey:[NSNumber numberWithInteger:state]];
}

- (void)_updateLayerColors:(NSArray <UIColor *> *)colors {
    if (colors == nil || colors.count == 0) {
        _gradientLayer.hidden = YES;
        self.backgroundColor = UIColor.ks_black;
        return;
    }
    if (colors.count == 1) {
        _gradientLayer.hidden = YES;
        self.backgroundColor = colors.firstObject;
        return;
    }
    NSMutableArray *k_colors = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [k_colors addObject:(__bridge id)color.CGColor];
    }
    _gradientLayer.colors = k_colors;
    _gradientLayer.hidden = NO;
}

@end
