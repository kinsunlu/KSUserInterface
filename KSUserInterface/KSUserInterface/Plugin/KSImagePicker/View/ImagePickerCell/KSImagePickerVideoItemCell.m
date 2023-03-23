//
//  KSImagePickerVideoItemCell.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerVideoItemCell.h"
 

@interface _KSIPVideoInfomationView : UIView

@property (nonatomic) NSString *text;

@end

@implementation _KSIPVideoInfomationView {
    __weak CAGradientLayer *_gradientLayer;
    __weak CALayer *_videoIndLayer;
    __weak CATextLayer *_textLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIColor *clearColor = UIColor.clearColor;
        self.backgroundColor = clearColor;
        
        CALayer *layer = self.layer;
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.colors = @[(__bridge id)[UIColor.blackColor colorWithAlphaComponent:0.8f].CGColor, (__bridge id)clearColor.CGColor];
        gradientLayer.startPoint = (CGPoint){0.5f, 1.f};
        gradientLayer.endPoint = (CGPoint){0.5f, 0.f};
        gradientLayer.locations = @[[NSNumber numberWithInteger:0], [NSNumber numberWithInteger:1]];
        [layer addSublayer:gradientLayer];
        _gradientLayer = gradientLayer;
        
        CALayer *videoIndLayer = [CALayer layer];
        videoIndLayer.contents = (id)[UIImage imageNamed:@"KSUserInterface.bundle/icon_ImagePicker_play"].CGImage;
        [layer addSublayer:videoIndLayer];
        _videoIndLayer = videoIndLayer;
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.wrapped = YES;
        textLayer.alignmentMode = kCAAlignmentRight;
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        UIFont *font = [UIFont systemFontOfSize:12.f];
        CFStringRef fontCFString = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontCFString);
        textLayer.font = fontRef;
        CGFontRelease(fontRef);
        textLayer.fontSize = font.pointSize;
        textLayer.foregroundColor = UIColor.whiteColor.CGColor;
        [layer addSublayer:textLayer];
        _textLayer = textLayer;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    CGRect bounds = layer.bounds;
    _gradientLayer.frame = bounds;
    CGSize windowSize = bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat margin = 8.0;
    CGFloat viewW = 12.0;
    CGFloat viewH = viewW;
    CGFloat viewX = margin;
    CGFloat viewY = (windowHeight-viewH)*0.5;
    _videoIndLayer.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    viewX = CGRectGetMaxX(_videoIndLayer.frame);
    viewW = windowWidth-viewX-margin;
    viewH = _textLayer.fontSize;
    viewY = (windowHeight-viewH)*0.5-1.0;
    _textLayer.frame = (CGRect){viewX, viewY, viewW, viewH};
}

- (void)setText:(NSString *)text {
    _textLayer.string = text;
}

- (NSString *)text {
    return _textLayer.string;
}

@end

@implementation KSImagePickerVideoItemCell {
    __weak _KSIPVideoInfomationView *_infoView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *contentView = self.contentView;
        
        _KSIPVideoInfomationView *infoView = [[_KSIPVideoInfomationView alloc] init];
        [contentView addSubview:infoView];
        _infoView = infoView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.contentView.bounds.size;
    CGFloat viewH = 20.0;
    CGFloat viewY = windowSize.height-viewH;
    _infoView.frame = (CGRect){0.0, viewY, windowSize.width, viewH};
}

- (void)setItemModel:(KSImagePickerItemModel *)itemModel {
    [super setItemModel:itemModel];
    NSTimeInterval duration = itemModel.asset.duration;
    _infoView.text = [NSString stringWithFormat:@"%02.0f:%02td", duration/60.f, (NSInteger)duration%60];
}

@end
