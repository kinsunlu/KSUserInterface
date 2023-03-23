//
//  KSBannerView.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/2.
//  Copyright © 2020年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KSBannerView;
@protocol KSBannerViewDelegate <NSObject, UIScrollViewDelegate>

@required
- (NSInteger)numberInBannerView:(KSBannerView *)bannerView;
/// 返回一个bannerItemView
/// @param bannerView bannerView
- (UIView *)itemInBannerView:(KSBannerView *)bannerView;
/// 根据index配置bannerViewItem
/// @param bannerView bannerView
/// @param item 要配置的ItemView
/// @param index 要配置ItemView的index
- (void)bannerView:(KSBannerView *)bannerView configurationItem:(__kindof UIView *)item atIndex:(NSInteger)index;
@optional
- (void)bannerView:(KSBannerView *)bannerView didClikeItemAtIndex:(NSInteger)index;
- (void)bannerView:(KSBannerView *)bannerView didChangeCurrentItemAtIndex:(NSInteger)index;

@end


@interface KSBannerView : UIScrollView

@property (nonatomic, weak) id <KSBannerViewDelegate> delegate;
@property (nonatomic, assign) CGFloat itemMargin;
@property (nonatomic, assign, getter=isAutoScroll) BOOL autoScroll;

- (void)reloadData;

- (void)setContentInset:(UIEdgeInsets)contentInset API_DEPRECATED("请不要给KSBannerView设置内边距。", ios(1.0, 99999.0));

@end

NS_ASSUME_NONNULL_END
