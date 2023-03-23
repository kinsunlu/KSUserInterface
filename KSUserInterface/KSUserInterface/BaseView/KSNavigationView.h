//
//  KSNavigationView.h
//  KSUserInterface
//
//  Created by Kinsun on 2020/11/30.
//  Copyright © 2020 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, KSNavigationViewStyle) {
    KSNavigationViewStyleLight  = 0,
    KSNavigationViewStyleDark   = 1,
    KSNavigationViewStyleClear  = 2
} NS_SWIFT_NAME(KSNavigationView.Style);

NS_ASSUME_NONNULL_BEGIN

@protocol KSNavigationCenterViewProtocol

@optional
/// 每当导航栏的标题变化将会更新此属性
@property (nonatomic, copy, nullable) NSString *title;
/// 每当导航栏的标题颜色变化将会更新此属性
@property (nonatomic, strong, nullable) UIColor *titleColor;
/// 每当导航栏样式发生变化将会更新此属性
@property (nonatomic, assign) KSNavigationViewStyle style;

@end

@interface KSNavigationView : UIView

/// 默认 = KSNavigationViewStyleLight
@property (nonatomic, assign) KSNavigationViewStyle style;

- (void)setBackgroundColor:(UIColor *_Nullable)backgroundColor forStyle:(KSNavigationViewStyle)style;
- (UIColor *_Nullable)backgroundColorForStyle:(KSNavigationViewStyle)style;
- (void)setLineColor:(UIColor *_Nullable)lineColor forStyle:(KSNavigationViewStyle)style;
- (UIColor *_Nullable)lineColorForStyle:(KSNavigationViewStyle)style;

@property (nonatomic, assign, getter=isHiddenLine) BOOL hiddenLine;
@property (nonatomic, assign) CGFloat statusBarHeight;
@property (nonatomic, nullable) NSString *title;

- (void)setTitleColor:(UIColor *_Nullable)titleColor forStyle:(KSNavigationViewStyle)style;
- (UIColor *_Nullable)titleColorForStyle:(KSNavigationViewStyle)style;

/// 默认=UILabel
@property (nonatomic, weak) UIView<KSNavigationCenterViewProtocol> *centerView;
@property (nonatomic, readonly) NSArray <UIView *> *leftViews;
@property (nonatomic, readonly) NSArray <UIView *> *rightViews;

/// 在导航视图添加左侧添加视图（按钮）。注意其size使用的是view.sizeThatFits返回的尺寸
/// @param leftView 要添加的视图
- (void)addLeftView:(UIView *)leftView;
- (void)removeLeftView:(UIView *)leftView;

/// 在导航视图添加右侧添加视图（按钮）。注意其size使用的是view.sizeThatFits返回的尺寸
/// @param rightView 要添加的视图
- (void)addRightView:(UIView *)rightView;
- (void)removeRightView:(UIView *)rightView;

@end

@interface KSSecondaryNavigationView : KSNavigationView

@property (nonatomic, weak, readonly) UIControl *backButton;

- (void)setBackButtonColor:(UIColor *_Nullable)backButtonColor forStyle:(KSNavigationViewStyle)style;
- (UIColor *_Nullable)backButtonColorForStyle:(KSNavigationViewStyle)style;

@end

NS_ASSUME_NONNULL_END
