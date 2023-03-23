//
//  KSGradientButton.h
//  KSUserInterface
//
//  Created by Kinsun on 2018/11/27.
//  Copyright © 2018年 Kinsun. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSGradientButton : UIButton

/// 设置依托高度的圆角，便捷方法本质为设置layer，默认=NO。请注意，变更其值将会变更layer的masksToBounds。
@property (nonatomic, assign, getter=isRoundedCorners) BOOL roundedCorners;
@property (nonatomic, weak, readonly) CAGradientLayer *gradientLayer;

/// 设置渐变背景色数组，单个颜色将不会渐变，大于1个元素将使用线性渐变
/// @param backgroundColors 颜色数组
/// @param state 为哪个状态设置颜色
- (void)setBackgroundColors:(NSArray <UIColor *> *_Nullable)backgroundColors forState:(UIControlState)state;
/// 通过状态获得一个背景色数组
/// @param state 状态
- (NSArray <UIColor *> *_Nullable)backgroundColorsForState:(UIControlState)state;

@end

NS_ASSUME_NONNULL_END
