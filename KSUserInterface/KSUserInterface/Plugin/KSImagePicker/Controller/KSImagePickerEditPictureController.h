//
//  KSImagePickerEditPictureController.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/10.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class KSImagePickerEditPictureController, KSImagePickerItemModel, KSImagePickerController;
@protocol KSImagePickerEditPictureDelegate <NSObject>

- (void)imagePickerEditPicture:(KSImagePickerEditPictureController *)imagePickerEditPicture didFinishSelectedImage:(UIImage *)image assetModel:(KSImagePickerItemModel *)assetModel;

@end

@interface KSImagePickerEditPictureController : KSSecondaryViewController

@property (nonatomic, assign, getter=isCircularMask) BOOL circularMask;
@property (nonatomic, strong) KSImagePickerItemModel *model;
@property (nonatomic, weak) KSImagePickerController <KSImagePickerEditPictureDelegate> *delegate;

@end

NS_ASSUME_NONNULL_END
