//
//  KSImagePickerItemModel.m
//  KSUserInterface
//
//  Created by Kinsun on 2018/12/2.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import "KSImagePickerItemModel.h"

@implementation KSImagePickerItemModel

+ (NSCache<NSString *,UIImage *> *)photosCache {
    static NSCache <NSString *,UIImage *> *k_photosCache = nil;
    if (k_photosCache == nil) {
        k_photosCache = NSCache.alloc.init;
    }
    return k_photosCache;
}

static CGSize k_thumbSize = {0.f, 0.f};
+ (CGSize)thumbSize {
    if (k_thumbSize.width == 0.f) {
        UIScreen *screen = UIScreen.mainScreen;
        CGFloat width = screen.bounds.size.width*screen.scale/4.0;
        k_thumbSize = (CGSize){width, width};
    }
    return k_thumbSize;
}

+ (PHImageRequestOptions *)pictureOptions {
    static PHImageRequestOptions *k_pictureOptions = nil;
    if (k_pictureOptions == nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        options.networkAccessAllowed = YES;
        k_pictureOptions = options;
    }
    return k_pictureOptions;
}

+ (PHImageRequestOptions *)pictureViewerOptions {
    static PHImageRequestOptions *k_pictureViewerOptions = nil;
    if (k_pictureViewerOptions == nil) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        // 同步获得图片, 只会返回1张图片
        options.synchronous = NO;
        options.networkAccessAllowed = YES;
        k_pictureViewerOptions = options;
    }
    return k_pictureViewerOptions;
}

#if __has_include(<KSUserInterface/KSVideoLayer.h>)
+ (PHVideoRequestOptions *)videoOptions {
    static PHVideoRequestOptions *k_videoOptions = nil;
    if (k_videoOptions == nil) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionCurrent;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
        k_videoOptions = options;
    }
    return k_videoOptions;
}
#endif

- (instancetype)initWithAsset:(PHAsset *)asset {
    if (self = [super init]) {
        _asset = asset;
    }
    return self;
}

@end
