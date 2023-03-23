//
//  KSImagePickerEditPictureNavigationView.m
//  KSUserInterface
//
//  Created by Kinsun on 2019/2/28.
//  Copyright © 2019年 Kinsun. All rights reserved.
//

#import "KSImagePickerEditPictureNavigationView.h"

@implementation KSImagePickerEditPictureNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
        doneButton.frame = (CGRect){CGPointZero, 60.0, 0.0};
        doneButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
        [doneButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [doneButton setTitle:@"完成" forState:UIControlStateNormal];
        [self addRightView:doneButton];
        _doneButton = doneButton;
    }
    return self;
}

@end
