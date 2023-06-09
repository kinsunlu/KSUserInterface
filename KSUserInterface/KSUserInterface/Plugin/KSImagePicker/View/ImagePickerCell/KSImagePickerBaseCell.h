//
//  KSImagePickerBaseCell.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSImagePickerItemModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerBaseCell : UICollectionViewCell

@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, assign, getter=isLoseFocus) BOOL loseFocus;
@property (nonatomic, strong) KSImagePickerItemModel *itemModel;

@property (nonatomic, readonly) CGRect imageViewFrameInSuperView;

@end

NS_ASSUME_NONNULL_END
