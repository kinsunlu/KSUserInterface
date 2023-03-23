//
//  KSImagePickerBaseCell.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerBaseCell.h"

@implementation KSImagePickerBaseCell 

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIView *contentView = self.contentView;
        contentView.clipsToBounds = YES;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        [contentView addSubview:imageView];
        _imageView = imageView;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGRect bounds = self.contentView.bounds;
    _imageView.frame = bounds;
}

- (void)setItemModel:(KSImagePickerItemModel *)itemModel {
    _itemModel = itemModel;
    self.loseFocus = itemModel.isLoseFocus;
}

- (CGRect)imageViewFrameInSuperView {
    UIView *cellContentView = _imageView.superview;
    UIView *cell = cellContentView.superview;
    UIView *wrapperView = cell.superview;
    UIView *tableView = wrapperView.superview;
    UIView *view = tableView.superview;
    return [cell convertRect:_imageView.frame toView:view];
}

@end
