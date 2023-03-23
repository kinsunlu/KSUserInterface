//
//  KSDialogView.h
//  KSUserInterface
//
//  Created by Kinsun on 2021/2/17.
//  Copyright © 2021年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KSDialogViewIndicatorDirection) {
    /// 箭头方向为^
    KSDialogViewIndicatorDirectionTop       = 0,
    /// 箭头方向为v
    KSDialogViewIndicatorDirectionBottom    = 1,
    /// 箭头方向为<
    KSDialogViewIndicatorDirectionLeft      = 2,
    /// 箭头方向为>
    KSDialogViewIndicatorDirectionRight     = 3
} NS_SWIFT_NAME(KSDialogView.IndicatorDirection);

@interface KSDialogView : UIView

/// 箭头方向
@property (nonatomic, assign, readonly) KSDialogViewIndicatorDirection direction;
/// 箭头大小（width=等腰三角形的底，height=等腰三角形的高，利用的值会根据Direction使用不同的值） 默认 = {14.0, 7.0}
@property (nonatomic, assign) CGSize indicatorSize;
/// 箭头位置（等腰三角形顶点的位置，等腰三角形底边平行于x轴会作用为x，等腰三角形底边平行于y轴会作用为y） 默认 = 16.0
@property (nonatomic, assign) CGFloat indicatorFocalPoint;
/// 对话框圆角大小 默认 = 8.0
@property (nonatomic, assign) CGFloat cornerRadius;
/// 内嵌视图内边距 默认 = UIEdgeInsetsZero
@property (nonatomic, assign) UIEdgeInsets contentInset;
/// 内嵌视图
@property (nonatomic, weak) __kindof UIView *contentView;

- (instancetype)initWithDirection:(KSDialogViewIndicatorDirection)direction;
- (instancetype)initWithFrame:(CGRect)frame direction:(KSDialogViewIndicatorDirection)direction;

@end

NS_ASSUME_NONNULL_END
