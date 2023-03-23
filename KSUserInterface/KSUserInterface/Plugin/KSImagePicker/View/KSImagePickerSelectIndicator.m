//
//  KSImagePickerSelectIndicator.m
//  KSUserInterface
//
//  Created by Kinsun on 2019/1/7.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerSelectIndicator.h"
 

@implementation KSImagePickerSelectIndicator {
    __weak CALayer *_normalLayer;
    __weak CATextLayer *_textLayer;
    __weak CALayer *_selectLayer;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _multipleSelected = YES;
        
        CALayer *layer = self.layer;
        CGColorRef color = UIColor.whiteColor.CGColor;
        
        CALayer *normalLayer = [CALayer layer];
        normalLayer.backgroundColor = UIColor.blackColor.CGColor;
        normalLayer.borderColor = color;
        normalLayer.borderWidth = 1.f;
        normalLayer.masksToBounds = YES;
        normalLayer.contents = (id)[UIImage imageNamed:@"KSUserInterface.bundle/icon_ImagePicker_Selected"].CGImage;
        normalLayer.opacity = 0.5f;
        [layer addSublayer:normalLayer];
        _normalLayer = normalLayer;
        
        CALayer *selectLayer = [CALayer layer];
        selectLayer.backgroundColor = UIColor.redColor.CGColor;
        selectLayer.borderColor = color;
        selectLayer.borderWidth = 1.f;
        selectLayer.masksToBounds = YES;
        selectLayer.hidden = YES;
        [layer addSublayer:selectLayer];
        _selectLayer = selectLayer;
        
        CATextLayer *textLayer = [CATextLayer layer];
        textLayer.wrapped = YES;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.contentsScale = UIScreen.mainScreen.scale;
        UIFont *font = [UIFont systemFontOfSize:12.f];
        CFStringRef fontCFString = (__bridge CFStringRef)font.fontName;
        CGFontRef fontRef = CGFontCreateWithFontName(fontCFString);
        textLayer.font = fontRef;
        textLayer.fontSize = font.pointSize;
        CGFontRelease(fontRef);
        textLayer.foregroundColor = color;
        [selectLayer addSublayer:textLayer];
        _textLayer = textLayer;
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer {
    [super layoutSublayersOfLayer:layer];
    CGSize windowSize = layer.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat viewW = 22.0;
    CGFloat viewH = viewW;
    CGFloat viewX = (windowWidth-viewW)*0.5;
    CGFloat viewY = (windowHeight-viewH)*0.5;
    CGRect frame = (CGRect){viewX, viewY, viewW, viewH};
    _normalLayer.frame = frame;
    _selectLayer.frame = frame;
    CGFloat cornerRadius = viewW*0.5f;
    _normalLayer.cornerRadius = cornerRadius;
    _selectLayer.cornerRadius = cornerRadius;
    
    if (_multipleSelected) {
        viewH = _textLayer.fontSize;
        viewX = 0.0;
        viewY = (22.0-viewH)*0.5-1.0;
        _textLayer.frame = (CGRect){viewX, viewY, viewW, viewH};
    }
}

- (void)setIndex:(NSUInteger)index {
    _index = index;
    BOOL isSelected = index > 0;
    if (_multipleSelected && isSelected) {
        _textLayer.string = [NSNumber numberWithUnsignedInteger:index].stringValue;
    }
    _selectLayer.hidden = !isSelected;
    _normalLayer.hidden = isSelected;
}

- (void)setMultipleSelected:(BOOL)multipleSelected {
    _multipleSelected = multipleSelected;
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (multipleSelected) {
        _textLayer.hidden = NO;
        _selectLayer.contents = nil;
    } else {
        _textLayer.hidden = YES;
        _selectLayer.contents = _normalLayer.contents;
    }
    [CATransaction commit];
    [self setNeedsLayout];
}

@end
