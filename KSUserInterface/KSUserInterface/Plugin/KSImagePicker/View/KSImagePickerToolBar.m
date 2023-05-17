//
//  KSImagePickerToolBar.m
//  KSUserInterface
//
//  Created by Kinsun on 2019/1/7.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerToolBar.h"
#import "UIColor+Hex.h"

@implementation KSImagePickerToolBar {
    __weak UIView *_lineView;
}

- (instancetype)initWithStyle:(KSImagePickerToolBarStyle)style {
    return [self initWithFrame:CGRectZero style:style];
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:KSImagePickerToolBarStylePreview];
}

- (instancetype)initWithFrame:(CGRect)frame style:(KSImagePickerToolBarStyle)style {
    if (self = [super initWithFrame:frame]) {
        _style = style;
        self.backgroundColor = UIColor.clearColor;
        
        UIView *lineView = [[UIView alloc] init];
        lineView.backgroundColor = UIColor.lightGrayColor;
        [self addSubview:lineView];
        _lineView = lineView;
        
        if (_style == KSImagePickerToolBarStylePreview) {
            KSTextButton *previewButton = KSTextButton.alloc.init;
            previewButton.enabled = NO;
            UILabel *label = previewButton.contentView;
            label.font = [UIFont systemFontOfSize:16.f];
            label.textColor = UIColor.ks_black;
            previewButton.normalTitle = @"预览";
            [self addSubview:previewButton];
            _previewButton = previewButton;
        } else {
            UILabel *pageNumberLabel = [[UILabel alloc] init];
            pageNumberLabel.font = [UIFont systemFontOfSize:16.0];
            pageNumberLabel.textColor = UIColor.whiteColor;
            [self addSubview:pageNumberLabel];
            _pageNumberLabel = pageNumberLabel;
        }
        
        KSGradientButton *doneButton = [KSGradientButton buttonWithType:UIButtonTypeCustom];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:12.0];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        doneButton.roundedCorners = YES;
        doneButton.enabled = NO;
        [self addSubview:doneButton];
        _doneButton = doneButton;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize windowSize = self.bounds.size;
    CGFloat windowWidth = windowSize.width;
    CGFloat windowHeight = windowSize.height;
    CGFloat viewW = windowWidth;
    CGFloat viewH = 0.5;
    CGFloat viewX = 0.0;
    CGFloat viewY = 0.0;
    _lineView.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    CGSize size = [_doneButton sizeThatFits:windowSize];
    viewW = size.width+40.0;
    viewH = 28.0;
    viewX = windowWidth-viewW-18.0;
    viewY = (windowHeight-viewH)*0.5;
    _doneButton.frame = (CGRect){viewX, viewY, viewW, viewH};
    
    if (_style == KSImagePickerToolBarStylePreview) {
        viewX = viewY = 0.0;
        size = [_previewButton sizeThatFits:windowSize];
        viewW = size.width+40.0; viewH = windowHeight;
        _previewButton.frame = (CGRect){viewX, viewY, viewW, viewH};
    } else {
        viewX = 20.0; viewY = 0.0; viewH = windowHeight;
        viewW = _doneButton.frame.origin.x-viewX;
        _pageNumberLabel.frame = (CGRect){viewX, viewY, viewW, viewH};
    }
}

@end
