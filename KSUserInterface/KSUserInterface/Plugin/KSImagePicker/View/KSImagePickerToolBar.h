//
//  KSImagePickerToolBar.h
//  KSUserInterface
//
//  Created by Kinsun on 2019/1/7.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBoxLayoutButton.h"
#import "KSGradientButton.h"

typedef NS_ENUM(NSInteger, KSImagePickerToolBarStyle) {
    KSImagePickerToolBarStylePreview = 0,
    KSImagePickerToolBarStylePageNumber
} NS_SWIFT_NAME(KSImagePickerToolBar.Style);

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerToolBar : UIView

@property (nonatomic, assign, readonly) KSImagePickerToolBarStyle style;
/**
 KSImagePickerToolBarStylePageNumber only
 */
@property (nonatomic, weak, readonly) UILabel *pageNumberLabel;
/**
 KSImagePickerToolBarStylePreview only
 */
@property (nonatomic, weak, readonly) KSTextButton *previewButton;
@property (nonatomic, weak, readonly) KSGradientButton *doneButton;

- (instancetype)initWithStyle:(KSImagePickerToolBarStyle)style;

@end

NS_ASSUME_NONNULL_END
