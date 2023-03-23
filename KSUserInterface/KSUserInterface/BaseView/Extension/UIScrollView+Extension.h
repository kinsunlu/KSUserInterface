//
//  UIScrollView+Extension.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/3.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSLoadingView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KSScrollViewDelegate <UIScrollViewDelegate>
@optional

/// 上拉刷新回调
- (void)scrollViewDidBeginRefresh:(UIScrollView *)scrollView;

/// 加载更多回调
- (void)scrollViewDidLoadMoreData:(UIScrollView *)scrollView;

/// scrollView停止滚动回调，无论动画停止还是滑动停止都会回调
- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView;

@end

typedef NS_ENUM(NSInteger, KSScrollViewLoadStyle){
    KSScrollViewLoadStyleNormal     = 0,
    KSScrollViewLoadStyleRefresh    = 1, //只有刷新
    KSScrollViewLoadStyleLoadMore   = 2, //只有加载更多
    KSScrollViewLoadStyleAll        = 3  //刷新和加载更多都有
}; /// NS_SWIFT_NAME(UIScrollView.LoadStyle);

@interface UIScrollView (KSUserInterface)

@property (nonatomic, weak) id <KSScrollViewDelegate> delegate;

// ********** Refresh ********** //
/// class must kindof MJRefreshHeader
@property (nonatomic, class) Class refreshHeaderClass;
/// class must kindof MJRefreshFooter
@property (nonatomic, class) Class loadMoreFooterClass;

@property (nonatomic, assign) KSScrollViewLoadStyle loadStyle;

/// 强制调用下拉刷新
- (void)launchRefresh;
/// 停止下拉刷新
- (void)finishRefresh;
/// 停止加载更多
- (void)finishLoadMore;
/// 停止加载更多并且没有更多
- (void)finishLoadMoreAndNoMore;
/// 重置没有更多
- (void)resetNoMoreData;

// ******** ScrollsToTop ********//
- (void)scrollViewScrollsToTop;
- (void)scrollViewScrollsToTopAnimated:(BOOL)animated;

// ******** LoadingView ******** //
@property (nonatomic, readonly) KSLoadingView *loadingView;
@property (nonatomic, assign) CGFloat topMargin;

- (void)layoutLoadingView:(KSLoadingView *)loadingView;
- (KSLoadingView *)loadLoadingView;

@end

NS_ASSUME_NONNULL_END
