//
//  KSImagePickerController.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSBaseViewController.h"
#import "KSImagePickerItemModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KSImagePickerMediaType) {
    KSImagePickerMediaTypePicture   = 1,
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
    KSImagePickerMediaTypeVideo     = 2,
#endif
} NS_SWIFT_NAME(KSImagePickerController.MediaType);

typedef NS_ENUM(NSInteger, KSImagePickerEditPictureStyle) {
    KSImagePickerEditPictureStyleNormal = 0,
    KSImagePickerEditPictureStyleCircular
} NS_SWIFT_NAME(KSImagePickerController.EditPictureStyle);

@protocol KSImagePickerControllerDelegate;
@interface KSImagePickerController : KSSecondaryViewController

@property (nonatomic, assign, readonly) KSImagePickerEditPictureStyle editPictureStyle;
@property (nonatomic, assign, readonly) KSImagePickerMediaType mediaType;
@property (nonatomic, assign, readonly) NSUInteger maxItemCount;
@property (nonatomic, weak) id <KSImagePickerControllerDelegate> delegate;

- (instancetype)initWithMediaType:(KSImagePickerMediaType)mediaType;
- (instancetype)initWithMediaType:(KSImagePickerMediaType)mediaType maxItemCount:(NSUInteger)maxItemCount;
- (instancetype)initWithEditPictureStyle:(KSImagePickerEditPictureStyle)editPictureStyle;

@end

typedef NS_ENUM(NSInteger, KSImagePickerAuthorityType) {
    KSImagePickerAuthorityTypePhotoLibrary  = 1,
    KSImagePickerAuthorityTypeCamera        = 2,
    KSImagePickerAuthorityTypeMicrophone    = 3
} NS_SWIFT_NAME(KSImagePickerController.AuthorityType);

@interface KSImagePickerController (Authority)

+ (void)authorityCheckUpWithController:(UIViewController *)controller type:(KSImagePickerAuthorityType)type completionHandler:(void(^)(KSImagePickerAuthorityType type))completionHandler cancelHandler:(nullable void (^)(UIAlertAction *action))cancelHandler ;

+ (void)authorityAlertWithController:(UIViewController *)controller name:(NSString*)name cancelHandler:(nullable void (^)(UIAlertAction *action))cancelHandler;

@end

@class AVURLAsset;
@protocol KSImagePickerControllerDelegate <NSObject>

@optional
- (void)imagePicker:(KSImagePickerController *)imagePicker didFinishSelectedAssetModelArray:(NSArray <KSImagePickerItemModel *> *)assetModelArray mediaType:(KSImagePickerMediaType)mediaType;

- (void)imagePicker:(KSImagePickerController *)imagePicker didFinishSelectedImageArray:(NSArray <UIImage *> *)imageArray;

#if __has_include(<KSUserInterface/KSVideoLayer.h>)
- (void)imagePicker:(KSImagePickerController *)imagePicker didFinishSelectedVideoArray:(NSArray <AVURLAsset *> *)videoArray;
#endif

- (void)imagePicker:(KSImagePickerController *)imagePicker didFinishEditImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
