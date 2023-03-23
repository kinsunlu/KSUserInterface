//
//  KSLoadingView.m
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import "KSLoadingView.h"
#import "UIColor+Hex.h"

@interface KSLoadingView () <UIAppearance>

@property (nonatomic, copy) void (^didChangedStatus)(KSLoadingViewStatus);

@end

@implementation KSLoadingView {
    NSMapTable <NSNumber *, NSString *>*_titles;
    NSMapTable <NSNumber *, id>*_images;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _titles = NSMapTable.strongToStrongObjectsMapTable;
        _images = NSMapTable.strongToStrongObjectsMapTable;
        self.backgroundColor = UIColor.ks_background;
        
        UILabel *titleLabel = UILabel.alloc.init;
        titleLabel.font = [UIFont systemFontOfSize:13.0];
        titleLabel.textColor = UIColor.ks_gray;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        
        UIImageView *contentView = UIImageView.alloc.init;
        contentView.contentMode = UIViewContentModeCenter;
        [self addSubview:contentView];
        _imageView = contentView;
        
        UIView <KSLoadingAnimationViewProtocol> *animationView = [[self.class.animationViewClass alloc] init];
        animationView.userInteractionEnabled = NO;
        [self addSubview:animationView];
        _animationView = animationView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    if (_status == KSLoadingViewStatusLoading) {
        CGSize size = [_animationView sizeThatFits:windowSize];
        _animationView.frame = (CGRect){(windowWidth-size.width)*0.5, (windowHeight-size.height)*0.5-26.0, size};
        size = [_titleLabel sizeThatFits:windowSize];
        _titleLabel.frame = (CGRect){(windowWidth-size.width)*0.5, CGRectGetMaxY(_animationView.frame)+20.0, size};
    } else {
        CGSize size = [_imageView sizeThatFits:windowSize];
        _imageView.frame = (CGRect){(windowWidth-size.width)*0.5, (windowHeight-size.height)*0.5-26.0, size};
        size = [_titleLabel sizeThatFits:windowSize];
        _titleLabel.frame = (CGRect){(windowWidth-size.width)*0.5, CGRectGetMaxY(_imageView.frame)+20.0, size};
    }
}

- (void)setStatus:(KSLoadingViewStatus)status {
    if (status == KSLoadingViewStatusNone) {
        [self removeFromSuperview];
    } else {
        _status = status;
        if (status == KSLoadingViewStatusLoading) {
            _imageView.hidden = YES;
            [_animationView startAnimating];
            _animationView.hidden = NO;
        } else {
            _animationView.hidden = YES;
            [_animationView stopAnimating];
            _imageView.image = [self imageForStatus:status];
            _imageView.hidden = NO;
        }
        _titleLabel.text = [self titleForStatus:status];
        [self setNeedsLayout];
    }
}

- (void)setTitle:(NSString *)title forStatus:(KSLoadingViewStatus)status {
    NSNumber *key = [NSNumber numberWithInteger:status];
    if (title == nil) {
        [_titles removeObjectForKey:key];
    } else {
        [_titles setObject:title forKey:key];
    }
    if (_status == status) {
        _titleLabel.text = title;
    }
}

- (NSString *)titleForStatus:(KSLoadingViewStatus)status {
    return [_titles objectForKey:[NSNumber numberWithInteger:status]];
}

- (void)setImage:(UIImage *)image forStatus:(KSLoadingViewStatus)status {
    NSNumber *key = [NSNumber numberWithInteger:status];
    if (image == nil) {
        [_images removeObjectForKey:key];
    } else {
        [_images setObject:image forKey:key];
    }
    if (_status == status) {
        if (status == KSLoadingViewStatusLoading) {
            _imageView.hidden = YES;
            [_animationView startAnimating];
            _animationView.hidden = NO;
        } else {
            _animationView.hidden = YES;
            [_animationView stopAnimating];
            _imageView.image = [self imageForStatus:status];
            _imageView.hidden = NO;
        }
    }
}

- (UIImage *)imageForStatus:(KSLoadingViewStatus)status {
    return [_images objectForKey:[NSNumber numberWithInteger:status]];
}

- (void)dealloc {
    [_animationView stopAnimating];
}

static Class _dn_animationViewClass = nil;

+ (void)setAnimationViewClass:(Class)animationViewClass {
    _dn_animationViewClass = animationViewClass;
}

+ (Class)animationViewClass {
    if (_dn_animationViewClass == nil) {
        _dn_animationViewClass = KSLoadingAnimationNormalView.class;
    }
    return _dn_animationViewClass;
}

@end

@implementation KSLoadingAnimationNormalView {
    __weak UIActivityIndicatorView *_indView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        
        UIActivityIndicatorView *indView = UIActivityIndicatorView.alloc;
        if (@available(iOS 13.0, *)) {
            indView = [indView initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        } else {
            indView = [indView initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        indView.color = UIColor.ks_gray;
        indView.hidesWhenStopped = YES;
        [self addSubview:indView];
        _indView = indView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGSize size = [_indView sizeThatFits:windowSize];
    _indView.frame = (CGRect){(windowSize.width-size.width)*0.5, (windowSize.height-size.height)*0.5, size};
}

- (void)startAnimating {
    [_indView startAnimating];
}

- (void)stopAnimating {
    [_indView stopAnimating];
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [_indView sizeThatFits:size];
}

@end
