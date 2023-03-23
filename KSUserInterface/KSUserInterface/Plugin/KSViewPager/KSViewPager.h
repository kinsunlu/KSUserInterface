//
//  KSViewPager.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/11/26.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class KSViewPager;
@protocol KSViewPagerDelegate <NSObject>

@optional
/// 横向滑动viewPager时会回调此方法
/// @param viewPager viewPager
/// @param scrollView viewPager的主要scrollView
- (void)viewPager:(KSViewPager *)viewPager scrollViewDidScroll:(UIScrollView *)scrollView;

/// viewPager的页数发生变化时会回调此方法
/// @param viewPager viewPager
/// @param page 滑动的目标页index
- (void)viewPager:(KSViewPager *)viewPager currentPageDidChange:(NSUInteger)page;

@end

typedef NS_ENUM(NSInteger, KSViewPagerHeaderChangeMode) {
    //使用此模式滑动列表内容时会改变header的Y坐标
    KSViewPagerHeaderChangeModeViewY = 0,
    //使用此模式滑动列表内容时会改变header的高度
    KSViewPagerHeaderChangeModeViewHeight
} NS_SWIFT_NAME(KSViewPager.HeaderChangeMode);

@interface KSViewPager : UIView

@property (nonatomic, assign, readonly) KSViewPagerHeaderChangeMode mode;
@property (nonatomic, copy, readonly) NSArray <__kindof UIScrollView *> *scrollViews;
@property (nonatomic, assign) NSUInteger currentPage;

- (void)setCurrentPage:(NSUInteger)currentPage animated:(BOOL)animated;

/// 公共头视图
@property (nonatomic) __kindof UIView *headerView;
/// 头视图的高度，可在layoutSubViews中随时设置
@property (nonatomic, assign) CGFloat headerHeight;
/// 需要停留显示的控件高度
@property (nonatomic, assign) CGFloat headerTabHeight;
/// 停留时距离顶部的内边距
@property (nonatomic, assign) CGFloat navHeight;
/// 请不要给初始化时传递过来的scrollViews设置contentInset， 如果需要请使用此项设置其contentInset
@property (nonatomic, assign) UIEdgeInsets contentInset;

@property (nonatomic, weak) id <KSViewPagerDelegate> delegate;

- (instancetype)initWithScrollViews:(NSArray <UIScrollView *> *)scrollViews;
- (instancetype)initWithScrollViews:(NSArray <UIScrollView *> *)scrollViews mode:(KSViewPagerHeaderChangeMode)mode;

/// call this method in scrollView delegate  -scrollViewWillEndDragging:withVelocity:targetContentOffset:
/// 由于ViewPager没有使用传递过来的scrollViews的代理所以请在scrollViews的代理回调中回调此方法
/// @param scrollView scrollView scrollViewWillEndDragging calling scrollview
/// @param targetContentOffset scrollView targetContentOffset calling scrollview
- (void)updateScrollView:(UIScrollView *)scrollView targetContentOffset:(CGPoint)targetContentOffset;

@end

NS_ASSUME_NONNULL_END
