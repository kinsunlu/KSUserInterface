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
    @public __weak UIView *_contentView;
}
@synthesize contentView = _contentView;

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView {
    if (self = [super initWithFrame:frame]) {
        UILabel *badgeLabel = [[UILabel alloc]init];
        badgeLabel.font = [UIFont systemFontOfSize:10.f];
        badgeLabel.textColor = UIColor.ks_white;
        badgeLabel.textAlignment = NSTextAlignmentCenter;
        badgeLabel.layer.masksToBounds = YES;
        badgeLabel.backgroundColor = UIColor.ks_red;
        badgeLabel.hidden = YES;
        [self addSubview:badgeLabel];
        _badgeLabel = badgeLabel;
        
        [self addSubview:contentView];
        _contentView = contentView;
        
        _contentInset = (UIEdgeInsets){7.0, 7.0, 4.0, 7.0};
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    UIEdgeInsets inset = self.contentInset;
    CGFloat x = inset.left;
    CGFloat y = inset.top;
    CGFloat r = inset.right;
    _contentView.frame = (CGRect){x, y, windowWidth-x-r, windowSize.height-y-inset.bottom};
    
    if (_badgeLabel.hidden) return;
    CGFloat viewW;
    CGFloat viewH;
    CGFloat viewX;
    if (_showPointTip) {
        viewW = viewH = 8.0;
        viewX = ceil(windowWidth-viewW-r);
    } else {
        CGSize size = [_badgeLabel sizeThatFits:windowSize];
        viewH = size.height+3.0;
        viewW = MAX(size.width+6.0, viewH);
        viewX = MIN(windowWidth-r-viewW*0.5, windowWidth-viewW);
    }
    _badgeLabel.frame = (CGRect){viewX, y, viewW, viewH};
    _badgeLabel.layer.cornerRadius = viewH*0.5;
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) return;
    _contentInset = contentInset;
    [self setNeedsLayout];
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
    UILabel *titleLabel = UILabel.alloc.init;
    titleLabel.adjustsFontSizeToFitWidth = YES;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    if (self = [super initWithFrame:frame contentView:titleLabel]) {
        _normalFont = [UIFont systemFontOfSize:17.0];
        _selectedTitleColor = UIColor.ks_black;
        _normalTitleColor = UIColor.ks_gray;
        self.selected = NO;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    UILabel *contentView = self.contentView;
    if (selected) {
        contentView.textColor = _selectedTitleColor ?: _normalTitleColor;
        contentView.font = _selectedFont ?: _normalFont;
    } else {
        contentView.textColor = _normalTitleColor;
        contentView.font = _normalFont;
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor ?: _normalTitleColor;
    if (self.selected) {
        self.contentView.textColor = selectedTitleColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    if (!self.selected) {
        self.contentView.textColor = normalTitleColor;
    }
}

- (void)setSelectedFont:(UIFont *)selectedFont {
    _selectedFont = selectedFont ?: _normalFont;
    if (self.selected) {
        self.contentView.font = selectedFont;
    }
}

- (void)setNormalFont:(UIFont *)normalFont {
    _normalFont = normalFont;
    if (!self.selected) {
        self.contentView.font = normalFont;
    }
}

@end

@implementation KSTabBarImageItem

- (instancetype)initWithFrame:(CGRect)frame {
    UIImageView *icon = UIImageView.alloc.init;
    icon.contentMode = UIViewContentModeScaleAspectFit;
    return [super initWithFrame:frame contentView:icon];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.image = selected ? (_selectedImage ?: _normalImage) : _normalImage;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage ?: _normalImage;
    if (self.isSelected) {
        self.contentView.image = selectedImage;
    }
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    if (!self.isSelected) {
        self.contentView.image = normalImage;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.contentView.tintColor = tintColor;
}

@end

@interface _KSTabBarSystemContentView : UIView

@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, weak, readonly) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat margin;

@end

@implementation _KSTabBarSystemContentView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _margin = 6.0;
        
        UIImageView *imageView = UIImageView.alloc.init;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:imageView];
        _imageView = imageView;
        
        UILabel *titleLabel = UILabel.alloc.init;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        self.backgroundColor = UIColor.clearColor;
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat labelH = ceil([_titleLabel sizeThatFits:windowSize].height);
    _titleLabel.frame = (CGRect){0.0, windowSize.height-labelH, windowWidth, labelH};
    _imageView.frame = (CGRect){0.0, 0.0, windowWidth, CGRectGetMinY(_titleLabel.frame)-_margin};
}

- (void)setMargin:(CGFloat)margin {
    if (_margin == margin) return;
    _margin = margin;
    [self setNeedsLayout];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    _imageView.tintColor = tintColor;
    _titleLabel.tintColor = tintColor;
}

@end

@implementation KSTabBarSystemItem

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame contentView:_KSTabBarSystemContentView.alloc.init]) {
        _normalFont = [UIFont systemFontOfSize:10.0];
        _selectedTitleColor = UIColor.ks_main;
        _normalTitleColor = UIColor.ks_lightGray1;
        self.selected = NO;
    }
    return self;
}

- (void)setMargin:(CGFloat)margin {
    ((_KSTabBarSystemContentView*)_contentView).margin = margin;
}

- (CGFloat)margin {
    return ((_KSTabBarSystemContentView*)_contentView).margin;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _KSTabBarSystemContentView *contentView = (_KSTabBarSystemContentView*)_contentView;
    UILabel *titleLabel = contentView.titleLabel;
    if (selected) {
        contentView.imageView.image = _selectedImage ?: _normalImage;
        titleLabel.textColor = _selectedTitleColor ?: _normalTitleColor;
        titleLabel.font = _selectedFont ?: _normalFont;
    } else {
        contentView.imageView.image = _normalImage;
        titleLabel.textColor = _normalTitleColor;
        titleLabel.font = _normalFont;
    }
}

- (void)setSelectedTitleColor:(UIColor *)selectedTitleColor {
    _selectedTitleColor = selectedTitleColor ?: _normalTitleColor;
    if (self.selected) {
        ((_KSTabBarSystemContentView*)_contentView).titleLabel.textColor = selectedTitleColor;
    }
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor {
    _normalTitleColor = normalTitleColor;
    if (!self.selected) {
        ((_KSTabBarSystemContentView*)_contentView).titleLabel.textColor = normalTitleColor;
    }
}

- (void)setSelectedFont:(UIFont *)selectedFont {
    _selectedFont = selectedFont ?: _normalFont;
    if (self.selected) {
        ((_KSTabBarSystemContentView*)_contentView).titleLabel.font = selectedFont;
    }
}

- (void)setNormalFont:(UIFont *)normalFont {
    _normalFont = normalFont;
    if (!self.selected) {
        ((_KSTabBarSystemContentView*)_contentView).titleLabel.font = normalFont;
    }
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    _selectedImage = selectedImage ?: _normalImage;
    if (self.isSelected) {
        ((_KSTabBarSystemContentView*)_contentView).imageView.image = selectedImage;
    }
}

- (void)setNormalImage:(UIImage *)normalImage {
    _normalImage = normalImage;
    if (!self.isSelected) {
        ((_KSTabBarSystemContentView*)_contentView).imageView.image = normalImage;
    }
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    _contentView.tintColor = tintColor;
}

- (UIImageView *)imageView {
    return ((_KSTabBarSystemContentView*)_contentView).imageView;
}

- (UILabel *)titleLabel {
    return ((_KSTabBarSystemContentView*)_contentView).titleLabel;
}

@end

