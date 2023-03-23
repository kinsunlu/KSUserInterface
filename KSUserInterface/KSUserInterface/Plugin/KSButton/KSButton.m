//
//  KSButton.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/10/29.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSButton.h"
#import "UIColor+Hex.h"

@implementation KSButton {
    NSMutableDictionary <NSNumber *, UIColor *> *_colors;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSMutableDictionary <NSNumber *, UIColor *> *colors = [NSMutableDictionary dictionaryWithCapacity:6];
        [colors setObject:UIColor.ks_main forKey:[NSNumber numberWithInteger:UIControlStateNormal]];
        [colors setObject:UIColor.ks_lightMain forKey:[NSNumber numberWithInteger:UIControlStateHighlighted]];
        [colors setObject:UIColor.ks_lightGray2 forKey:[NSNumber numberWithInteger:UIControlStateDisabled]];
        _colors = colors;
        self.enabled = YES;
        [self setTitleColor:UIColor.ks_black forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont systemFontOfSize:15.0];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
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
    UIColor *color = [self backgroundColorForState:self.state];
    if (color != nil) self.backgroundColor = color;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor *color = [self backgroundColorForState:self.state];
    if (color != nil) self.backgroundColor = color;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    UIColor *color = [self backgroundColorForState:self.state];
    if (color != nil) self.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)state {
    if (backgroundColor != nil) {
        [_colors setObject:backgroundColor forKey:[NSNumber numberWithInteger:state]];
    } else {
        [_colors removeObjectForKey:[NSNumber numberWithInteger:state]];
    }
    if (self.state == state)
        self.backgroundColor = backgroundColor;
}

- (UIColor *)backgroundColorForState:(UIControlState)state {
    return [_colors objectForKey:[NSNumber numberWithInteger:state]];
}

@end
