//
//  KSTabBarController.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/12/1.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSTabBar.h"
#import "KSTabBarItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSTabBarController : UITabBarController

@property (nonatomic, readonly) NSArray <KSTabBarItem *> *items;
@property (nonatomic, readonly) KSSystemTabBar *tabBar;

+ (instancetype)sharedInstance;

/// 此方法不应该被调用，继承后重写以添加子控制器
- (void)setupViewControllers;

- (void)setTabBarHidden:(BOOL)hidden animated:(BOOL)animated;

/// 插入一个TabBarItem
/// @param item TabBarItem
/// @param index 插入到第几个
- (void)insertTabBarItem:(KSTabBarItem *)item atIndex:(NSInteger)index;

/// 添加一个TabBarItem
/// @param item TabBarItem
- (void)addTabBarItem:(KSTabBarItem *)item;

/// mask的作用旨在某些情况下tabbar需要被遮挡
/// 在tabbar显示透明度为0.5黑色的蒙版
/// @param duration 动画持续时间（0为无动画，反之增加fade动画）
- (void)showMaskWithDuration:(NSTimeInterval)duration;

/// mask的作用旨在某些情况下tabbar需要被遮挡
/// 在tabbar显示透明度为0.5黑色的蒙版
/// @param animation 想要让mask层做的动画对象
- (void)showMaskWithAnimation:(CAAnimation * _Nullable)animation;

/// mask的作用旨在某些情况下tabbar需要被遮挡
/// 在tabbar显示蒙版
/// @param color 蒙版的颜色
/// @param animation 想要让mask层做的动画对象
- (void)showMaskWithColor:(UIColor *)color animation:(CAAnimation *_Nullable)animation;

/// 在tabbar隐藏蒙版
/// @param duration 动画持续时间（0为无动画，反之增加fade动画）
- (void)hiddenMaskWithDuration:(NSTimeInterval)duration;

/// 在tabbar隐藏蒙版
/// @param animation 想要让mask层做的动画对象
- (void)hiddenMaskWithAnimation:(CAAnimation *_Nullable)animation;

@property (nonatomic, readonly) UIViewController *topViewController;
@property (nonatomic, readonly, nullable) UINavigationController *topNavgiationViewController;

/// 获得控制器的最顶部控制器
/// @param controller 从哪个控制器开始获取
+ (UIViewController *)topViewControllerWithController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
