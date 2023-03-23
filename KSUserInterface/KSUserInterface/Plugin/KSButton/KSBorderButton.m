//
//  KSBorderButton.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/10/29.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSBorderButton.h"
#import "UIColor+Hex.h"

@implementation KSBorderButton {
    NSMutableDictionary <NSNumber *, UIColor *> *_borderColors;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSMutableDictionary <NSNumber *, UIColor *> *borderColors = [NSMutableDictionary dictionaryWithCapacity:6];
        [borderColors setObject:UIColor.ks_main forKey:[NSNumber numberWithInteger:UIControlStateNormal]];
        [borderColors setObject:UIColor.ks_lightMain forKey:[NSNumber numberWithInteger:UIControlStateHighlighted]];
        [borderColors setObject:UIColor.ks_lightGray2 forKey:[NSNumber numberWithInteger:UIControlStateDisabled]];
        _borderColors = borderColors;
        
        [self setBackgroundColor:UIColor.clearColor forState:UIControlStateNormal];
        [self setBackgroundColor:UIColor.clearColor forState:UIControlStateSelected];
        [self setBackgroundColor:UIColor.clearColor forState:UIControlStateDisabled];
        [self setTitleColor:UIColor.ks_main forState:UIControlStateNormal];
        
        self.layer.borderWidth = 1.0;
        self.enabled = YES;
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    UIColor *color = [self borderColorForState:self.state];
    if (color != nil)
        self.layer.borderColor = color.CGColor;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    UIColor *color = [self borderColorForState:self.state];
    if (color != nil)
        self.layer.borderColor = color.CGColor;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    UIColor *color = [self borderColorForState:self.state];
    if (color != nil)
        self.layer.borderColor = color.CGColor;
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)state {
    if (borderColor != nil) {
        [_borderColors setObject:borderColor forKey:[NSNumber numberWithInteger:state]];
    } else {
        [_borderColors removeObjectForKey:[NSNumber numberWithInteger:state]];
    }
    if (self.state == state)
        self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColorForState:(UIControlState)state {
    return [_borderColors objectForKey:[NSNumber numberWithInteger:state]];
}

@end
