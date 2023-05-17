//
//  KSImagePickerEditPictureNavigationView.m
//  KSUserInterface
//
//  Created by Kinsun on 2019/2/28.
//  Copyright © 2019年 Kinsun. All rights reserved.
//

#import "KSImagePickerEditPictureNavigationView.h"
#import "UIColor+Hex.h"

@implementation KSImagePickerEditPictureNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        KSTextButton *doneButton = KSTextButton.alloc.init;
        doneButton.frame = (CGRect){CGPointZero, 60.0, 0.0};
        doneButton.contentInset = (UIEdgeInsets){14.0, 0.0, 14.0, 16.0};
        doneButton.contentView.textColor = UIColor.ks_white;
        doneButton.normalTitle = @"完成";
        [self addRightView:doneButton];
        _doneButton = doneButton;
    }
    return self;
}

@end
