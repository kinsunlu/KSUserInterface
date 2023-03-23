//
//  KSActionSheetViewController.h
//  KSUserInterface
//
//  Created by Kinsun on 2022/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 高度自定义的ActionSheet，ActionSheet的size来自于sizeThatFits:得到的size
@interface KSActionSheetViewController : UIViewController

@property (nonatomic, strong) UIControl *view;

@property (nonatomic, strong) UIView *actionSheetView;

/// 此方法不应该被调用，继承后重写此方法以返回自定义的视图
- (UIView *)loadActionSheetView;

/// 点击背景是否关闭actionSheet，默认=YES
@property (nonatomic, assign, getter=isClickBackgroundCloseEnable) BOOL clickBackgroundCloseEnable;

/// actionSheetView是否跟随键盘做动画
@property (nonatomic, assign, getter=isFollowKeyboard) BOOL followKeyboard;
/// 当前是否有键盘在屏幕中
@property (nonatomic, assign, getter=isKeyBoradShowed, readonly) BOOL keyBoradShowed;

/// 点击半透明背景会执行此方法
- (void)didClickBackgroundView;

/// 关闭actionSheet时请执行此方法
- (void)closeActionSheetViewController;

@end

NS_ASSUME_NONNULL_END
