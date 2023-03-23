//
//  KSAlertViewController.h
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString * const KSAlertViewControllerAnimationKey NS_SWIFT_NAME(KSAlertViewController.AnimationKey);

/// 高度自定义的AlertView，AlertView的size来自于sizeThatFits:得到的size
@interface KSAlertViewController : UIViewController

@property (nonatomic, strong) UIControl *view;

@property (nonatomic, strong) UIView *alertView;

/// 此方法不应该被调用，继承后重写此方法以返回自定义的视图
- (UIView *)loadAlertView;

@property (nonatomic, copy, nullable) CAAnimation *showAnimation UI_APPEARANCE_SELECTOR;
@property (nonatomic, copy, nullable) CAAnimation *hiddenAnimation UI_APPEARANCE_SELECTOR;

/// 点击背景是否关闭Alert，默认=NO
@property (nonatomic, assign, getter=isClickBackgroundCloseEnable) BOOL clickBackgroundCloseEnable;

/// alertview是否跟随键盘做动画
@property (nonatomic, assign, getter=isFollowKeyboard) BOOL followKeyboard;
/// 当前是否有键盘在屏幕中
@property (nonatomic, assign, getter=isKeyBoradShowed, readonly) BOOL keyBoradShowed;

/// 此句包含在UIView.animate的闭包当中，
/// 也就是说在此句中实现Frame的变更可直接展示动画。
/// 重写此方法以布局alert中的其他附加视图的移动动画
/// isFollowKeyboard = true 才会生效
/// - Parameters:
///   - frame: keyboard的目标位置
///   - duration: keyboard动画的持续时间
- (void)keyboardWillChangeToFrame:(CGRect)frame duration:(NSTimeInterval)duration;

/// 点击半透明背景会执行此方法
- (void)didClickBackgroundView;

/// 关闭alert时请执行此方法
- (void)closeAlertViewController;

@end

NS_ASSUME_NONNULL_END
