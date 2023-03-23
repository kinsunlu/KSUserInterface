//
//  KSTabBarItem.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSTabBarItem.h"
#import "UIColor+Hex.h"

@implementation KSTabBarItem {
    @public __weak UILabel *_badgeLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = NO;
        UILabel *badgeLabel = [[UILabel alloc]init];
        badgeLabel.font = [UIFont systemFontOfSize:10.f];
        badgeLabel.textColor = UIColor.ks_white;
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.layer.masksToBounds = YES;
        badgeLabel.backgroundColor = UIColor.ks_red;
        badgeLabel.hidden = YES;
        [self addSubview:badgeLabel];
        _badgeLabel = badgeLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!_badgeLabel.hidden) {
        CGSize windowSize = self.bounds.size;
        CGFloat windowWidth = windowSize.width;
        CGFloat viewX = 0.0;
        CGFloat viewY = 0.0;
        CGFloat viewW = 0.0;
        CGFloat viewH = 0.0;
        if (_showPointTip) {
            viewW = viewH = 8.0;
            viewX = ceil(windowWidth/3.0*2.0-3.0);
        } else {
            CGFloat magin = 3.0;
            CGSize size = [_badgeLabel sizeThatFits:windowSize];
            viewW = size.width+magin*2.0;
            viewH = size.height+magin;
            viewW = MAX(viewW, viewH);
            viewX = windowWidth*0.5+3.0;
            viewY = -5.5;
        }
        _badgeLabel.frame = (CGRect){viewX, viewY, viewW, viewH};
        _badgeLabel.layer.cornerRadius = viewH*0.5;
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.7f : 1.f;
}

- (void)setBadgeString:(NSString *)badgeString {
    _badgeString = badgeString;
    if (badgeString != nil && badgeString.length > 0) {
        _badgeLabel.text = badgeString;
        _badgeLabel.hidden = NO;
    } else {
        _badgeLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

- (void)setShowPointTip:(BOOL)showPointTip {
    _showPointTip = showPointTip;
    if (showPointTip) {
        _badgeLabel.text = nil;
        _badgeLabel.hidden = NO;
    } else {
        _badgeLabel.hidden = YES;
    }
    [self setNeedsLayout];
}

@end

@implementation KSTabBarLabelItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedFont = [UIFont systemFontOfSize:19.f];
        _normalFont = [UIFont systemFontOfSize:17.f];
        _selectedTitleColor = UIColor.ks_black;
        _normalTitleColor = UIColor.ks_gray;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        [self insertSubview:titleLabel belowSubview:_badgeLabel];
        _titleLabel = titleLabel;
        
        self.selected = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = self.bounds;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        _titleLabel.textColor = _selectedTitleColor;
        _titleLabel.font = _selectedFont;
    } else {
        _titleLabel.textColor = _normalTitleColor;
        _titleLabel.font = _normalFont;
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    if (self.selected) {
        _titleLabel.textColor = selectedTitleColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    if (!self.selected) {
        _titleLabel.textColor = normalTitleColor;
    }
}

- (void)setSelectedFont:(UIFont *)selectedFont {
    _selectedFont = selectedFont;
    if (self.selected) {
        _titleLabel.font = selectedFont;
    }
}

- (void)setNormalFont:(UIFont *)normalFont {
    _normalFont = normalFont;
    if (!self.selected) {
        _titleLabel.font = normalFont;
    }
}

@end

@implementation KSTabBarImageItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *icon = [[UIImageView alloc]init];
        icon.contentMode = UIViewContentModeScaleAspectFit;
        
        CALayer *layer = icon.layer;
        layer.masksToBounds = YES;
        layer.borderColor = UIColor.ks_gray.CGColor;
        [self insertSubview:icon belowSubview:_badgeLabel];
        _icon = icon;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIImageView *icon = _icon;
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat viewX = 0.0;
    CGFloat viewY = 4.0;
    CGFloat viewW = windowWidth;
    CGFloat viewH = windowHeight-viewY*2.0;
    icon.frame = (CGRect){viewX, viewY, viewW, viewH};
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _icon.image = selected ? _selectedImage : _normalImage;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage;
    if (self.isSelected) {
        _icon.image = selectedImage;
    }
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    if (!self.isSelected) {
        _icon.image = normalImage;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    _icon.tintColor = tintColor;
}

@end

@implementation KSTabBarSystemItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _selectedTitleColor = UIColor.ks_main;
        _normalTitleColor = UIColor.ks_lightGray1;
        self.icon.contentMode = UIViewContentModeCenter;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:10.0];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = _normalTitleColor;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    
    CGFloat viewX = 0.0;
    CGFloat viewY = 0.0;
    CGFloat viewW = 0.0;
    CGFloat viewH = 0.0;
    
    viewW = viewH = windowHeight*0.65;
    viewX = (windowWidth-viewW)*0.5;
    UIImageView *icon = self.icon;
    icon.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    viewX = 7.0;
    viewY = CGRectGetMaxY(icon.frame);
    viewW = windowWidth-viewX*2.0;
    viewH = windowHeight-viewY;
    _titleLabel.frame = (CGRect){viewX, viewY, viewW, viewH};;
}


- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _titleLabel.textColor = selected ? _selectedTitleColor : _normalTitleColor;
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor;
    if (self.isSelected) {
        _titleLabel.textColor = selectedTitleColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    if (!self.isSelected) {
        _titleLabel.textColor = normalTitleColor;
    }
}

@end

