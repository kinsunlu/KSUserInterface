//
//  KSBaseView.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSLoadingView.h"
#import "KSToast.h"
#import "KSNavigationView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSBaseView : UIView

@property (nonatomic, strong, nullable) UIView <NSMutableCopying>*backgroundView UI_APPEARANCE_SELECTOR;
/// 显示正在加载视图
@property (nonatomic, weak, readonly) KSLoadingView *loadingView;
@property (nonatomic, copy, nullable) void(^didClickLoadingViewCallback)(KSBaseView *, KSLoadingView *);
/// 当前Toast视图实例
@property (nonatomic, readonly) KSToast *toast;
/// 显示加载进度或加载等待的Toast视图，Message类型请使用KSToastShowMessage()
/// @param style Toast类型
- (void)showToastWithStyle:(KSToastStyle)style;
/// 隐藏Toast视图
- (void)dismissToast;

@end

@interface KSSystemStyleView : KSBaseView

@property (nonatomic, weak, readonly) __kindof KSNavigationView *navigationView;

- (instancetype)initWithFrame:(CGRect)frame navigationView:(KSNavigationView *)navigationView;

/// 将视图加到导航视图之上
/// @param view 要添加的子视图
- (void)addSubviewToTheTop:(UIView *)view;

@end

@interface KSSecondaryView : KSSystemStyleView

@property (nonatomic, weak, readonly) __kindof KSSecondaryNavigationView *navigationView;

- (instancetype)initWithFrame:(CGRect)frame navigationView:(KSSecondaryNavigationView *)navigationView;

@end

NS_ASSUME_NONNULL_END
