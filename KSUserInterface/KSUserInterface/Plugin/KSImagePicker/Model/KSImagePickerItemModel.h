//
//  KSImagePickerItemModel.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSImagePickerItemModel : NSObject

@property (nonatomic, class, readonly) NSCache <NSString *, UIImage *>*photosCache;
@property (nonatomic, class, readonly) CGSize thumbSize;
@property (nonatomic, class, readonly) PHImageRequestOptions *pictureViewerOptions;
@property (nonatomic, class, readonly) PHImageRequestOptions *pictureOptions;
#if __has_include(<KSUserInterface/KSVideoLayer.h>)
@property (nonatomic, class, readonly) PHVideoRequestOptions *videoOptions;
#endif

@property (nonatomic, assign, getter=isCameraCell) BOOL cameraCell;
@property (nonatomic, assign, getter=isLoseFocus) BOOL loseFocus;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, readonly) PHAsset *asset;
@property (nonatomic, strong) UIImage *thumb;

- (instancetype)initWithAsset:(PHAsset *)asset;

@end

NS_ASSUME_NONNULL_END
