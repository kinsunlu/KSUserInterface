//
//  KSImagePickerEditPictureView.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/10.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSBaseView.h"
#import "KSImagePickerEditPictureNavigationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerEditPictureView : KSSecondaryView

@property (nonatomic, weak, readonly) KSImagePickerEditPictureNavigationView *navigationView;
@property (nonatomic, getter=isCircularMask) BOOL circularMask;
@property (nonatomic, weak, readonly) UIImageView *imageView;
@property (nonatomic, readonly) CGRect contentRect;

@property (nonatomic, readonly, nullable) UIImage *snapshot;

@end

NS_ASSUME_NONNULL_END
