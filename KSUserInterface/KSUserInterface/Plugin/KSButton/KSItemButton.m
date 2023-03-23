//
//  KSItemButton.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/1.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSItemButton.h"
#import "UIColor+Hex.h"

@implementation KSItemButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = UIImageView.alloc.init;
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        _imageView = imageView;
        
        UILabel *titleLabel = UILabel.alloc.init;
        titleLabel.font = [UIFont systemFontOfSize:12.0];
        titleLabel.textColor = UIColor.ks_lightGray7;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        _imageViewInset = (UIEdgeInsets){0.0, 7.0, 0.0, 7.0};
        _titleLabelInset = (UIEdgeInsets){8.0, 0.0, 0.0, 0.0};
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat centerMargin = MAX(_imageViewInset.bottom, _titleLabelInset.top);
    
    CGFloat viewX = _titleLabelInset.left;
    CGFloat viewH = _titleLabel.font.lineHeight;
    CGFloat viewY = windowHeight-viewH-_titleLabelInset.bottom;
    CGFloat viewW = windowWidth-viewX-_titleLabelInset.right;
    _titleLabel.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    viewX = _imageViewInset.left;
    viewY = _imageViewInset.top;
    viewW = windowWidth-viewX-_imageViewInset.right;
    viewH = _titleLabel.frame.origin.y-centerMargin-viewY;
    _imageView.frame = (CGRect){viewX, viewY, viewW, viewH};
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGFloat margin = MAX(_imageViewInset.bottom, _titleLabelInset.top);
    CGSize imageSize = [_imageView sizeThatFits:size];
    imageSize.width += _imageViewInset.left+_imageViewInset.right;
    imageSize.height += _imageViewInset.top;
    CGSize titleSize = [_titleLabel sizeThatFits:size];
    titleSize.width += _titleLabelInset.left+_titleLabelInset.right;
    titleSize.height += _titleLabelInset.bottom;
    return (CGSize){MAX(imageSize.width, titleSize.width), imageSize.height+margin+titleSize.height};
}

- (void)sizeToFit {
    self.frame = (CGRect){CGPointZero, [self sizeThatFits:(CGSize){MAXFLOAT, MAXFLOAT}]};
}

- (void)setImageViewInset:(UIEdgeInsets)imageViewInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(imageViewInset, _imageViewInset)) {
        _imageViewInset = imageViewInset;
        [self setNeedsLayout];
    }
}

- (void)setTitleLabelInset:(UIEdgeInsets)titleLabelInset {
    if (!UIEdgeInsetsEqualToEdgeInsets(titleLabelInset, _titleLabelInset)) {
        _titleLabelInset = titleLabelInset;
        [self setNeedsLayout];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.5 : 1.0;
}

@end
