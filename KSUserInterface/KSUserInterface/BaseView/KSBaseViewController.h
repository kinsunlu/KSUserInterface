//
//  KSBaseViewController.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KSBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSBaseViewController <__covariant View: KSBaseView*> : UIViewController

@property (nonatomic, strong) View view;

/// 设定此项可以在KSNavigationController push时检查当前栈顶第二控制器是否与目标控制器是否为相同类型并且标识符也相同，
/// 即会pop回第二控制器而不是push出新的，为了不造成循环交替push两个相同的控制器
@property (nonatomic, copy, readonly, nullable) NSString *tag;
/// 设定当前控制器内是否启用左侧边缘滑动返回上一级手势，默认=YES
@property (nonatomic, getter=isInteractivePopEnabled) BOOL interactivePopEnabled;

/// 此方法不应该被调用，控制器第一次视图已经被展示的回调
/// @param animated 是否包含动画
- (void)firstViewDidAppear:(BOOL)animated;

/// 此方法不应该被调用，控制器第一次视图已经被完全的布局
- (void)firstViewDidLayoutSubviews;

/// 此方法不应该被调用，当tabBar选中的是当前控制器时再次点击选中的item就会调用此方法
- (void)clickTabBarItemOnTheSelfController;

/// 此方法不应该被调用，当点击正在加载视图的回调
/// @param loadingView 正在加载视图
- (void)didClickLoadingView:(KSLoadingView *)loadingView;

@end

typedef KSBaseViewController<KSBaseView*>* KSBaseViewControllerDefault;

/// 默认带导航栏的控制器
@interface KSSystemStyleViewController<__covariant View: KSSystemStyleView*> : KSBaseViewController<View>

/// 带导航视图的view
@property (nonatomic, strong) View view;

@end

typedef KSSystemStyleViewController<KSSystemStyleView*>* KSSystemStyleViewControllerDefault;

/// 默认带导航栏并且导航栏带返回按钮的控制器
@interface KSSecondaryViewController<__covariant View: KSSecondaryView*> : KSSystemStyleViewController<View>

/// 带导航视图带返回按钮的view
@property (nonatomic, strong) View view;

/// 关闭按钮调用的方法
- (void)didClickNavigationBackButton:(UIControl *)backButton;

@end

typedef KSSecondaryViewController<KSSecondaryView*>* KSSecondaryViewControllerDefault;

@interface KSNavigationController : UINavigationController

@end

typedef UIViewController ViewController;

@interface UIViewController (KSNavigationController)

@property (nonatomic, readonly) UIViewController *lastPresentedViewController;

/// 获得当前控制器的真实导航控制器
@property (nonatomic, readonly) KSNavigationController *controllerNavigationController;

/// 判断当前控制器是否为导航控制器
@property (nonatomic, readonly, getter=isNavigationController) BOOL isNavigationController;

/// 从底部显示出一个新的带导航控制器的控制器(带动画)
/// @param controller 要显示的控制器
- (void)presentNavigationControllerWithViewController:(ViewController *)controller;

/// 从底部显示出一个新的带导航控制器的控制器
/// @param controller 要显示的控制器
/// @param animated 是否使用动画效果
- (void)presentNavigationControllerWithViewController:(ViewController *)controller animated:(BOOL)animated;

/// 从底部显示出一个新的带导航控制器的控制器
/// @param controller 要显示的控制器
/// @param animated  是否使用动画效果
/// @param completion 完成后回调Block
- (void)presentNavigationControllerWithViewController:(ViewController *)controller animated:(BOOL)animated completion:(void (^_Nullable)(void))completion;

/// 关闭从底部显示出的控制器(带动画)
- (void)dismissViewController;

/// 关闭从底部显示出的控制器
/// @param animated 是否使用动画效果
- (void)dismissViewControllerAnimation:(BOOL)animated;

/// 关闭从底部显示出的控制器(不支持动画)
- (void)dismissToViewController:(ViewController *)controller;

/// 关闭从底部显示出的控制器到某个控制器(不支持动画)
/// @param controller 目标控制器
/// @param completion 完成后回调Block
- (void)dismissToViewController:(ViewController *)controller completion:(void (^_Nullable)(void))completion;

/// 关闭从导航控制器显示出的所有控制器(带动画)
- (void)popToRootViewController;

/// 关闭从导航控制器显示出的所有控制器
/// @param animated 是否使用动画效果
- (void)popToRootViewControllerAnimated:(BOOL)animated;

/// 关闭从导航控制器显示出的控制器(带动画)
- (void)popViewController;

/// 关闭从导航控制器显示出的控制器
/// @param animated 是否使用动画效果
- (void)popViewControllerAnimated:(BOOL)animated;

/// 关闭当前控制器并跳转到指定控制器(带动画)
/// @param controller 要显示的控制器
- (void)popToViewController:(ViewController *_Nullable)controller;

/// 关闭当前控制器并跳转到指定控制器(带动画)
/// @param controller 要显示的控制器
/// @param animated 是否使用动画效果
- (void)popToViewController:(ViewController *_Nullable)controller animation:(BOOL)animated;

/// 使用导航控制器显示新的控制器(带动画)
/// @param controller 要显示的控制器
- (void)pushViewController:(ViewController *)controller;

/// 使用导航控制器显示新的控制器(带动画)
/// @param controller 要显示的控制器
/// @param animated 是否使用动画效果
- (void)pushViewController:(ViewController *)controller animated:(BOOL)animated;

/// 关闭当前控制器，会自动识别是否使用了导航控制器无论使用什么方式都会关闭(带动画)
- (void)closeCurrentViewController;

/// 关闭当前控制器，会自动识别是否使用了导航控制器无论使用什么方式都会关闭
/// @param animated 是否使用动画效果
- (void)closeCurrentViewControllerAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
