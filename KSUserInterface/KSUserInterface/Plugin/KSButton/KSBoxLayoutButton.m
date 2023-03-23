//
//  KSBoxLayoutButton.m
//  KSUserInterface
//
//  Created by Kinsun on 2021/1/11.
//

#import "KSBoxLayoutButton.h"

@implementation KSBoxLayoutButton

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _contentInset = UIEdgeInsetsZero;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize size = self.bounds.size;
    CGFloat windowHeight = size.height;
    CGFloat x = _contentInset.left;
    CGFloat y = _contentInset.top;
    _contentView.frame = (CGRect){x, y, size.width-x-_contentInset.right, windowHeight-y-_contentInset.bottom};
    if (_roundedCorners) {
        CALayer *layer = self.layer;
        layer.cornerRadius = windowHeight*0.5;
    }
}

- (void)setRoundedCorners:(BOOL)roundedCorners {
    _roundedCorners = roundedCorners;
    self.layer.masksToBounds = roundedCorners;
    [self setNeedsLayout];
}

- (void)setContentView:(UIView *)contentView {
    if (_contentView != nil) {
        [_contentView removeFromSuperview];
    }
    _contentView = contentView;
    if (contentView != nil) {
        [self addSubview:contentView];
        [self setNeedsLayout];
    }
}

- (void)setContentInset:(UIEdgeInsets)contentInset {
    if (UIEdgeInsetsEqualToEdgeInsets(_contentInset, contentInset)) return;
    _contentInset = contentInset;
    [self setNeedsLayout];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    self.alpha = enabled ? 1.0 : 0.5;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.5 : 1.0;
}

- (CGSize)sizeThatFits:(CGSize)size {
    CGSize r = [_contentView sizeThatFits:size];
    r.width += _contentInset.left+_contentInset.right;
    r.height += _contentInset.top+_contentInset.bottom;
    return r;
}

- (void)sizeToFit {
    self.frame = (CGRect){CGPointZero, [self sizeThatFits:(CGSize){MAXFLOAT, MAXFLOAT}]};
}

@end

#import "UIColor+Hex.h"

@implementation KSImageButton
@dynamic contentView;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = UIImageView.alloc.init;
        imageView.tintColor = UIColor.ks_main;
        imageView.contentMode = UIViewContentModeCenter;
        self.contentView = imageView;
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.contentView.highlighted = selected;
}

- (void)setNormalImage:(UIImage *)normalImage {
    self.contentView.image = normalImage;
}

- (UIImage *)normalImage {
    return self.contentView.image;
}

- (void)setSelectedImage:(UIImage *)selectedImage {
    self.contentView.highlightedImage = selectedImage;
}

- (UIImage *)selectedImage {
    return self.contentView.highlightedImage;
}

@end

@implementation KSTextButton
@dynamic contentView;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UILabel *label = UILabel.alloc.init;
        label.textAlignment = NSTextAlignmentCenter;
        self.contentView = label;
    }
    return self;
}

- (void)setNormalTitle:(NSString *)normalTitle {
    _normalTitle = normalTitle.copy;
    if (!self.isSelected) {
        self.contentView.text = _normalTitle;
    }
}

- (void)setSelectedTitle:(NSString *)selectedTitle {
    _selectedTitle = selectedTitle.copy;
    if (self.isSelected) {
        self.contentView.text = _selectedTitle;
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (_normalTitle == nil) { return; }
    if (_selectedTitle == nil) {
        self.contentView.text = _normalTitle;
    } else {
        self.contentView.text = selected ? _selectedTitle : _normalTitle;
    }
}

@end
