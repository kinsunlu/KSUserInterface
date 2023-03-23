//
//  KSImageView.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/10/15.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const _KSWebImageURLErrorDomain;
FOUNDATION_EXPORT const NSInteger _KSWebImageURLErrorCode;

@class KSImageView;
typedef void (^KSImageViewCallback)(__kindof KSImageView *, UIImage *_Nullable, NSString *_Nullable, NSError *_Nullable);

@interface KSImageView : UIImageView

+ (UIImage *_Nullable)imageWithURL:(NSURL *)url;
+ (UIImage *_Nullable)imageWithURLString:(NSString *)urlString;

/// 当=YES时，可以丢弃那些没有显示在屏幕中的图像加载任务，从而达到节省资源。
/// 建议在tableView上Cell的imageView开启，默认=NO
@property (nonatomic, assign, getter=isTailOfQueue) BOOL tailOfQueue;

- (void)setImageURL:(NSURL *)url placeholder:(UIImage * _Nullable)placeholder finished:(_Nullable KSImageViewCallback)finished;

- (void)setImageURL:(NSURL *)url placeholder:(UIImage * _Nullable)placeholder;

- (void)setImageURL:(NSURL *)url;

- (void)setImageURLString:(NSString *)urlString placeholder:(UIImage * _Nullable)placeholder finished:(_Nullable KSImageViewCallback)finished;

- (void)setImageURLString:(NSString *)urlString placeholder:(UIImage * _Nullable)placeholder;

- (void)setImageURLString:(NSString *)urlString;

@end

@interface KSImageView (ImageCache)

/// 缓存占用磁盘的总大小单位Bytes
@property (nonatomic, readonly, class) unsigned long long totalDiskSize;
/// 磁盘中缓存图像的总个数
@property (nonatomic, readonly, class) NSUInteger totalDiskCount;

/// 使用io线程单独计算是缓存个数及占用空间的总大小
/// @param completion 计算完成后的回调
+ (void)calculateSizeWithCompletion:(void (^_Nullable)(NSUInteger, unsigned long long))completion;

/// 清空内存中的缓存
+ (void)clearMemory;

/// 清空磁盘中的缓存
+ (void)clearDisk;

/// 使用io线程单独清空磁盘中的缓存
/// @param completion 任务完成后的回调
+ (void)clearDiskOnCompletion:(void (^_Nullable)(void))completion;

+ (NSString *)stringWithSize:(unsigned long long)size;

@end

NS_ASSUME_NONNULL_END
