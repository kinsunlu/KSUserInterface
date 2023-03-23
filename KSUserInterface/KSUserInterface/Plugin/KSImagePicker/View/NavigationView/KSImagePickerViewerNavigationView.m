//
//  KSImagePickerViewerNavigationView.m
//  KSUserInterface
//
//  Created by Kinsun on 2019/1/7.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerViewerNavigationView.h"
 

@implementation KSImagePickerViewerNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        KSImagePickerSelectIndicator *indView = [KSImagePickerSelectIndicator.alloc initWithFrame:(CGRect){CGPointZero, 60.0, 60.0}];
        [self addRightView:indView];
        _selectIndicator = indView;
        
        self.style = KSNavigationViewStyleDark;
    }
    return self;
}

@end
